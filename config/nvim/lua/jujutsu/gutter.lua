--- Gutter signs for uncommitted jj changes, in the spirit of gitsigns.nvim.
---
--- Signs reflect the diff of the *live buffer* against the working-copy parent
--- (`@-`). Diffing the buffer rather than `jj diff` output means unsaved edits
--- show up too, without forcing a jj snapshot on every keystroke.
---
--- Design axioms (keep these when editing):
---   * Read-only: never mutate the repo; UI must not cause a working-copy
---     snapshot (hence jj.run's `--ignore-working-copy`).
---   * Per-buffer state is owned here and torn down in detach(); no leaks.
---   * Rendering is debounced and idempotent — safe to call render() anytime.

local api = vim.api
local jj = require("jujutsu.jj")

local M = {}

-- Compared against `@-`: in jj `@` is the working copy, so this is the
-- equivalent of git's "uncommitted changes" gutter.
local BASE_REV = "@-"
local DEBOUNCE_MS = 200
local NS = api.nvim_create_namespace("jujutsu_gutter")

-- TODO(coexistence): these glyphs are identical to the gitsigns config in
-- plugins.lua, so the two overdraw each other in a git+jj repo. Give the jj
-- gutter a distinct glyph / sign priority before re-enabling gitsigns.
-- Highlights link to GitSigns* groups, which catppuccin themes.
local SIGNS = {
	add = { text = "▎", hl = "GitSignsAdd" },
	change = { text = "▎", hl = "GitSignsChange" },
	delete = { text = "▁", hl = "GitSignsDelete" },
	topdelete = { text = "▔", hl = "GitSignsDelete" },
	changedelete = { text = "░", hl = "GitSignsChange" },
}

-- Per-buffer state: { root, relpath, base_lines, timer }.
local state = {}

--- Snapshot the file content at BASE_REV into state.base_lines.
--- @param bufnr integer
local function load_base(bufnr)
	local st = state[bufnr]
	-- `file show` prints nothing for a path absent in BASE_REV (newly added
	-- file); treat that as an empty base so every line reads as added.
	st.base_lines = jj.run({ "file", "show", "-r", BASE_REV, st.relpath }, st.root) or {}
end

--- Map a vim.diff indices hunk to per-line sign placements.
--- @param ca integer count in base
--- @param sb integer start in buffer (0 when count is 0)
--- @param cb integer count in buffer
--- @param place fun(lnum: integer, kind: string)
local function hunk_signs(ca, sb, cb, place)
	if ca == 0 then
		-- Pure addition.
		for l = sb, sb + cb - 1 do
			place(l, "add")
		end
	elseif cb == 0 then
		-- Pure deletion: anchor on the line the removed text sat above.
		-- vim.diff reports sb as the preceding buffer line for deletions.
		place(math.max(sb, 1), sb == 0 and "topdelete" or "delete")
	else
		-- Change, possibly with a net add/delete of lines.
		local kind = cb < ca and "changedelete" or "change"
		for l = sb, sb + cb - 1 do
			place(l, kind)
		end
	end
end

--- Recompute and render signs for a buffer. Idempotent.
--- @param bufnr integer
local function render(bufnr)
	local st = state[bufnr]
	if not st or not api.nvim_buf_is_valid(bufnr) then
		return
	end

	api.nvim_buf_clear_namespace(bufnr, NS, 0, -1)

	local base = table.concat(st.base_lines, "\n")
	local buf = table.concat(api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
	local hunks = vim.diff(base .. "\n", buf .. "\n", { result_type = "indices" })
	--- @cast hunks integer[][]

	local line_count = api.nvim_buf_line_count(bufnr)
	local place = function(lnum, kind)
		if lnum < 1 or lnum > line_count then
			return
		end
		local sign = SIGNS[kind]
		api.nvim_buf_set_extmark(bufnr, NS, lnum - 1, 0, {
			sign_text = sign.text,
			sign_hl_group = sign.hl,
		})
	end

	for _, h in ipairs(hunks) do
		-- h = { start_base, count_base, start_buf, count_buf }
		hunk_signs(h[2], h[3], h[4], place)
	end
end

--- Debounced render driven by buffer edits.
--- @param bufnr integer
local function schedule_render(bufnr)
	local st = state[bufnr]
	if not st then
		return
	end
	if st.timer then
		st.timer:stop()
		st.timer:close()
	end
	st.timer = vim.defer_fn(function()
		st.timer = nil
		render(bufnr)
	end, DEBOUNCE_MS)
end

--- Attach to a buffer if it lives in a jj repo. Idempotent.
--- @param bufnr integer
function M.attach(bufnr)
	bufnr = bufnr or api.nvim_get_current_buf()
	if state[bufnr] or vim.bo[bufnr].buftype ~= "" then
		return
	end
	local path = api.nvim_buf_get_name(bufnr)
	if path == "" then
		return
	end

	local root = jj.root(vim.fs.dirname(path))
	if not root then
		return
	end

	state[bufnr] = {
		root = root,
		relpath = vim.fs.normalize(path):sub(#root + 2),
	}
	load_base(bufnr)
	render(bufnr)

	local group = api.nvim_create_augroup("jujutsu_gutter_buf_" .. bufnr, { clear = true })
	api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
		group = group,
		buffer = bufnr,
		callback = function()
			schedule_render(bufnr)
		end,
	})
	-- A write may move `@`, so re-read the base before re-rendering.
	api.nvim_create_autocmd("BufWritePost", {
		group = group,
		buffer = bufnr,
		callback = function()
			load_base(bufnr)
			render(bufnr)
		end,
	})
	api.nvim_create_autocmd({ "BufUnload", "BufDelete" }, {
		group = group,
		buffer = bufnr,
		callback = function()
			M.detach(bufnr)
		end,
	})
end

--- Detach and clean up a buffer.
--- @param bufnr integer
function M.detach(bufnr)
	local st = state[bufnr]
	if not st then
		return
	end
	if st.timer then
		st.timer:stop()
		st.timer:close()
	end
	if api.nvim_buf_is_valid(bufnr) then
		api.nvim_buf_clear_namespace(bufnr, NS, 0, -1)
	end
	pcall(api.nvim_del_augroup_by_name, "jujutsu_gutter_buf_" .. bufnr)
	state[bufnr] = nil
end

--- Auto-attach on buffer load, and attach any buffers already open.
function M.setup()
	api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
		group = api.nvim_create_augroup("jujutsu_gutter", { clear = true }),
		callback = function(ev)
			M.attach(ev.buf)
		end,
	})
	-- Buffers already open when setup runs (e.g. lazy-loaded plugin).
	for _, bufnr in ipairs(api.nvim_list_bufs()) do
		if api.nvim_buf_is_loaded(bufnr) then
			M.attach(bufnr)
		end
	end
end

return M
