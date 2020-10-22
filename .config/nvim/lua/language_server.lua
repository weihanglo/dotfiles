local vim = vim
local nvim_lsp = require'nvim_lsp'
local M = {}

local make_on_attach = function(comp, diag)
  return function(client)
    -- Auto-completion functionality from `nvim-lua/completion-nvim`
    require'completion'.on_attach(comp)
    -- Better diagnose UI from `nvim-lua/diagnostic-nvim`
    require'diagnostic'.on_attach(diag)
  end
end

--- Rust Analyzer setup.
--`git clone https://github.com/rust-analyzer/rust-analyzer` and build!
--
-- Ref: https://github.com/rust-analyzer/rust-analyzer
M.rust_analyzer_setup = function()
  nvim_lsp.rust_analyzer.setup{
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
  nvim_lsp.tsserver.setup{
    on_attach = make_on_attach({ sorting = "alphabet" })
  }
end

--- gopls setup.
-- `GO111MODULE=on go get golang.org/x/tools/gopls@latest`
--
-- Ref: https://github.com/golang/tools/blob/master/gopls/README.md
M.gopls_setup = function()
  nvim_lsp.gopls.setup{ on_attach = make_on_attach() }
end

--- Asynchorounsly get python virtualenv path for current working directory.
-- Currently support: `pipenv`.
--
-- This is done by neovim job-control system. See `:h job-control`.
local get_python_venv_path = function(callback)
  local on_event = function(job_id, data, event)
    if event == 'stdout' then
      -- Leading and trailing elements would contains gibberish whitespaces.
      callback(data[1])
    end
  end
  local job_id = vim.fn.jobstart(
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
    nvim_lsp.pyls.setup{
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
-- `:LspInstall sumneko_lua`
--
-- Ref: https://github.com/sumneko/lua-language-server
M.sumneko_lua_setup = function()
  nvim_lsp.sumneko_lua.setup{}
end

--- Setup all language servers from above configurations.
M.setup = function()
  vim.schedule(function()
    M.rust_analyzer_setup()
    M.gopls_setup()
    M.tsserver_setup()
    M.pyls_setup()
    M.sumneko_lua_setup()
  end)
end

return M
