--- Launch the jjui terminal UI.
---
--- Surface:
---   :JJ ui  open jjui in a terminal tab; the buffer is wiped when jjui exits.
---
--- Unlike the other jujutsu modules this is an interactive TUI that mutates the
--- repo, so it deliberately does *not* go through jj.run's read-only,
--- `--ignore-working-copy` wrapper — it just spawns the terminal.

local api = vim.api

local M = {}

--- Open jjui in a new terminal tab.
function M.open()
	vim.cmd("tabedit | terminal jjui")
end

function M.setup()
	-- Wipe the terminal buffer once jjui exits, so a dead shell prompt is not
	-- left behind.
	api.nvim_create_autocmd("TermClose", {
		group = api.nvim_create_augroup("jujutsu_ui", { clear = true }),
		pattern = "term://*:jjui*",
		callback = function(ev)
			api.nvim_buf_delete(ev.buf, { force = true })
		end,
	})
end

return M
