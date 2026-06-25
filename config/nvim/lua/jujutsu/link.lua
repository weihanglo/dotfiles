--- GitHub permalink for the current file/selection, in the spirit of
--- gitlinker.nvim but driven by jj.
---
--- Surface:
---   :JJ link  copy a GitHub permalink to the `+` register and open it.
---             Works on the cursor line (normal) or the selection (visual).
---
--- The rev is the closest *pushed* ancestor — `latest(::@ & remote_bookmarks())`
--- — so the link points at a commit_id that actually exists on the remote and
--- never rots, even when the working copy isn't pushed. We warn (not block) if
--- the file differs between that rev and the working copy.
---
--- Design axioms (keep these when editing):
---   * Read-only: never mutates the repo (jj.run uses `--ignore-working-copy`).
---   * GitHub-focused: this is the only forge in use; no multi-host router.

local jj = require("jujutsu.jj")

local M = {}

-- The closest ancestor that lives on a remote bookmark. Its commit_id is a
-- stable SHA present on the remote, which is what makes the link permanent.
local PUSHED_REV = "latest(::@ & remote_bookmarks())"

--- Parse a git remote URL into host/org/repo. Handles the two forms jj emits:
---   git@github.com:org/repo.git      (scp-like)
---   https://github.com/org/repo.git  (with optional user@ and :port)
--- @param url string
--- @return { host: string, org: string, repo: string }?
local function parse_remote(url)
	-- scp-like: [user@]host:org/repo[.git]
	local host, path = url:match("^[%w._-]+@([%w._-]+):(.+)$")
	if not host then
		-- url form: scheme://[user@]host[:port]/org/repo[.git]
		host, path = url:match("^%w+://[^@/]-@?([%w._-]+):?%d*/(.+)$")
	end
	if not host or not path then
		return nil
	end
	path = path:gsub("%.git$", ""):gsub("/$", "")
	local org, repo = path:match("^(.+)/([^/]+)$")
	if not org then
		return nil
	end
	return { host = host, org = org, repo = repo }
end

--- Build the permalink for the current buffer, or nil with a notified reason.
--- @param lstart integer first line of the range (1-based)
--- @param lend integer last line of the range (1-based)
--- @return string?
local function build_url(lstart, lend)
	local path = vim.api.nvim_buf_get_name(0)
	if path == "" then
		return jj.warn("buffer has no file")
	end
	local dir = vim.fs.dirname(path)

	local root = jj.root(dir)
	if not root then
		return jj.warn("not in a jj repo")
	end

	-- First configured remote, preferring one literally named "origin".
	local remotes = jj.run({ "git", "remote", "list" }, root) or {}
	local remote_url
	for _, line in ipairs(remotes) do
		local name, url = line:match("^(%S+)%s+(%S+)$")
		if name and (name == "origin" or not remote_url) then
			remote_url = url
		end
	end
	if not remote_url then
		return jj.warn("no git remote configured")
	end

	local parsed = parse_remote(remote_url)
	if not parsed then
		return jj.error("cannot parse remote url: " .. remote_url)
	end

	local rev = jj.run({ "log", "--no-graph", "-r", PUSHED_REV, "-T", "commit_id" }, root)
	if not rev or not rev[1] or rev[1] == "" then
		return jj.warn("no pushed ancestor to link against")
	end
	local commit = rev[1]

	local relpath = vim.fs.normalize(path):sub(#root + 2)

	-- Warn if the local file differs from the linked rev — the link is still
	-- valid, it just may not match what's on screen.
	local diff = jj.run({ "diff", "--from", commit, "--name-only", relpath }, root)
	if diff and #diff > 0 then
		jj.warn("file differs from linked rev " .. commit:sub(1, 8))
	end

	local anchor = string.format("#L%d", lstart)
	if lend > lstart then
		anchor = anchor .. string.format("-L%d", lend)
	end

	return string.format(
		"https://%s/%s/%s/blob/%s/%s%s",
		parsed.host,
		parsed.org,
		parsed.repo,
		commit,
		vim.uri_encode(relpath, "rfc3986"):gsub("%%2F", "/"),
		anchor
	)
end

--- Copy a GitHub permalink to the `+` register and open it.
--- @param lstart integer first line of the range (1-based)
--- @param lend integer last line of the range (1-based)
function M.link(lstart, lend)
	local url = build_url(lstart, lend)
	if not url then
		return
	end
	vim.fn.setreg("+", url)
	vim.notify(url, vim.log.levels.INFO)
	pcall(vim.ui.open, url)
end

return M
