--- Thin wrapper around the `jj` CLI.
---
--- The single place that shells out to jujutsu. Every command runs with
--- `--ignore-working-copy` so we never trigger a snapshot as a side effect of
--- drawing UI; feature modules (gutter, blame, ...) build on `run`.

local M = {}

--- Run jj synchronously, capturing stdout as lines.
--- @param args string[] arguments after the global flags
--- @param cwd string directory to run in
--- @return string[]? lines stdout split on newlines, or nil on non-zero exit
function M.run(args, cwd)
	local cmd = { "jj", "--no-pager", "--color=never", "--ignore-working-copy" }
	vim.list_extend(cmd, args)
	local res = vim.system(cmd, { cwd = cwd, text = true }):wait()
	if res.code ~= 0 then
		return nil
	end
	local lines = vim.split(res.stdout or "", "\n")
	-- jj output ends with a newline; drop the trailing empty element so callers
	-- get one entry per real line.
	if lines[#lines] == "" then
		lines[#lines] = nil
	end
	return lines
end

--- Locate the jj repo root containing a directory.
--- @param dir string
--- @return string? root normalized absolute path, or nil if not in a repo
function M.root(dir)
	local out = M.run({ "root" }, dir)
	return out and out[1] ~= "" and vim.fs.normalize(out[1]) or nil
end

--- Whether a path lives inside a jj repo, by `.jj` marker lookup.
---
--- Cheap and synchronous (no subprocess), unlike root() — safe to call from
--- hot paths such as another plugin's attach callback.
--- @param path string
--- @return boolean
function M.in_repo(path)
	return vim.fs.root(path, ".jj") ~= nil
end

--- Notify with the shared `jujutsu:` prefix. Returns nil so a guard can both
--- report and bail in one line: `return jj.warn("not in a jj repo")`.
--- @param msg string
--- @return nil
function M.warn(msg)
	vim.notify("jujutsu: " .. msg, vim.log.levels.WARN)
end

--- Like warn(), but at INFO level. Also returns nil for the bail-in-one-line
--- pattern.
--- @param msg string
--- @return nil
function M.info(msg)
	vim.notify("jujutsu: " .. msg, vim.log.levels.INFO)
end

--- Like warn(), but at ERROR level. Also returns nil for the bail-in-one-line
--- pattern.
--- @param msg string
--- @return nil
function M.error(msg)
	vim.notify("jujutsu: " .. msg, vim.log.levels.ERROR)
end

return M
