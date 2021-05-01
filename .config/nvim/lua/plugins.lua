local M = {}

--- nvim-treesitter/nvim-treesitter
local function nvim_treesitter_setup()
  return require'nvim-treesitter.configs'.setup{
    ensure_installed = "maintained",
    highlight = { enable = true },
    incremental_selection = { enable = true },
    indent = { enabled = true },
  }
end

--- nvim-telescope/telescope.nvim
local function telescope_nvim_setup()
  local map = vim.api.nvim_set_keymap
  local opts = { noremap = true, silent = true }
  local unrestricted = ',-uu,--glob,!.git'
  vim.api.nvim_command('command! GStatus Telescope git_status')
  vim.api.nvim_command('command! GBcommits Telescope git_bcommits')
  map('n', '<localleader>b',     '<cmd>Telescope buffers<cr>', opts)
  map('n', '<localleader>c',     '<cmd>Telescope commands<cr>', opts)
  map('n', '<c-p>',              '<cmd>Telescope find_files<cr>', opts)
  local find = 'rg,--files,--smart-case'..unrestricted
  map('n', '<localleader><c-p>', '<cmd>Telescope find_files find_command='..find..'<cr>', opts)
  map('n', '<localleader>g',     '<cmd>Telescope live_grep<cr>', opts)
  map('n', '<localleader>*',     "<cmd>exec 'Telescope grep_string prompt_prefix='.expand('<cword>').'>\\ '<cr>", opts)
end

--- preservim/nerdtree
local function nerdtree_setup()
  local map = vim.api.nvim_set_keymap
  local opts = { noremap = true, silent = true }
  map('n', '<localleader>n', '<cmd>NERDTreeToggle<cr>', opts)
end

-- akinsho/nvim-toggleterm.lua
local function nvim_toggleterm_lua_setup()
  local map = vim.api.nvim_set_keymap
  local opts = { noremap = true, silent = true }
  map('n', '<localleader>t', '<cmd>execute v:count1 . "ToggleTerm"<cr>', opts)
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

    -- fast moves
    use {'preservim/nerdtree', cmd = 'NERDTreeToggle'}
    use {'troydm/zoomwintab.vim', cmd = 'ZoomWinTabToggle'}
    use {'mg979/vim-visual-multi', opt = true}

    -- vcs
    use {'airblade/vim-gitgutter', keys = {'<plug>(GitGutterNextHunk)', '<plug>(GitGutterPrevHunk)'}}

    -- filetype
    use {'rust-lang/rust.vim', ft = 'rust', wants = 'nvim-treesitter'}
    use {'elixir-editors/vim-elixir', ft = 'elixir', wants = 'nvim-treesitter'}
    use {'fatih/vim-go', wants = 'nvim-treesitter'}
    use {
      'nvim-treesitter/nvim-treesitter',
      opt = true,
      config = nvim_treesitter_setup,
    }

    -- search
    use {
      'nvim-telescope/telescope.nvim',
      cmd = 'Telescope',
      wants = {'popup.nvim', 'plenary.nvim'},
      requires = {
        {'nvim-lua/popup.nvim', opt = true},
        {'nvim-lua/plenary.nvim', opt = true},
      },
    }

    -- registers
    use {'tversteeg/registers.nvim'}

    -- profiling startup time
    use {'dstein64/vim-startuptime', cmd = 'StartupTime'}

    use {
      'akinsho/nvim-toggleterm.lua',
      cmd = 'ToggleTerm',
      config = function () require'toggleterm'.setup{} end,
    }
  end)

  -- Configure plugins
  nerdtree_setup()
  telescope_nvim_setup()
  nvim_toggleterm_lua_setup()
end

return M
