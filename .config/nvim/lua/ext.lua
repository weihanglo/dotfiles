local vim = vim
local M = {}

M.telescope_setup = function()
  local map = vim.api.nvim_set_keymap
  local opts = { noremap = true, silent = true }
  map('n', '<LocalLeader>b',     '<cmd>Telescope buffers<cr>', opts)
  map('n', '<LocalLeader>c',     '<cmd>Telescope commands<cr>', opts)
  map('n', '<c-p>',              '<cmd>Telescope find_files<cr>', opts)
  map('n', '<LocalLeader><c-p>', '<cmd>Telescope find_files find_command=rg,-S,--files,-uu,--glob,!.git<cr>', opts)
  map('n', '<LocalLeader>G',     '<cmd>Telescope live_grep<cr>', opts)
  return require'telescope'.setup{
    defaults = {
      file_previewer = require'telescope.previewers'.vim_buffer_cat.new,
      grep_previewer = require'telescope.previewers'.vim_buffer_vimgrep.new,
      qflist_previewer = require'telescope.previewers'.vim_buffer_qflist.new,
    }
  }
end

M.nvim_treesitter_setup = function()
  return require'nvim-treesitter.configs'.setup{
    ensure_installed = "maintained",
    highlight = { enable = true },
    incremental_selection = { enable = true },
    indent = { enabled = true },
  }
end

return M
