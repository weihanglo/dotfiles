"""Kitty 0.50+ watcher for Zellij 0.46+ status, locally or over SSH.

Runs in Kitty's Python runtime; requires an attached client and host_status=true.
Only the highest-priority pane is reported; direct OSC notifications may overlap.
macOS needs an official signed Kitty build for native notifications.
https://github.com/kovidgoyal/kitty/discussions/7929
https://zellij.dev/documentation/inbox-integrations.html#passing-status-to-your-terminal
"""

# Notification APIs are internal; source-checked in 0.50.0/0.51.0. Recheck upgrades.
# https://github.com/kovidgoyal/kitty/blob/v0.51.0/kitty/notifications.py
from kitty.notifications import OnlyWhen


_TITLES = {
    "blocked": "Zellij: needs you",
    "error": "Zellij: command failed",
    "done": "Zellij: command finished",
}
_previous = {}


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
    previous = _previous.get(window.id, {})
    # Ignore progress-only updates; clear/restart permits repeated results.
    _previous[window.id] = current

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
        manager.notify_with_command(command, window.id)


def on_close(boss, window, data):
    _previous.pop(window.id, None)
