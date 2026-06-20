--- jujutsu.nvim — minimal Jujutsu (jj) integration for Neovim.
---
--- This module is just the orchestrator: it wires the feature modules together
--- on setup(). Each feature lives in its own file and owns its state, commands,
--- and autocmds:
---
---   * jujutsu.jj      — the only place that shells out to the `jj` CLI
---   * jujutsu.gutter  — uncommitted-change signs in the sign column
---   * jujutsu.blame   — `jj file annotate` line/file blame
---
--- To add a new jj feature, drop a module with a setup() here and call it below.

local M = {}

--- Whether a path lives inside a jj repo. Used by the gitsigns config to bow
--- out where jujutsu owns the gutter (in a colocated repo the two would draw
--- identical signs, since git HEAD tracks jj's `@-`).
--- @param path string
--- @return boolean
function M.in_repo(path)
	return require("jujutsu.jj").in_repo(path)
end

function M.setup()
	require("jujutsu.gutter").setup()
	require("jujutsu.blame").setup()
end

return M
