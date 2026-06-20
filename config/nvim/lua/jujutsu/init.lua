--- jujutsu.nvim — minimal Jujutsu (jj) integration for Neovim.
---
--- This module is just the orchestrator: it wires the feature modules together
--- on setup(). Each feature lives in its own file and owns its state, commands,
--- and autocmds. To add a jj feature, drop a module exposing setup() and call
--- it below.

local M = {}

function M.setup()
	-- Feature modules are wired in here as they are added.
end

return M
