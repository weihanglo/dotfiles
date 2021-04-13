-- Auto install packer.nvim
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.api.nvim_command('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
  vim.cmd [[packadd packer.nvim]]
end

vim.cmd [[packadd packer.nvim]]
vim.cmd [[autocmd BufWritePost plugins.lua PackerCompile]]

return require'packer'.startup(function(use)
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
    config = function() require'ext'.nvim_treesitter_setup() end,
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
