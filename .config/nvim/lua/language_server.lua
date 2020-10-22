local vim = vim
local string = string
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

--- Return python virtualenv path for current working directory.
-- Currently support: `pipenv`.
--
-- Ref: https://duseev.com/articles/vim-python-pipenv/
local get_python_venv_path = function()
  local pipenv_venv_path = vim.fn.system('pipenv --venv')
  if vim.v.shell_error == 0 then
    local venv_path = string.gsub(pipenv_venv_path, '%s+$', '')
    return venv_path
  end
end

--- Python Language Server setup.
-- `python3 -m pip install 'python-language-server[all]'`
--
-- Ref: https://github.com/palantir/python-language-server
M.pyls_setup = function()
  nvim_lsp.pyls.setup{
    on_attach = make_on_attach(),
    settings = {
      pyls = {
        plugins = {
          jedi = {
            environment = get_python_venv_path()
          }
        }
      }
    }
  }
end

--- Setup all language servers from above configurations.
M.setup = function()
  M.rust_analyzer_setup()
  M.gopls_setup()
  M.tsserver_setup()
  M.pyls_setup()
end

return M
