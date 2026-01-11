-- Please put each language server under "$XDG_DATA_HOME/nvim/lss" directory,
-- which equals `vim.fn.stdpath('data')`.

local vim = vim
local lspconfig = require("lspconfig")
local M = {}
local lss_dir = vim.fn.stdpath("data") .. "/lss"

--- Auto-completion capabilities from `hrsh7th/nvim-cmp`
local function make_capabilities()
	return require("cmp_nvim_lsp").default_capabilities({
		-- disable snippet since we do not choose any snippet engine yet
		snippetSupport = false,
	})
end

local function on_attach(client, bufnr)
	-- Vim commands setup
	vim.api.nvim_exec(
		[[
    command! LspCodeAction       lua vim.lsp.buf.code_action()
    command! LspDeclaration      lua vim.lsp.buf.declaration()
    command! LspDefinition       lua vim.lsp.buf.definition()
    command! LspDocumentSymbol   lua vim.lsp.buf.document_symbol()
    command! LspHover            lua vim.lsp.buf.hover({ border = 'rounded' })
    command! LspImplementation   lua vim.lsp.buf.implementation()
    command! LspIncomingCalls    lua vim.lsp.buf.incoming_calls()
    command! LspOutgoingCalls    lua vim.lsp.buf.outgoing_calls()
    command! LspReferences       lua vim.lsp.buf.references()
    command! LspRename           lua vim.lsp.buf.rename()
    command! LspSignatureHelp    lua vim.lsp.buf.signature_help({ border = 'rounded' })
    command! LspTypeDefinition   lua vim.lsp.buf.type_definition()
    command! LspWorkspaceSymbol  lua vim.lsp.buf.workspace_symbol()
  ]],
		false
	)

	-- Vim keymaps setup
	local map = function(...)
		vim.api.nvim_buf_set_keymap(bufnr, ...)
	end
	local opts = { noremap = true, silent = true }
	map("n", "<c-]>", "<cmd>Telescope lsp_definitions<cr>", opts)
	map("n", "K", "<cmd>LspHover<cr>", opts)
	map("n", "<c-k>", "<cmd>LspSignatureHelp<cr>", opts)
	map("n", "<localleader><space>", "<cmd>LspCodeAction<cr>", opts)
	map("n", "<f7>", "<cmd>Telescope lsp_references<cr>", opts)
	map("n", "<f2>", "<cmd>LspRename<cr>", opts)
	map("n", "]e", "<cmd>lua vim.diagnostic.goto_next()<cr>", opts)
	map("n", "[e", "<cmd>lua vim.diagnostic.goto_prev()<cr>", opts)
	map("n", "<localleader>e", "<cmd>Telescope diagnostics bufnr=0<cr>", opts)
	map("n", "<localleader>E", "<cmd>Telescope diagnostics<cr>", opts)

	-- Vim options setup (Obsolete. Temporarily replaced by nvim-cmp)
	-- local opt = function(...) vim.api.nvim_buf_set_option(bufnr, ...) end
	-- opt('omnifunc', 'v:lua.vim.lsp.omnifunc')

	-- Vim autocommands setup
	-- Show available code actions on sign column.
	vim.api.nvim_exec(
		[[
    augroup LspAutoCommands
      autocmd! * <buffer>
      autocmd CursorHold,CursorHoldI <buffer> lua require'nvim-lightbulb'.update_lightbulb()
    augroup END
  ]],
		false
	)

	if client.server_capabilities.documentHighlightProvider then
		-- Highlight word under cursor.
		vim.api.nvim_exec(
			[[
      augroup LspDocumentHighlight
        autocmd! * <buffer>
        autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]],
			false
		)
	end
end

--- Rust Analyzer setup.
--- `git clone https://github.com/rust-analyzer/rust-analyzer` and build!
---
--- Ref: https://github.com/rust-analyzer/rust-analyzer
local function rust_analyzer_setup()
	vim.lsp.config("rust_analyzer", {
		capabilities = make_capabilities(),
		on_attach = on_attach,
		settings = {
			["rust-analyzer"] = {
				-- Default 128. Ref: https://git.io/JTczw
				lru = {
					capacity = 512,
				},
				rustc = {
					source = "discover",
				},
				server = {
					extraEnv = {
						RA_LOG = "info",
					},
				},
			},
		},
		single_file_support = true,
	})
	vim.lsp.enable("rust_analyzer")
end

--- TypeScript Language Server setup.
--- `npm install -g typescript typescript-language-server`
---
--- Ref: https://github.com/typescript-language-server/typescript-language-server
local function ts_ls_setup()
	vim.lsp.config("ts_ls", {
		capabilities = make_capabilities(),
		on_attach = on_attach,
	})
	vim.lsp.enable("ts_ls")
end

--- gopls setup.
--- `GO111MODULE=on go get golang.org/x/tools/gopls@latest`
---
--- Ref: https://github.com/golang/tools/blob/master/gopls/README.md
local function gopls_setup()
	vim.lsp.config("gopls", {
		capabilities = make_capabilities(),
		on_attach = on_attach,
	})
	vim.lsp.enable("gopls")
end

--- Python Language Server setup.
--- `python3 -m pipx install 'python-lsp-server[all]'`
---
--- Ref: https://github.com/python-lsp/python-lsp-server
local function pylsp_setup()
	--- Get python virtualenv path for current working directory.
	--- Currently support: `pipenv`, `poetry`.
	---
	--- Thanks to `on_new_config`, this is only executed when the project root
	--- matching patterns of pylsp.
	---
	--- This is done by neovim job-control system. See `:h job-control`.
	local function get_python_venv_path()
		local cmd = nil
		local cwd = vim.fn.getcwd()
		if lspconfig.util.root_pattern("pyproject.toml")(cwd) then
			cmd = { "poetry", "env", "info", "-p" }
		end
		if cmd == nil then
			if lspconfig.util.root_pattern("Pipfile")(cwd) then
				cmd = { "pipenv", "--venv" }
			end
		end
		if cmd == nil then
			vim.notify("[LSP] Not a poetry or pipenv project", vim.log.levels.INFO)
			return ""
		end

		local cmd_out = ""
		local cmd_err = ""
		local job_id = vim.fn.jobstart(cmd, {
			on_stdout = function(_, d, _)
				cmd_out = d
			end,
			on_stderr = function(_, d, _)
				cmd_err = d
			end,
			stdout_buffered = true,
			stderr_buffered = true,
		})
		local exit_code = 0
		if job_id > 0 then
			exit_code = vim.fn.jobwait({ job_id }, 5000)[1] -- wait for 5 seconds
		end
		if exit_code > 0 then
			vim.notify(
				string.format(
					"[LSP] Failed to detect python venv\ncmd: `%q`\nerr: %s",
					table.concat(cmd, " "),
					table.concat(cmd_err, "\n")
				),
				vim.log.levels.WARN
			)
			return ""
		end

		local venv_path = cmd_out[1]
		vim.notify("[LSP] Set python venv at:\n" .. venv_path, vim.log.levels.INFO)
		return venv_path
	end

	local function on_new_config(config, _)
		local venv_path = get_python_venv_path()
		if venv_path ~= nil and venv_path ~= "" then
			config.settings.pylsp.plugins.jedi = { environment = venv_path }
		end
	end

	local settings = { pylsp = { plugins = { jedi = { environment = vim.NIL } } } }

	vim.lsp.config("pylsp", {
		capabilities = make_capabilities(),
		on_attach = on_attach,
		settings = settings,
		on_new_config = on_new_config,
	})
	vim.lsp.enable("pylsp")
end

--- lua-language-server setup.
--- `git clone https://github.com/LuaLS/lua-language-server` and build!
---
--- Ref: https://github.com/LuaLS/lua-language-server/wiki/Getting-Started
local function lua_ls_setup()
	vim.lsp.config("lua_ls", {
		capabilities = make_capabilities(),
		on_attach = on_attach,
		settings = {
			Lua = {
				runtime = {
					version = "LuaJIT",
				},
				diagnostics = {
					globals = { "vim" },
				},
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true),
				},
				telemetry = {
					enable = false,
				},
			},
		},
	})
	vim.lsp.enable("lua_ls")
end

--- cland setup.
--- Installation guide [1].
--- Note that clangd relies on a JSON compilation database[2].
---
--- [1]: https://clangd.llvm.org/installation.html
--- [2]: https://clang.llvm.org/docs/JSONCompilationDatabase.html
local function clangd_setup()
	vim.lsp.config("clangd", {
		capabilities = make_capabilities(),
		on_attach = on_attach,
	})
	vim.lsp.enable("clangd")
end

--- Setup all language servers from above configurations.
M.setup = function()
	-- Show virtual text for diagnoses
	vim.g.diagnostic_enable_virtual_text = 1
	-- Delay showing virtual text while inserting
	vim.g.diagnostic_insert_delay = 1

	-- Language servers setup
	rust_analyzer_setup()
	gopls_setup()
	ts_ls_setup()
	pylsp_setup()
	lua_ls_setup()
	clangd_setup()
end

return M
