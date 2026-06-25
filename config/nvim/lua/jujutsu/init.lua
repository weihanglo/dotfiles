--- jujutsu.nvim — minimal Jujutsu (jj) integration for Neovim.
---
--- The orchestrator: it owns the `:JJ <subcommand>` command surface (in the
--- spirit of the builtin `:lsp <subcommand>`) and dispatches to the feature
--- modules, each of which owns its own logic, state, and autocmds:
---
---   * jujutsu.jj      — the only place that shells out to the `jj` CLI
---   * jujutsu.gutter  — uncommitted-change signs in the sign column
---   * jujutsu.blame   — `jj file annotate` line/file blame
---   * jujutsu.status  — working-copy change picker
---   * jujutsu.link    — GitHub permalink for the current line(s)
---   * jujutsu.ui      — launch the jjui terminal UI
---
--- To add a new `:JJ` subcommand, add an entry to `subcommands` below; to add a
--- feature with autocmds/signs, give it a setup() and call it in M.setup().

local M = {}

--- `:JJ <name>` subcommands. Each handler receives the command argument table,
--- so range-aware subcommands can read opts.line1/opts.line2. This table is the
--- single place to register a new subcommand. Modules are required on demand to
--- keep them off the startup path.
local subcommands = {
	status = function()
		require("jujutsu.status").status()
	end,
	blame = function()
		require("jujutsu.blame").blame_file()
	end,
	blameline = function()
		require("jujutsu.blame").toggle_current_line()
	end,
	link = function(opts)
		-- `:'<,'>JJ link` exits visual mode before running, so the selection is
		-- gone; read the range the command captured. line1/line2 default to the
		-- cursor line when no range is given.
		require("jujutsu.link").link(opts.line1, opts.line2)
	end,
	ui = function()
		require("jujutsu.ui").open()
	end,
}

--- Run `:JJ <subcommand>`, reporting an unknown or missing name.
--- @param opts table the nvim_create_user_command argument table
local function dispatch(opts)
	local name = opts.fargs[1]
	local handler = name and subcommands[name]
	if not handler then
		require("jujutsu.jj").error("unknown subcommand: " .. (name or "(none given)"))
		return
	end
	handler(opts)
end

--- Complete subcommand names for `:JJ <Tab>`.
--- @param arglead string the partial word being completed
--- @return string[]
local function complete(arglead)
	local names = vim.tbl_keys(subcommands)
	table.sort(names)
	return vim.tbl_filter(function(name)
		return vim.startswith(name, arglead)
	end, names)
end

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
	require("jujutsu.ui").setup()

	vim.api.nvim_create_user_command("JJ", dispatch, {
		nargs = "*",
		range = true,
		complete = complete,
		desc = "jujutsu: <status|blame|blameline|link|ui>",
	})
end

return M
