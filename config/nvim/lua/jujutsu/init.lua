--- jujutsu.nvim — minimal Jujutsu (jj) integration for Neovim.
---
--- This module is just the orchestrator: it wires the feature modules together
--- on setup(). Each feature lives in its own file and owns its state, commands,
--- and autocmds:
---   * jujutsu.jj      — the only place that shells out to the `jj` CLI
---   * jujutsu.gutter  — uncommitted-change signs in the sign column
---
--- To add a new jj feature, drop a module with a setup() here and call it below.

local M = {}

function M.setup()
	require("jujutsu.gutter").setup()
end

return M
