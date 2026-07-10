--- Gutter signs and hunk motions for uncommitted jj changes, in the spirit
--- of gitsigns.nvim. Attached buffers get `]c`/`[c` mapped to next/prev hunk,
--- matching the gitsigns mappings so muscle memory carries over.
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

-- Glyphs match the gitsigns config in plugins.lua for a consistent gutter.
-- Highlights link to `GitSigns*` groups, which catppuccin themes.
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

--- Diff the live buffer against the BASE_REV snapshot.
--- @param bufnr integer
--- @return integer[][] hunks vim.diff indices quadruples, ascending by line
local function compute_hunks(bufnr)
	local st = state[bufnr]
	local base = table.concat(st.base_lines, "\n")
	local buf = table.concat(api.nvim_buf_get_lines(bufnr, 0, -1, false), "\n")
	local hunks = vim.diff(base .. "\n", buf .. "\n", { result_type = "indices" })
	--- @cast hunks integer[][]
	return hunks
end

--- Recompute and render signs for a buffer. Idempotent.
--- @param bufnr integer
local function render(bufnr)
	local st = state[bufnr]
	if not st or not api.nvim_buf_is_valid(bufnr) then
		return
	end

	api.nvim_buf_clear_namespace(bufnr, NS, 0, -1)

	local hunks = compute_hunks(bufnr)
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

--- Buffer-line span occupied by a hunk. A pure deletion has no buffer lines;
--- it collapses to the anchor line its sign is drawn on.
--- @param h integer[] vim.diff indices quadruple
--- @return integer start, integer fin
local function hunk_span(h)
	local sb, cb = h[3], h[4]
	if cb == 0 then
		local anchor = math.max(sb, 1)
		return anchor, anchor
	end
	return sb, sb + cb - 1
end

--- Index of the hunk to land on from lnum, or nil when out of hunks and
--- 'wrapscan' is off. Same wrap semantics as gitsigns and `n`/`N`.
--- @param hunks integer[][]
--- @param lnum integer
--- @param direction "next"|"prev"
--- @return integer?
local function find_nearest(hunks, lnum, direction)
	if direction == "next" then
		for i, h in ipairs(hunks) do
			if hunk_span(h) > lnum then
				return i
			end
		end
	else
		for i = #hunks, 1, -1 do
			local _, fin = hunk_span(hunks[i])
			if fin < lnum then
				return i
			end
		end
	end
	if vim.o.wrapscan then
		return direction == "next" and 1 or #hunks
	end
end

--- Transient statusline message; unlike jj.warn it leaves no notify history,
--- fitting a motion that may fire many times in a row.
--- @param msg string
--- @param hl string
local function echo(msg, hl)
	api.nvim_echo({ { msg, hl } }, false, {})
end

--- Jump the cursor to the start of the next/previous hunk, v:count1 times,
--- wrapping per 'wrapscan'. The builtin `[c`/`]c` land on hunk starts in both
--- directions, so we do too (gitsigns lands on the end when going back).
--- @param direction "next"|"prev"
function M.nav_hunk(direction)
	local bufnr = api.nvim_get_current_buf()
	if not state[bufnr] then
		return
	end

	-- Recompute rather than reuse render()'s result: renders are debounced,
	-- so anything cached may lag the buffer by up to DEBOUNCE_MS of edits.
	local hunks = compute_hunks(bufnr)
	if #hunks == 0 then
		return echo("No hunks", "WarningMsg")
	end

	local lnum = api.nvim_win_get_cursor(0)[1]
	local index
	for _ = 1, vim.v.count1 do
		index = find_nearest(hunks, lnum, direction)
		if not index then
			return echo("No more hunks", "WarningMsg")
		end
		lnum = hunk_span(hunks[index])
	end

	vim.cmd("normal! m'") -- record the jump for <C-o>
	api.nvim_win_set_cursor(0, { lnum, 0 })
	echo(("Hunk %d of %d"):format(index, #hunks), "None")
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

	-- Hunk motions, mirroring the gitsigns mappings in plugins.lua (which bow
	-- out in jj repos). In a diff window the builtin motion is the right thing,
	-- per the gitsigns README recipe.
	for lhs, dir in pairs({ ["]c"] = "next", ["[c"] = "prev" }) do
		vim.keymap.set("n", lhs, function()
			if vim.wo.diff then
				vim.cmd.normal({ vim.v.count1 .. lhs, bang = true })
			else
				M.nav_hunk(dir)
			end
		end, { buffer = bufnr, desc = "jujutsu: " .. dir .. " hunk" })
	end

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
		for _, lhs in ipairs({ "]c", "[c" }) do
			pcall(vim.keymap.del, "n", lhs, { buffer = bufnr })
		end
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
