local vim = vim
local lspconfig = require'lspconfig'
local M = {}

local on_attach = function()
  -- Auto-completion functionality from `hrsh7th/nvim-compe`
  -- This will setup with buffers attached with LSP clients.
  require'compe'.setup {
    source = {
      path = true;
      buffer = true;
      tags = true;
      spell = true;
      calc = true;
      omni = true;
      nvim_lsp = true;
      nvim_lua = true;
      vsnip = true;
      treesitter = true;
    };
  }
end

--- Rust Analyzer setup.
--`git clone https://github.com/rust-analyzer/rust-analyzer` and build!
--
-- Ref: https://github.com/rust-analyzer/rust-analyzer
M.rust_analyzer_setup = function()
  -- inlay hints for rust
  vim.api.nvim_exec([[
augroup RustInlayHint
  autocmd CursorHold,CursorHoldI *.rs silent lua require'lsp_extensions'.inlay_hints{ only_current_line = true, prefix = ' » ', highlight = "NonText" }
augroup END
  ]], false)

  -- LSP snippet. Ref: https://git.io/Jqf0c
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  lspconfig.rust_analyzer.setup{
    capabilities = capabilities,
    on_attach = on_attach,
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
    on_attach = on_attach
  }
end

--- gopls setup.
-- `GO111MODULE=on go get golang.org/x/tools/gopls@latest`
--
-- Ref: https://github.com/golang/tools/blob/master/gopls/README.md
M.gopls_setup = function()
  lspconfig.gopls.setup{ on_attach = on_attach }
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
      on_attach = on_attach,
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
-- https://github.com/neovim/nvim-lspconfig/blob/2258598/lua/lspconfig/sumneko_lua.lua#L26-L70
M.sumneko_lua_setup = function()
  local system_name
  if vim.fn.has("mac") == 1 then
    system_name = "macOS"
  elseif vim.fn.has("unix") == 1 then
    system_name = "Linux"
  elseif vim.fn.has('win32') == 1 then
    system_name = "Windows"
  else
    print("Unsupported system for sumneko")
  end
  local sumneko_root_path = vim.fn.expand('~')..'/wd/quick-dirty/lua-language-server'
  local sumneko_binary = sumneko_root_path..'/bin/'..system_name..'/lua-language-server'
  lspconfig.sumneko_lua.setup {
    on_attach = on_attach,
    cmd = {sumneko_binary, '-E', sumneko_root_path..'/main.lua'};
    settings = {
      Lua = {
        runtime = {
          version = 'LuaJIT',
          path = vim.split(package.path, ';'),
        },
        diagnostics = {
          globals = {'vim'},
        },
        workspace = {
          library = {
            [vim.fn.expand('$VIMRUNTIME/lua')] = true,
            [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
          },
        },
      },
    },
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
    on_attach = on_attach,
  }
end

--- Solargraph setup.
-- `gem install solargraph`
--
-- Ref: https://github.com/castwide/solargraph
M.solargraph_setup = function()
  lspconfig.solargraph.setup{
    on_attach = on_attach,
  }
end


--- OCaml-LSP setup.
-- `opam install ocaml-lsp-server`
--
-- Ref: https://github.com/ocaml/ocaml-lsp
M.ocamllsp_setup = function()
  lspconfig.ocamllsp.setup{
    on_attach = on_attach,
  }
end

M.variables_setup = function()
  -- Show virtual text for diagnoses
  vim.g.diagnostic_enable_virtual_text = 1
  -- Delay showing virtual text while inserting
  vim.g.diagnostic_insert_delay = 1
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
  map('n', '<f2>',                  '<cmd>LspRename<cr>', opts)
  -- Manually trigger completion on Ctrl-Space
  map('i', '<cr>',                  'compe#confirm("<cr>")', { noremap = true, silent = true, expr = true })
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
    autocmd FileType go,rust,ruby,python,javascript,typescript,lua,c,cpp,objc,objcpp,ocaml setlocal omnifunc=v:lua.vim.lsp.omnifunc
    autocmd CursorHold,CursorHoldI *.{go,rs,rb,py,js,jsx,ts,tsx,lua,c,h,cpp,hpp,ml} lua require'nvim-lightbulb'.update_lightbulb()
augroup END
  ]], false)
end

return M
