--- Blame display backed by `jj file annotate` (no reblame).
---
--- Two surfaces:
---   :JJBlameLine  toggle current-line virtual text (change-id, author, ago, summary)
---   :JJBlame      open a scroll-synced annotation column for the whole file
---
--- Design axioms (keep these when editing):
---   * Read-only: annotate never mutates the repo (jj.run uses
---     `--ignore-working-copy`).
---   * Annotation is parsed from a tab-separated template, so fields may contain
---     spaces; never split on whitespace.
---   * UI buffers/windows created here clean themselves up (scratch, wipe on
---     hide); no lingering state between invocations.

local api = vim.api
local jj = require("jujutsu.jj")

local M = {}

local NS = api.nvim_create_namespace("jujutsu_blame")

-- Tab-separated so we can parse without worrying about spaces in fields.
-- Fields: change-id, author name, relative time, first line of description.
local TEMPLATE = table.concat({
	"commit.change_id().shortest(8)",
	"commit.author().name()",
	"commit.author().timestamp().ago()",
	"commit.description().first_line()",
}, ' ++ "\\t" ++ ') .. ' ++ "\\n"'

--- Run `jj file annotate` and return parsed per-line blame entries.
--- @param bufnr integer
--- @return { change: string, author: string, ago: string, summary: string }[]?
local function annotate(bufnr)
	local path = api.nvim_buf_get_name(bufnr)
	if path == "" then
		return nil
	end
	local dir = vim.fs.dirname(path)
	local out = jj.run({ "file", "annotate", "-T", TEMPLATE, path }, dir)
	if not out then
		jj.error("blame failed for " .. path)
		return nil
	end

	local lines = {}
	for _, line in ipairs(out) do
		local change, author, ago, summary = line:match("^(.-)\t(.-)\t(.-)\t(.*)$")
		if change then
			lines[#lines + 1] = { change = change, author = author, ago = ago, summary = summary }
		end
	end
	return lines
end

-- Current-line virtual text -------------------------------------------------

local current_line_enabled = false

local function clear_current_line(bufnr)
	api.nvim_buf_clear_namespace(bufnr, NS, 0, -1)
end

--- Render blame virtual text on the cursor line.
local function show_current_line()
	local bufnr = api.nvim_get_current_buf()
	clear_current_line(bufnr)
	if not current_line_enabled then
		return
	end
	local lnum = api.nvim_win_get_cursor(0)[1]
	local blame = annotate(bufnr)
	local entry = blame and blame[lnum]
	if not entry then
		return
	end
	local text = string.format("%s  %s, %s · %s", entry.change, entry.author, entry.ago, entry.summary)
	api.nvim_buf_set_extmark(bufnr, NS, lnum - 1, 0, {
		virt_text = { { text, "Comment" } },
		virt_text_pos = "eol",
	})
end

function M.toggle_current_line()
	current_line_enabled = not current_line_enabled
	show_current_line()
end

-- Full-file blame column ----------------------------------------------------

--- Open a left split with per-line blame, scroll-bound to the source buffer.
function M.blame_file()
	local src_buf = api.nvim_get_current_buf()
	local src_win = api.nvim_get_current_win()
	local blame = annotate(src_buf)
	if not blame then
		return
	end

	local width = 0
	local rendered = {}
	for _, e in ipairs(blame) do
		local line = string.format("%s %s %s", e.change, e.author, e.ago)
		rendered[#rendered + 1] = line
		width = math.max(width, #line)
	end

	-- Scratch buffer in a narrow left split.
	vim.cmd("topleft vsplit")
	local win = api.nvim_get_current_win()
	local buf = api.nvim_create_buf(false, true)
	api.nvim_win_set_buf(win, buf)
	api.nvim_buf_set_lines(buf, 0, -1, false, rendered)

	vim.bo[buf].modifiable = false
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].filetype = "jjblame"
	api.nvim_win_set_width(win, math.min(width, 60))
	local wo = vim.wo[win]
	wo.number = false
	wo.relativenumber = false
	wo.signcolumn = "no"
	wo.foldcolumn = "0"
	wo.wrap = false
	wo.cursorline = true

	-- Bind scrolling: both windows scroll together, aligned line-for-line.
	for _, w in ipairs({ src_win, win }) do
		vim.wo[w].scrollbind = true
	end
	api.nvim_set_current_win(src_win)
	vim.cmd("syncbind")

	-- Close the blame window with q; unbind the source on the way out.
	api.nvim_buf_set_keymap(buf, "n", "q", "", {
		noremap = true,
		silent = true,
		callback = function()
			if api.nvim_win_is_valid(src_win) then
				vim.wo[src_win].scrollbind = false
			end
			if api.nvim_win_is_valid(win) then
				api.nvim_win_close(win, true)
			end
		end,
	})
end

function M.setup()
	api.nvim_create_user_command("JJBlame", M.blame_file, { desc = "jj annotate: full-file blame" })
	api.nvim_create_user_command("JJBlameLine", M.toggle_current_line, {
		desc = "jj annotate: toggle current-line blame",
	})

	api.nvim_create_autocmd("CursorMoved", {
		group = api.nvim_create_augroup("jujutsu_blame", { clear = true }),
		callback = function()
			if current_line_enabled then
				show_current_line()
			end
		end,
	})
end

return M
