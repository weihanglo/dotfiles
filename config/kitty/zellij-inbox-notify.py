"""Kitty 0.50+ watcher for Zellij 0.46+ status, locally or over SSH.

Runs in Kitty's Python runtime; requires an attached client and host_status=true.
Only the highest-priority pane is reported; direct OSC notifications may overlap.
Local pane focus needs an unambiguous inbox label and lsof (included with macOS).
macOS needs an official signed Kitty build for native notifications.
https://github.com/kovidgoyal/kitty/discussions/7929
https://zellij.dev/documentation/inbox-integrations.html#passing-status-to-your-terminal
"""

import json
import os
import re
import subprocess
import sys
import time

# Notification APIs are internal; source-checked in 0.50.0/0.51.0. Recheck upgrades.
# https://github.com/kovidgoyal/kitty/blob/v0.51.0/kitty/notifications.py
from kitty.fast_data_types import add_timer
from kitty.notifications import OnlyWhen


_TITLES = {
    "blocked": "Zellij: needs you",
    "error": "Zellij: command failed",
    "done": "Zellij: command finished",
}
_previous = {}
_STATES = {"blocked": "NeedsYou", "error": "Failed", "done": "Done"}
_DISPLAY_CONTROLS = re.compile(
    r"[\x00-\x1f\x7f-\x9f\u00ad\u061c\u200b-\u200f"
    r"\u202a-\u202e\u2060-\u2064\u2066-\u206f\ufeff]"
)


# Match Zellij 0.46's sanitized, truncated host label and command-text redaction.
# https://github.com/zellij-org/zellij/blob/v0.46.0/zellij-utils/src/attention.rs
def _pane_label(pane, text=None):
    if text is None:
        attention = pane["attention"]
        text = attention["text"]
        if attention["source"] in ("ShellCommand", "CommandPane", "ForegroundProcess", "Watch"):
            text = text.split(": ", 1)[0]
    tab, title, text = (
        _DISPLAY_CONTROLS.sub("", value)
        for value in (pane["tab_name"], pane["title"], text)
    )
    place = " › ".join(value for value in (tab, title) if value)
    label = f"{place}: {text}" if text else place
    return label.encode("utf-8")[:2048].decode("utf-8", errors="ignore")


# list-panes --all --json includes attention and tab names in Zellij 0.46+.
# https://zellij.dev/documentation/programmatic-control.html#structured-output-reference
def _find_pane(executable, state, message):
    deadline = time.monotonic() + 3

    def query(*args):
        return subprocess.check_output(
            [executable, *args], stdin=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL, text=True, timeout=max(0, deadline - time.monotonic()),
        )

    match = None
    try:
        for session in query("list-sessions", "--short").splitlines():
            try:
                panes = json.loads(query("--session", session, "action", "list-panes", "--all", "--json"))
            except (subprocess.CalledProcessError, ValueError):
                continue  # Saved session without a server.
            for pane in panes:
                attention = pane["attention"]
                if pane["is_plugin"] or attention["muted"] is not None:
                    continue
                # A bare completion can clear before list-panes takes its snapshot.
                # Its entire label is reproducible from the tab and pane titles.
                if state == "done" and message.endswith(": done"):
                    matches = _pane_label(pane, "done") == message
                else:
                    matches = attention["status"] == _STATES[state] and _pane_label(pane) == message
                if matches:
                    if match is not None:
                        return None  # The host label identifies more than one pane.
                    match = pane["id"]
    except (OSError, ValueError, subprocess.SubprocessError):
        return None
    return match


# Kitty 0.50+ exposes the foreground process and its environment on Child.
# https://github.com/kovidgoyal/kitty/blob/v0.51.0/kitty/child.py
def _local_client(window):
    for process in window.child.foreground_processes:
        argv = process["cmdline"]
        if argv and os.path.basename(argv[0]) in ("zellij", ".zellij-wrapped"):
            pid = process["pid"]
            # Zellij can switch sessions without changing PID. Its Unix socket
            # changes on reconnect. Kitty also clears done/error records on focus.
            # https://github.com/lsof-org/lsof/blob/master/Lsof.8
            try:
                sockets = subprocess.check_output(
                    ["/usr/sbin/lsof" if sys.platform == "darwin" else "lsof",
                     "-nP", "-a", "-p", str(pid), "-U", "-Ffin"],
                    stderr=subprocess.DEVNULL, timeout=0.5,
                )
            except (OSError, subprocess.SubprocessError):
                return None
            if any(line.startswith((b"n->", b"i")) for line in sockets.splitlines()):
                return pid, argv[0], sockets
    return None


def _activation_callback(boss, window, signature):
    client = _local_client(window)
    if client is None:
        return None
    window_id = window.id
    state, _, _, message = signature
    # Kitty's GUI can leave Python worker threads idle past the lookup deadline.
    # +launch runs this file in a separate Kitty Python process (0.50/0.51).
    # https://github.com/kovidgoyal/kitty/blob/v0.51.0/kitty/entry_points.py
    try:
        lookup = subprocess.Popen(
            [sys.executable, "+launch", __file__, client[1], state, message],
            env=window.child.foreground_environ, stdin=subprocess.DEVNULL,
            stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True,
        )
    except OSError:
        return None

    def activate(_command, button=0):
        current = boss.window_id_map.get(window_id)
        if button or current is None:
            return
        if lookup.poll() is None:
            add_timer(activate, 0.05, False)
        else:
            pane_id = lookup.stdout.read().strip()
            if not pane_id.isdigit() or _local_client(current) != client:
                return
            # OSC 99 routes the click to the client that received this notification.
            # https://github.com/zellij-org/zellij/blob/v0.46.0/zellij-server/src/screen.rs
            current.write_to_child(f"\x1b]99;i=p{pane_id}.zellij-inbox-notify;\x1b\\")

    return activate


# Both watcher callbacks and the record schema:
# https://sw.kovidgoyal.net/kitty/launch/#watching-launched-windows
# Zellij's app=zellij producer:
# https://github.com/zellij-org/zellij/blob/v0.46.0/zellij-utils/src/attention.rs
def on_program_status_change(boss, window, data):
    current = {
        record["id"]: (
            record["state"],
            record["kind"],
            record["title"],
            record["msg"],
        )
        for record in data["program_status"]
        if record["app"] == "zellij"
    }
    if not current:
        _previous.pop(window.id, None)
        return
    previous = _previous.get(window.id, {})

    # Boss.notification_manager is internal too; it preserves Kitty's filters/focus.
    # https://github.com/kovidgoyal/kitty/blob/v0.51.0/kitty/boss.py
    manager = boss.notification_manager
    for record_id, signature in current.items():
        state, _kind, title, message = signature
        if state not in _TITLES or previous.get(record_id) == signature:
            continue
        command = manager.create_notification_cmd()
        command.title = _TITLES[state]
        command.body = message or title
        command.application_name = "zellij"
        # One notification per window/record; subsequent reports replace it.
        command.identifier = f"zellij-status-{window.id}-{record_id}"
        command.only_when = OnlyWhen.always
        command.on_activation = _activation_callback(boss, window, signature)
        manager.notify_with_command(command, window.id)

    _previous[window.id] = current


def on_close(boss, window, data):
    _previous.pop(window.id, None)


if __name__ == "__main__":
    pane_id = _find_pane(*sys.argv[1:])
    if pane_id is not None:
        print(pane_id)
