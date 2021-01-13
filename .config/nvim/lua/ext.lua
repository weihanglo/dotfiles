local vim = vim
local M = {}

M.nvim_treesitter_setup = function()
  return require'nvim-treesitter.configs'.setup{
    ensure_installed = "maintained",
    highlight = { enable = true },
    incremental_selection = { enable = true },
    indent = { enabled = true },
  }
end

return M
