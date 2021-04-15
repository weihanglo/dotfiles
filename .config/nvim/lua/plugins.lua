local M = {}

--- nvim-treesitter/nvim-treesitter
M.nvim_treesitter_setup = function ()
  return require'nvim-treesitter.configs'.setup{
    ensure_installed = "maintained",
    highlight = { enable = true },
    incremental_selection = { enable = true },
    indent = { enabled = true },
  }
end

--- nvim-telescope/telescope.nvim
M.telescope_nvim_setup = function ()
  local map = vim.api.nvim_set_keymap
  local opts = { noremap = true, silent = true }
  map('n', '<localleader>b',     '<cmd>Telescope buffers<cr>', opts)
  map('n', '<localleader>c',     '<cmd>Telescope commands<cr>', opts)
  map('n', '<c-p>',              '<cmd>Telescope find_files<cr>', opts)
  map('n', '<localleader><c-p>', '<cmd>Telescope find_files find_command=rg,--files,--smart-case,-uu,--glob,!.git<cr>', opts)
  map('n', '<localleader>G',     '<cmd>Telescope live_grep<cr>', opts)
end

--- kyazdani42/nvim-tree.lua
M.nvim_tree_lua_setup = function ()
  local g = vim.api.nvim_set_var
  g('nvim_tree_add_trailing', 1)
  g('nvim_tree_gitignore', 1)
  g('nvim_tree_ignore', {'.git'})
  g('nvim_tree_show_icons', { folders = 1 })
  g('nvim_tree_group_empty', 1)
  g('nvim_tree_icons', { folder = { default = "▶", open = "▼", empty = "▷", empty_open = "▽", symlink = "⇢", symlink_open = "⇣" } })
  local map = vim.api.nvim_set_keymap
  local opts = { noremap = true, silent = true }
  map('n', '<localleader>n', '<cmd>NvimTreeToggle<cr>', opts)
end

--- Load all plugins
M.load_all = function ()
  -- Auto install packer.nvim
  local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim'
  local cmd = vim.api.nvim_command
  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    cmd('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
    cmd('packadd packer.nvim')
  end

  cmd('packadd packer.nvim')
  cmd('autocmd BufWritePost plugins.lua PackerCompile')

  -- Declare and load plugins
  require'packer'.startup(function(use)
    -- Lock in commit fdf1851 for `plugins.wants` option
    -- See https://github.com/wbthomason/packer.nvim/pull/279
    use {'wbthomason/packer.nvim', opt = true, commit = 'fdf1851'}

    -- user interface
    use {'itchyny/lightline.vim'}
    use {'sainnhe/gruvbox-material'}
    use {'edkolev/tmuxline.vim', opt = true}

    -- nvim-lsp
    use {
      'neovim/nvim-lspconfig',
      event = {'BufNew'},
      wants = {
          'nvim-compe',
          'lsp_extensions.nvim',
          'nvim-lightbulb',
          'vim-visual-multi',
          'nvim-treesitter'
      },
      config = function() require'lsp'.setup() end,
    }
    use {'hrsh7th/nvim-compe', opt = true}
    use {'weihanglo/lsp_extensions.nvim', opt = true, branch = 'customized'}
    use {'kosayoda/nvim-lightbulb', opt = true}
    use {'liuchengxu/vista.vim', cmd = 'Vista'}

    -- fast moves
    use {'kyazdani42/nvim-tree.lua'}
    use {'troydm/zoomwintab.vim', cmd = 'ZoomWinTabToggle'}
    use {'mg979/vim-visual-multi', opt = true}

    -- vcs
    use {'airblade/vim-gitgutter', keys = {'<plug>(GitGutterNextHunk)', '<plug>(GitGutterPrevHunk)'}}

    -- filetype
    use {'rust-lang/rust.vim', ft = 'rust', wants = 'nvim-treesitter'}
    use {'elixir-editors/vim-elixir', ft = 'elixir', wants = 'nvim-treesitter'}
    use {
      'nvim-treesitter/nvim-treesitter',
      opt = true,
      config = M.nvim_treesitter_setup,
    }

    -- search
    use {
      'weihanglo/telescope.nvim',
      cmd = 'Telescope',
      wants = {'popup.nvim', 'plenary.nvim'},
      requires = {
        {'nvim-lua/popup.nvim', opt = true},
        {'nvim-lua/plenary.nvim', opt = true},
      },
      branch = 'feat/commands-table',
    }
    use {'mhinz/vim-grepper', cmd = 'Grepper', keys = {'<plug>(GrepperOperator)'}}

    -- registers
    use {'tversteeg/registers.nvim'}

    -- profiling startup time
    use {'dstein64/vim-startuptime', cmd = 'StartupTime'}
  end)

  -- Configure plugins
  M.nvim_tree_lua_setup()
  M.telescope_nvim_setup()
end

return M
