local vim = vim
local lspconfig = require'lspconfig'
local M = {}

local on_attach = function(client, bufnr)
  -- Auto-completion functionality from `hrsh7th/nvim-compe`
  -- This will setup with buffers attached with LSP clients.
  require'compe'.setup {
    source = {
      path = true,
      buffer = true,
      tags = true,
      spell = true,
      calc = true,
      emoji = true,
      nvim_lsp = true,
      nvim_lua = true,
      vsnip = true,
    };
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
  map('n', '<c-]>',                 '<cmd>Telescope lsp_definitions<cr>', opts)
  map('n', 'K',                     '<cmd>LspHover<cr>', opts)
  map('n', '<c-k>',                 '<cmd>LspSignatureHelp<cr>', opts)
  map('n', '<localleader><space>',  '<cmd>LspCodeAction<cr>', opts)
  map('n', '<f7>',                  '<cmd>Telescope lsp_references<cr>', opts)
  map('n', '<f2>',                  '<cmd>LspRename<cr>', opts)
  map('i', '<cr>',                  'compe#confirm("<cr>")', { noremap = true, silent = true, expr = true })
  map('n', ']e',                    '<cmd>lua vim.lsp.diagnostic.goto_next()<cr>', opts)
  map('n', '[e',                    '<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>', opts)

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
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
  end
end

--- Rust Analyzer setup.
--- `git clone https://github.com/rust-analyzer/rust-analyzer` and build!
---
--- Ref: https://github.com/rust-analyzer/rust-analyzer
M.rust_analyzer_setup = function()
  -- Inlay hints for rust
  local rust_on_attach = function(client, bufnr)
    vim.api.nvim_exec([[
      augroup RustInlayHint
        autocmd! * <buffer>
        autocmd CursorHold,CursorHoldI <buffer> silent lua require'lsp_extensions'.inlay_hints{ only_current_line = true, prefix = ' » ', highlight = "NonText" }
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
        lruCapacity = 512
      }
    }
  }
end

--- TypeScript Language Server setup.
--- `npm i g typescript-language-server`
---
--- Ref: https://github.com/theia-ide/typescript-language-server
M.tsserver_setup = function()
  lspconfig.tsserver.setup{
    on_attach = on_attach
  }
end

--- gopls setup.
--- `GO111MODULE=on go get golang.org/x/tools/gopls@latest`
---
--- Ref: https://github.com/golang/tools/blob/master/gopls/README.md
M.gopls_setup = function()
  lspconfig.gopls.setup{ on_attach = on_attach }
end

--- Asynchorounsly get python virtualenv path for current working directory.
--- Currently support: `pipenv`.
---
--- This is done by neovim job-control system. See `:h job-control`.
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
--- `python3 -m pip install 'python-language-server[all]'`
---
--- Ref: https://github.com/palantir/python-language-server
M.pyls_setup = function()
  get_python_venv_path(function(venv_path)
    local echo = vim.api.nvim_echo
    local settings = {
      pyls = { plugins = { jedi = { environment = vim.NIL } } }
    }
    lspconfig.pyls.setup{
      on_attach = on_attach,
      settings = settings,
    }
    if venv_path ~= '' then
      echo({{'[LSP] set Python venv at'..venv_path, 'WarningMsg'}}, true, {})
      settings.pyls.plugins.jedi = {
        environment = venv_path
      }
    else
      echo({{'[LSP] Python venv not found', 'WarningMsg'}}, true, {})
    end
  end)
end

--- lua-language-server setup.
--- `git clone https://github.com/sumneko/lua-language-server` and build!
---
--- Ref: https://github.com/sumneko/lua-language-server/wiki/Build-and-Run-(Standalone)
--- https://github.com/neovim/nvim-lspconfig/blob/2258598/lua/lspconfig/sumneko_lua.lua#L26-L70
M.sumneko_lua_setup = function()
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
  local sumneko_root_path = vim.fn.stdpath('data') .. '/lss/lua-language-server'
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
M.clangd_setup = function()
  lspconfig.clangd.setup{
    on_attach = on_attach,
  }
end

--- Solargraph setup.
--- `gem install solargraph`
---
--- Ref: https://github.com/castwide/solargraph
M.solargraph_setup = function()
  lspconfig.solargraph.setup{
    on_attach = on_attach,
  }
end


--- OCaml-LSP setup.
--- `opam install ocaml-lsp-server`
---
--- Ref: https://github.com/ocaml/ocaml-lsp
M.ocamllsp_setup = function()
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
M.elixirls_setup = function()
  local ext
  if vim.fn.has("mac") == 1 or vim.fn.has("unix") == 1 then
    ext = "sh"
  elseif vim.fn.has('win32') == 1 then
      ext = "bat"
  else
    print("Unsupported system for elixirls")
  end
  local elixirls_root_path = vim.fn.stdpath('data') .. '/lss/elixir-ls'
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
  M.rust_analyzer_setup()
  M.gopls_setup()
  M.tsserver_setup()
  M.pyls_setup()
  M.sumneko_lua_setup()
  M.clangd_setup()
  M.solargraph_setup()
  M.ocamllsp_setup()
  M.elixirls_setup()
end

return M
