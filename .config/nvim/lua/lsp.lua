local vim = vim
local lspconfig = require'lspconfig'
local M = {}

local make_on_attach = function(comp)
  return function(client)
    -- Auto-completion functionality from `nvim-lua/completion-nvim`
    require'completion'.on_attach(comp)
    -- Auto-highlighting symbols under the cursor from `RRethy/vim-illuminate`
    require'illuminate'.on_attach(client)
  end
end

--- Rust Analyzer setup.
--`git clone https://github.com/rust-analyzer/rust-analyzer` and build!
--
-- Ref: https://github.com/rust-analyzer/rust-analyzer
M.rust_analyzer_setup = function()
  -- inlay hints for rust
  vim.api.nvim_exec([[
augroup RustInlayHinto
  autocmd CursorHold,CursorHoldI *.rs silent lua require'lsp_extensions'.inlay_hints{ only_current_line = true, prefix = ' » ', highlight = "NonText" }
augroup END
  ]], false)
  lspconfig.rust_analyzer.setup{
    on_attach = make_on_attach(),
    settings = {
      ['rust-analyzer'] = {
        -- Default 128. Ref: https://git.io/JTczw
        lruCapacity = 512
      }
    }
  }
end

--- TypeScript Language Server setup.
-- `npm i g typescript-language-server`
--
-- Ref: https://github.com/theia-ide/typescript-language-server
M.tsserver_setup = function()
  lspconfig.tsserver.setup{
    on_attach = make_on_attach({ sorting = 'alphabet' })
  }
end

--- gopls setup.
-- `GO111MODULE=on go get golang.org/x/tools/gopls@latest`
--
-- Ref: https://github.com/golang/tools/blob/master/gopls/README.md
M.gopls_setup = function()
  lspconfig.gopls.setup{ on_attach = make_on_attach() }
end

--- Asynchorounsly get python virtualenv path for current working directory.
-- Currently support: `pipenv`.
--
-- This is done by neovim job-control system. See `:h job-control`.
local get_python_venv_path = function(callback)
  local on_event = function(_, data, event)
    if event == 'stdout' then
      -- Here are gibberish leading and trailing whitespace elements.
      callback(data[1])
    end
  end
  vim.fn.jobstart(
    'python -m pipenv --venv',
    {
      on_exit = on_event,
      on_stdout = on_event,
      on_stderr = on_event,
      stdout_buffered = true,
      stderr_buffered = true,
    }
  )
end

--- Python Language Server setup.
-- `python3 -m pip install 'python-language-server[all]'`
--
-- Ref: https://github.com/palantir/python-language-server
M.pyls_setup = function()
  get_python_venv_path(function(venv_path)
    lspconfig.pyls.setup{
      on_attach = make_on_attach(),
      settings = {
        pyls = {
          plugins = {
            jedi = {
              environment = venv_path
            }
          }
        }
      }
    }
  end)
end

--- lua-language-server setup.
-- `git clone https://github.com/sumneko/lua-language-server` and build!
--
-- Ref: https://github.com/sumneko/lua-language-server/wiki/Build-and-Run-(Standalone)
M.sumneko_lua_setup = function()
  lspconfig.sumneko_lua.setup{
    on_attach = make_on_attach(),
  }
end

--- cland setup.
-- Installation guide [1].
-- Note that clangd relies on a JSON compilation database[2].
--
-- [1]: https://clangd.llvm.org/installation.html
-- [2]: https://clang.llvm.org/docs/JSONCompilationDatabase.html
M.clangd_setup = function()
  lspconfig.clangd.setup{
    on_attach = make_on_attach(),
  }
end

--- Solargraph setup.
-- `gem install solargraph`
--
-- Ref: https://github.com/castwide/solargraph
M.solargraph_setup = function()
  lspconfig.solargraph.setup{
    on_attach = make_on_attach(),
  }
end


--- OCaml-LSP setup.
-- `opam install ocaml-lsp-server`
--
-- Ref: https://github.com/ocaml/ocaml-lsp
M.ocamllsp_setup = function()
  lspconfig.ocamllsp.setup{
    on_attach = make_on_attach(),
  }
end

M.variables_setup = function()
  -- Show virtual text for diagnoses
  vim.g.diagnostic_enable_virtual_text = 1
  -- Delay showing virtual text while inserting
  vim.g.diagnostic_insert_delay = 1
  -- Support snippets completions
  vim.g.completion_sorting = 'none'
  vim.g.completion_auto_change_source = 1
  vim.g.completion_enable_fuzzy_match = 1
  vim.g.completion_matching_strategy_list = {'exact', 'substring'}
  vim.g.completion_abbr_length = 50
  vim.g.completion_menu_length = 30
  -- CompletionItemKind from https://bit.ly/343efwm
  -- 100 -> none
  -- 90 -> property
  -- 80 -> declaration
  -- 70 -> variables/values, keywords
  -- 50 -> Snips
  -- 40 -> misc.
  vim.g.completion_items_priority = {
    Mtd = 90,
    Fd = 90,
    Cls = 80,
    E = 80,
    S = 80,
    Evt = 80,
    Fn = 80,
    I = 80,
    Mod = 80,
    TyPar = 80,
    Var = 70,
    Val = 70,
    Kw = 70,
    Cnst = 70,
    Op = 70,
    Snip = 50,
    Ref = 40,
    Text = 0,
  }
  vim.g.completion_customize_lsp_label = {
    Buffers = 'Buf',
    Class = 'Cls',
    Color = 'Clr',
    Constant = 'Cnst',
    Constructor = 'Fn',
    Enum = 'E',
    EnumMember = 'E',
    Event = 'Evt',
    Field = 'Fd',
    File = 'File',
    Folder = 'Dir',
    Function = 'Fn',
    Interface = 'I',
    Keyword = 'Kw',
    Method = 'Mtd',
    Module = 'Mod',
    Operator = 'Op',
    Property = 'Fd',
    Reference = 'Ref',
    Snippet = 'Snip',
    Struct = 'S',
    Text = 'Text',
    TypeParameter = 'TyPar',
    Unit = 'E',
    Value = 'Val',
    Variable = 'Var',
  }
end

--- Vim keymaps setup
M.keymaps_setup = function()
  local map = vim.api.nvim_set_keymap
  local opts = { noremap = true, silent = true }
  map('n', '<c-]>',                 '<cmd>LspDefinition<cr>', opts)
  map('n', 'K',                     '<cmd>LspHover<cr>', opts)
  map('n', '<c-k>',                 '<cmd>LspSignatureHelp<cr>', opts)
  map('n', '<LocalLeader><space>',  '<cmd>LspCodeAction<cr>', opts)
  map('n', '<f12>',                 '<cmd>LspReferences<cr>', opts)
  -- NOTE: Rename sometimes malfunctions. Use at your own risk.
  map('n', '<f2>',                  '<cmd>LspRename<cr>', opts)
  -- Manually trigger completion on Ctrl-Space
  map('i', '<c-space>',             '<plug>(completion_trigger)', {silent = true})
  -- Jump between diagnostics.
  map('n', ']e',                    '<cmd>lua vim.lsp.diagnostic.goto_next()<cr>', opts)
  map('n', '[e',                    '<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>', opts)
end

--- Vim commands setup
M.commands_setup = function()
  vim.api.nvim_exec([[
function! LspRestart(force) abort
lua << EOF
    if not vim.lsp.buf.server_ready() or vim.fn.nvim_eval('a:force') then
        vim.lsp.stop_client(vim.lsp.get_active_clients())
    end
EOF
    edit
endfunction

command! LspCodeAction       lua vim.lsp.buf.code_action()
command! LspDeclaration      lua vim.lsp.buf.declaration()
command! LspDefinition       lua vim.lsp.buf.definition()
command! LspDocumentSymbol   lua vim.lsp.buf.document_symbol()
command! LspHover            lua vim.lsp.buf.hover()
command! LspImplementation   lua vim.lsp.buf.implementation()
command! LspIncomingCalls    lua vim.lsp.buf.incoming_calls()
command! LspInfo             lua print(vim.inspect(vim.lsp.buf_get_clients()))
command! LspOutgoingCalls    lua vim.lsp.buf.outgoing_calls()
command! LspReferences       lua vim.lsp.buf.references()
command! LspRename           lua vim.lsp.buf.rename()
command! -bang LspRestart    call LspRestart(<bang>0)
command! LspServerReady      lua print(vim.lsp.buf.server_ready())
command! LspSignatureHelp    lua vim.lsp.buf.signature_help()
command! LspTypeDefinition   lua vim.lsp.buf.type_definition()
command! LspWorkspaceSymbol  lua vim.lsp.buf.workspace_symbol()
  ]], false)
end

--- Setup all language servers from above configurations.
M.setup = function()
  M.variables_setup()
  M.commands_setup()
  M.keymaps_setup()
  M.rust_analyzer_setup()
  M.gopls_setup()
  M.tsserver_setup()
  M.pyls_setup()
  M.sumneko_lua_setup()
  M.clangd_setup()
  M.solargraph_setup()
  M.ocamllsp_setup()

  -- * List all filetype that is enabled omnifunc with lsp.
  -- * Show light bulb if any code action available.
  vim.api.nvim_exec([[
augroup LspAutoCommands
    autocmd!
    autocmd FileType go,rust,python,javascript,typescript,lua,c,cpp,objc,objcpp setlocal omnifunc=v:lua.vim.lsp.omnifunc
    autocmd CursorHold,CursorHoldI * lua require'nvim-lightbulb'.update_lightbulb()
augroup END
  ]], false)
end

return M
