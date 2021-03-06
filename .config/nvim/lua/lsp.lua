-- Please put each language server under "$XDG_DATA_HOME/nvim/lss" directory,
-- which equals `vim.fn.stdpath('data')`.

local vim = vim
local lspconfig = require'lspconfig'
local M = {}
local lss_dir = vim.fn.stdpath('data') .. '/lss'

local function on_attach(client, bufnr)
  -- Auto-completion functionality from `hrsh7th/nvim-compe`
  -- This will setup with buffers attached with LSP clients.
  require'compe'.setup {
    preselect = 'disable',
    source = {
      path = true,
      buffer = true,
      tags = true,
      spell = false,
      calc = false,
      emoji = true,
      nvim_lsp = true,
      nvim_lua = true,
      vsnip = true,
    },
  }

  -- Vim commands setup
  vim.api.nvim_exec([[
    command! LspCodeAction       lua vim.lsp.buf.code_action()
    command! LspDeclaration      lua vim.lsp.buf.declaration()
    command! LspDefinition       lua vim.lsp.buf.definition()
    command! LspDocumentSymbol   lua vim.lsp.buf.document_symbol()
    command! LspHover            lua vim.lsp.buf.hover()
    command! LspImplementation   lua vim.lsp.buf.implementation()
    command! LspIncomingCalls    lua vim.lsp.buf.incoming_calls()
    command! LspOutgoingCalls    lua vim.lsp.buf.outgoing_calls()
    command! LspReferences       lua vim.lsp.buf.references()
    command! LspRename           lua vim.lsp.buf.rename()
    command! LspSignatureHelp    lua vim.lsp.buf.signature_help()
    command! LspTypeDefinition   lua vim.lsp.buf.type_definition()
    command! LspWorkspaceSymbol  lua vim.lsp.buf.workspace_symbol()
  ]], false)

  -- Vim keymaps setup
  local map = function(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local opts = { noremap = true, silent = true }
  map('n', '<c-]>',                 '<cmd>LspDefinition<cr>', opts)
  map('n', 'K',                     '<cmd>LspHover<cr>', opts)
  map('n', '<c-k>',                 '<cmd>LspSignatureHelp<cr>', opts)
  map('n', '<localleader><space>',  '<cmd>LspCodeAction<cr>', opts)
  map('n', '<f7>',                  '<cmd>LspReferences<cr>', opts)
  map('n', '<f2>',                  '<cmd>LspRename<cr>', opts)
  map('i', '<cr>',                  'compe#confirm("<cr>")', { noremap = true, silent = true, expr = true })
  map('n', ']e',                    '<cmd>lua vim.lsp.diagnostic.goto_next()<cr>', opts)
  map('n', '[e',                    '<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>', opts)
  map('n', '<localleader>e',        '<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>', opts)
  map('n', '<localleader>E',        '<cmd>lua vim.lsp.diagnostic.set_loclist({workspace = true})<cr>', opts)

  -- Vim options setup
  local opt = function(...) vim.api.nvim_buf_set_option(bufnr, ...) end
  opt('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Vim autocommands setup
  -- Show available code actions on sign column.
  vim.api.nvim_exec([[
    augroup LspAutoCommands
      autocmd! * <buffer>
      autocmd CursorHold,CursorHoldI <buffer> lua require'nvim-lightbulb'.update_lightbulb()
    augroup END
  ]], false)

  if client.resolved_capabilities.document_highlight then
    -- Highlight word under cursor.
    vim.api.nvim_exec([[
      augroup LspDocumentHighlight
        autocmd! * <buffer>
        autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
  end
end

--- Rust Analyzer setup.
--- `git clone https://github.com/rust-analyzer/rust-analyzer` and build!
---
--- Ref: https://github.com/rust-analyzer/rust-analyzer
local function rust_analyzer_setup()
  -- Inlay hints for rust
  function M.inlay_hints()
    require'lsp_extensions'.inlay_hints{
      only_current_line = true,
      prefix = ' » ',
      highlight = 'NonText',
      enabled = { 'TypeHint', 'ChainingHint', 'ParameterHint' },
    }
  end
  local function rust_on_attach(client, bufnr)
    vim.api.nvim_exec([[
      augroup RustInlayHint
        autocmd! * <buffer>
        autocmd CursorHold,CursorHoldI <buffer> silent lua require'lsp'.inlay_hints()
      augroup END
    ]], false)
    on_attach(client, bufnr)
  end

  -- LSP snippet. Ref: https://git.io/Jqf0c
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true

  lspconfig.rust_analyzer.setup{
    capabilities = capabilities,
    on_attach = rust_on_attach,
    settings = {
      ['rust-analyzer'] = {
        -- Default 128. Ref: https://git.io/JTczw
        lruCapacity = 512,
        procMacro = { enable = true },
        experimental = { procAttrMacros = true },
      }
    }
  }
end

--- TypeScript Language Server setup.
--- `npm i g typescript-language-server`
---
--- Ref: https://github.com/theia-ide/typescript-language-server
local function tsserver_setup()
  lspconfig.tsserver.setup{
    on_attach = on_attach
  }
end

--- gopls setup.
--- `GO111MODULE=on go get golang.org/x/tools/gopls@latest`
---
--- Ref: https://github.com/golang/tools/blob/master/gopls/README.md
local function gopls_setup()
  lspconfig.gopls.setup{ on_attach = on_attach }
end

--- Python Language Server setup.
--- `python3 -m pip install 'python-language-server[all]'`
---
--- Ref: https://github.com/palantir/python-language-server
local function pyls_setup()
  --- Asynchorounsly get python virtualenv path for current working directory.
  --- Currently support: `pipenv`, `poetry`.
  ---
  --- This is done by neovim job-control system. See `:h job-control`.
  local function get_python_venv_path(callback)
    local function on_event(_, data, event)
      if event == 'stdout' then
        -- Here are gibberish leading and trailing whitespace elements.
        callback(data[1])
      end
    end

    local cmd = ''
    local cwd = vim.fn.getcwd()
    local root = lspconfig.util.root_pattern('pyproject.toml')(cwd)
    if root then
      cmd = {'python', '-m', 'poetry', 'env', 'info', '-p'}
    end

    if root == '' or root == nil then
      root = lspconfig.util.root_pattern('Pipfile')(cwd)
      if root then
        cmd = {'python', '-m', 'pipenv', '--venv'}
      end
    end

    if root == '' or root == nil then
      callback('')
    end

    if cmd ~= '' then
      vim.fn.jobstart(
        cmd,
        {
          on_exit = on_event,
          on_stdout = on_event,
          on_stderr = on_event,
          stdout_buffered = true,
          stderr_buffered = true,
        }
      )
    end
  end

  get_python_venv_path(function(venv_path)
    local echo = vim.api.nvim_echo
    local settings = {
      pyls = {
        plugins = {
          jedi = { environment = vim.NIL }
        }
      }
    }
    lspconfig.pyls.setup{
      on_attach = on_attach,
      settings = settings,
    }
    if venv_path == '' or venv_path == nil then
      echo({{'[LSP] Python venv not found', 'WarningMsg'}}, true, {})
    else
      echo({{'[LSP] set Python virtualenv at '..venv_path, 'WarningMsg'}}, true, {})
      settings.pyls.plugins.jedi = { environment = venv_path }
    end
  end)
end

--- lua-language-server setup.
--- `git clone https://github.com/sumneko/lua-language-server` and build!
---
--- Ref: https://github.com/sumneko/lua-language-server/wiki/Build-and-Run-(Standalone)
--- https://github.com/neovim/nvim-lspconfig/blob/2258598/lua/lspconfig/sumneko_lua.lua#L26-L70
local function sumneko_lua_setup()
  local sys
  if vim.fn.has("mac") == 1 then
    sys = "macOS"
  elseif vim.fn.has("unix") == 1 then
    sys = "Linux"
  elseif vim.fn.has('win32') == 1 then
    sys = "Windows"
  else
    print("Unsupported system for sumneko")
  end
  local sumneko_root_path = lss_dir .. '/lua-language-server'
  local sumneko_binary = sumneko_root_path .. '/bin/' .. sys .. '/lua-language-server'
  lspconfig.sumneko_lua.setup {
    on_attach = on_attach,
    cmd = {sumneko_binary, '-E', sumneko_root_path .. '/main.lua'};
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
--- Installation guide [1].
--- Note that clangd relies on a JSON compilation database[2].
---
--- [1]: https://clangd.llvm.org/installation.html
--- [2]: https://clang.llvm.org/docs/JSONCompilationDatabase.html
local function clangd_setup()
  lspconfig.clangd.setup{
    on_attach = on_attach,
  }
end

--- Solargraph setup.
--- `gem install solargraph`
---
--- Ref: https://github.com/castwide/solargraph
 local function solargraph_setup()
  lspconfig.solargraph.setup{
    on_attach = on_attach,
  }
end


--- OCaml-LSP setup.
--- `opam install ocaml-lsp-server`
---
--- Ref: https://github.com/ocaml/ocaml-lsp
local function ocamllsp_setup()
  lspconfig.ocamllsp.setup{
    on_attach = on_attach,
  }
end

--- ElixirLS setup.
---
--- ```
--- git clone https://github.com/elixir-lsp/elixir-ls.git`
--- mix compile
--- mix elixir_ls.release
--- ```
---
--- Ref: https://github.com/elixir-lsp/elixir-ls
local function elixirls_setup()
  local ext
  if vim.fn.has("mac") == 1 or vim.fn.has("unix") == 1 then
    ext = "sh"
  elseif vim.fn.has('win32') == 1 then
      ext = "bat"
  else
    print("Unsupported system for elixirls")
  end

  local elixirls_root_path =  lss_dir .. '/elixir-ls'
  local elixirls_binary = elixirls_root_path .. '/release/language_server.' .. ext
  lspconfig.elixirls.setup{
    on_attach = on_attach,
    cmd = {elixirls_binary}
  }
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
  tsserver_setup()
  pyls_setup()
  sumneko_lua_setup()
  clangd_setup()
  solargraph_setup()
  ocamllsp_setup()
  elixirls_setup()
end

return M
