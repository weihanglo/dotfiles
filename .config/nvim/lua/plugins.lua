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

--- junegunn/fzf.vim
local function fzf_vim_setup()
  local map = vim.api.nvim_set_keymap
  local opts = { noremap = true, silent = true }
  -- From fzf official doc.
  -- An action can be a reference to a function that processes selected lines.
  vim.api.nvim_command [[
    function! s:build_qflist(lines)
      call setqflist(map(copy(a:lines), '{ "filename": v:val }')) | copen | cc
    endfunction
    let g:fzf_action = { 'ctrl-q': function('s:build_qflist'), 'ctrl-t': 'tab split', 'ctrl-x': 'split', 'ctrl-v': 'vsplit' }
  ]]
  vim.api.nvim_command("command! -bang -nargs=? -complete=dir AllFiles call fzf#vim#files(<q-args>, fzf#vim#with_preview({'source': 'rg --files --smart-case -uu --glob !.git'}), <bang>0)")
  vim.g.fzf_layout = { window = { width = 0.9, height = 0.9 } }
  map('n', '<localleader>b',     '<cmd>Buffers<cr>', opts)
  map('n', '<localleader>c',     '<cmd>Commands<cr>', opts)
  map('n', '<c-p>',              '<cmd>Files<cr>', opts)
  map('n', '<localleader><c-p>', '<cmd>AllFiles<cr>', opts)
  map('n', '<localleader>g',     "<cmd>Rg<cr>", opts)
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
  map('n', '<localleader>t', ':<c-u>execute v:count1 . "ToggleTerm"<cr>', opts)
  map('t', '<localleader>t', '<c-\\><c-n>:<c-u>execute v:count1 . "ToggleTerm"<cr>', opts)
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
    use {'wbthomason/packer.nvim', opt = true}

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
          'nvim-treesitter',
      },
      config = function() require'lsp'.setup() end,
    }
    use {'hrsh7th/nvim-compe', opt = true}
    use {'nvim-lua/lsp_extensions.nvim', opt = true}
    use {'kosayoda/nvim-lightbulb', opt = true}
    use {'liuchengxu/vista.vim', cmd = 'Vista'}

    -- fast moves
    use {'preservim/nerdtree', cmd = 'NERDTreeToggle'}
    use {'troydm/zoomwintab.vim', cmd = 'ZoomWinTabToggle'}
    use {'mg979/vim-visual-multi'}
    use {
      'akinsho/nvim-toggleterm.lua',
      cmd = 'ToggleTerm',
      config = function () require'toggleterm'.setup{start_in_insert = false} end,
    }

    -- vcs
    use {'airblade/vim-gitgutter'}

    -- filetype
    use {'sheerun/vim-polyglot', event = {'BufNew'}}
    use {
      'nvim-treesitter/nvim-treesitter',
      opt = true,
      config = nvim_treesitter_setup,
    }

    -- search
    use {'google/vim-searchindex', opt = true} -- show search index beyond [>99/>99]
    use {
      'junegunn/fzf.vim',
      cmd = {'Files', 'GFiles', 'Buffers', 'Rg', 'Commands', 'BCommits'},
      wants = {'fzf'},
      requires = {
        {'junegunn/fzf', opt = true}
      }
    }

    -- registers
    use {'tversteeg/registers.nvim'}

    -- profiling startup time
    use {'dstein64/vim-startuptime', cmd = 'StartupTime'}
  end)

  -- Configure plugins
  nerdtree_setup()
  fzf_vim_setup()
  nvim_toggleterm_lua_setup()
  vim.g.vista_default_executive = 'nvim_lsp'
  vim.g['vista#renderer#enable_icon'] = false
  -- Disable keymaps from ocaml/vim-ocaml (https://git.io/JYbMm)
  vim.g.no_ocaml_maps = true
  -- gitgutter symbols
  vim.g.gitgutter_sign_added = '▎'
  vim.g.gitgutter_sign_modified = '▎'
  vim.g.gitgutter_sign_removed = '▁'
  vim.g.gitgutter_sign_removed_first_line = '▔'
  vim.g.gitgutter_sign_removed_above_and_below = '░'
  vim.g.gitgutter_sign_modified_removed = '▎'
end

return M
