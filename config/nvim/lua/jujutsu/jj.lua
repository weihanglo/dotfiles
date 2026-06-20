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

return M
