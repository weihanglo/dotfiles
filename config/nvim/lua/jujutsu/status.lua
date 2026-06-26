--- Working-copy status picker, in the spirit of `:Telescope git_status`.
---
--- Surface:
---   :JJ status  Telescope picker of files changed in the working copy (`@`),
---               <CR> opens the file.
---
--- Design axioms (keep these when editing):
---   * Read-only: status never mutates the repo (jj.run uses
---     `--ignore-working-copy`).
---   * Status is parsed from `jj diff --summary`, whose leading letter is the
---     change kind; the rest of the line is the repo-relative path.

local jj = require("jujutsu.jj")

local M = {}

-- `jj diff --summary` prefixes each path with a single-letter kind. Map those
-- to the highlight groups Telescope/gitsigns already theme.
local KIND_HL = {
	M = "GitSignsChange",
	A = "GitSignsAdd",
	D = "GitSignsDelete",
	R = "GitSignsChange",
	C = "GitSignsAdd",
}

--- Changed files in the working copy, as picker entries.
--- @param root string repo root
--- @return { kind: string, path: string, abspath: string }[]?
local function changes(root)
	local out = jj.run({ "diff", "--summary" }, root)
	if not out then
		return nil
	end
	local entries = {}
	for _, line in ipairs(out) do
		-- "M path/to/file" — kind letter, a space, then the path (which may
		-- itself contain spaces, so match only the single leading letter).
		local kind, path = line:match("^(%a)%s+(.*)$")
		if kind then
			entries[#entries + 1] = {
				kind = kind,
				path = path,
				abspath = root .. "/" .. path,
			}
		end
	end
	return entries
end

--- Open the Telescope picker over working-copy changes.
function M.status()
	local path = vim.api.nvim_buf_get_name(0)
	local dir = path ~= "" and vim.fs.dirname(path) or vim.fn.getcwd()
	local root = jj.root(dir)
	if not root then
		return jj.warn("not in a jj repo")
	end

	local entries = changes(root)
	if not entries then
		return jj.error("status failed")
	end
	if #entries == 0 then
		return jj.info("working copy has no changes")
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")
	local entry_display = require("telescope.pickers.entry_display")
	local previewers = require("telescope.previewers")
	local putils = require("telescope.previewers.utils")

	local displayer = entry_display.create({
		separator = " ",
		items = { { width = 1 }, { remaining = true } },
	})

	-- Preview the per-file `jj diff`, highlighted as `diff`.
	local previewer = previewers.new_buffer_previewer({
		title = "jj diff",
		get_buffer_by_name = function(_, entry)
			return entry.value.path
		end,
		define_preview = function(self, entry)
			putils.job_maker(
				{ "jj", "--no-pager", "--color=never", "--ignore-working-copy", "diff", "--", entry.value.path },
				self.state.bufnr,
				{
					value = entry.value.path,
					bufname = self.state.bufname,
					cwd = root,
					callback = function(bufnr)
						if vim.api.nvim_buf_is_valid(bufnr) then
							putils.highlighter(bufnr, "diff", {})
						end
					end,
				}
			)
		end,
	})

	pickers
		.new({}, {
			prompt_title = "jj status",
			finder = finders.new_table({
				results = entries,
				entry_maker = function(e)
					return {
						value = e,
						ordinal = e.path,
						path = e.abspath,
						display = function(entry)
							return displayer({
								{ entry.value.kind, KIND_HL[entry.value.kind] or "Normal" },
								entry.value.path,
							})
						end,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			previewer = previewer,
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection then
						vim.cmd.edit(vim.fn.fnameescape(selection.path))
					end
				end)
				return true
			end,
		})
		:find()
end

return M
