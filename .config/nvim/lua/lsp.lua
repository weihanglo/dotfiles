-- Please put each language server under "$XDG_DATA_HOME/nvim/lss" directory,
-- which equals `vim.fn.stdpath('data')`.

local vim = vim
local lspconfig = require'lspconfig'
local M = {}
local lss_dir = vim.fn.stdpath('data') .. '/lss'

--- Auto-completion capabilities from `hrsh7th/nvim-cmp`
local function make_capabilities()
  return require('cmp_nvim_lsp').update_capabilities(
    vim.lsp.protocol.make_client_capabilities(),
    {
      -- disable snippet since we do not choose any snippet engine yet
      snippetSupport = false,
    }
  )
end

local function on_attach(client, bufnr)
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
  map('n', '<c-]>',                 '<cmd>Telescope lsp_definitions<cr>', opts)
  map('n', 'K',                     '<cmd>LspHover<cr>', opts)
  map('n', '<c-k>',                 '<cmd>LspSignatureHelp<cr>', opts)
  map('n', '<localleader><space>',  '<cmd>Telescope lsp_code_actions theme=get_cursor<cr>', opts)
  map('n', '<f7>',                  '<cmd>LspReferences<cr>', opts)
  map('n', '<f2>',                  '<cmd>LspRename<cr>', opts)
  map('n', ']e',                    '<cmd>lua vim.lsp.diagnostic.goto_next()<cr>', opts)
  map('n', '[e',                    '<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>', opts)
  map('n', '<localleader>e',        '<cmd>Telescope lsp_document_diagnostics<cr>', opts)
  map('n', '<localleader>E',        '<cmd>Telescope lsp_workspace_diagnostics<cr>', opts)

  -- Vim options setup (Obsolete. Temporarily replaced by nvim-cmp)
  -- local opt = function(...) vim.api.nvim_buf_set_option(bufnr, ...) end
  -- opt('omnifunc', 'v:lua.vim.lsp.omnifunc')

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

  lspconfig.rust_analyzer.setup{
    capabilities = make_capabilities(),
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
    capabilities = make_capabilities(),
    on_attach = on_attach,
  }
end

--- gopls setup.
--- `GO111MODULE=on go get golang.org/x/tools/gopls@latest`
---
--- Ref: https://github.com/golang/tools/blob/master/gopls/README.md
local function gopls_setup()
  lspconfig.gopls.setup{
    capabilities = make_capabilities(),
    on_attach = on_attach,
  }
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
  local function get_python_venv_path()
    local cmd = nil
    local cwd = vim.fn.getcwd()
    if lspconfig.util.root_pattern('pyproject.toml')(cwd) then
      cmd = {'poetry', 'env', 'info', '-p'}
    end
    if cmd == nil then
      if lspconfig.util.root_pattern('Pipfile')(cwd) then
        cmd = {'pipenv', '--venv'}
      end
    end
    if cmd == nil then
      return ''
    end

    local venv_path = vim.fn.systemlist(cmd)[1]
    if vim.v.shell_error ~= 0 then
      return ''
    end

    return venv_path
  end

  local function on_new_config(config, _)
      local venv_path = get_python_venv_path()
      if venv_path == '' or venv_path == nil then
        vim.notify('[LSP] Python venv not found', vim.log.levels.WARN)
      else
        vim.notify('[LSP] set Python virtualenv at '..venv_path, vim.log.levels.INFO)
        config.settings.pylsp.plugins.jedi = { environment = venv_path }
      end
  end

  local settings = { pylsp = { plugins = { jedi = { environment = vim.NIL } } } }

  lspconfig.pylsp.setup{
    capabilities = make_capabilities(),
    on_attach = on_attach,
    settings = settings,
    on_new_config = on_new_config,
  }
end

--- lua-language-server setup.
--- `git clone https://github.com/sumneko/lua-language-server` and build!
---
--- Ref: https://github.com/sumneko/lua-language-server/wiki/Build-and-Run-(Standalone)
--- https://github.com/neovim/nvim-lspconfig/blob/2258598/lua/lspconfig/sumneko_lua.lua#L26-L70
local function sumneko_lua_setup()
  local sys
  if vim.fn.has("mac") == 1 then
    sys = 'macOS'
  elseif vim.fn.has("unix") == 1 then
    sys = 'Linux'
  elseif vim.fn.has('win32') == 1 then
    sys = 'Windows'
  else
    vim.notify('Unsupported system for sumneko', vim.log.levels.WARN)
  end
  local sumneko_root_path = lss_dir .. '/lua-language-server'
  local sumneko_binary = sumneko_root_path .. '/bin/' .. sys .. '/lua-language-server'
  lspconfig.sumneko_lua.setup {
    capabilities = make_capabilities(),
    cmd = {sumneko_binary, '-E', sumneko_root_path .. '/main.lua'};
    on_attach = on_attach,
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
    capabilities = make_capabilities(),
    on_attach = on_attach,
  }
end

--- Solargraph setup.
--- `gem install solargraph`
---
--- Ref: https://github.com/castwide/solargraph
 local function solargraph_setup()
  lspconfig.solargraph.setup{
    capabilities = make_capabilities(),
    on_attach = on_attach,
  }
end


--- OCaml-LSP setup.
--- `opam install ocaml-lsp-server`
---
--- Ref: https://github.com/ocaml/ocaml-lsp
local function ocamllsp_setup()
  lspconfig.ocamllsp.setup{
    capabilities = make_capabilities(),
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
    ext = 'sh'
  elseif vim.fn.has('win32') == 1 then
    ext = 'bat'
  else
    vim.notify('Unsupported system for elixirls', vim.log.levels.WARN)
  end

  local elixirls_root_path =  lss_dir .. '/elixir-ls'
  local elixirls_binary = elixirls_root_path .. '/release/language_server.' .. ext
  lspconfig.elixirls.setup{
    capabilities = make_capabilities(),
    cmd = {elixirls_binary},
    on_attach = on_attach,
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
  pylsp_setup()
  sumneko_lua_setup()
  clangd_setup()
  solargraph_setup()
  ocamllsp_setup()
  elixirls_setup()
end

return M
