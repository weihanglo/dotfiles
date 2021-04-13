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
  use {'edkolev/tmuxline.vim', cmd = {'Tmuxline', 'TmuxlineSnapshot'}}
  use {'sainnhe/gruvbox-material'}

  -- nvim-lsp
  use {'neovim/nvim-lspconfig'}
  use {'hrsh7th/nvim-compe'}
  use {'weihanglo/lsp_extensions.nvim', branch = 'customized'}
  use {'liuchengxu/vista.vim', cmd = 'Vista'}
  use {'kosayoda/nvim-lightbulb'}

  -- fast moves
  use {'troydm/zoomwintab.vim', cmd = 'ZoomWinTabToggle'}
  use {'kyazdani42/nvim-tree.lua'}
  use {'mg979/vim-visual-multi'}

  -- vcs
  use {'airblade/vim-gitgutter', keys = {'<plug>(GitGutterNextHunk)', '<plug>(GitGutterPrevHunk)'}}

  -- filetype
  use {'rust-lang/rust.vim', ft = 'rust'}
  use {'elixir-editors/vim-elixir', ft = 'elixir'}
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'}

  -- search
  use {'weihanglo/telescope.nvim',
    cmd = 'Telescope',
    -- Ref: https://github.com/wbthomason/packer.nvim/pull/279
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
