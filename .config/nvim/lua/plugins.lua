local M = {}

local map = vim.api.nvim_set_keymap

--- nvim-treesitter/nvim-treesitter
local function nvim_treesitter_config()
  return require'nvim-treesitter.configs'.setup{
    ensure_installed = "maintained",
    highlight = { enable = true },
    incremental_selection = { enable = true },
    indent = { enabled = true },
  }
end

--- junegunn/fzf.vim
local function fzf_vim_setup()
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

--- hoob3rt/lualine.nvim
local function lualine_setup()
  local function encoding()
    local enc = vim.o.fenc:len() > 0 and vim.o.fenc or vim.o.enc
    return enc ~= 'utf-8' and enc or ''
  end
  require'lualine'.setup{
    options = {
      theme = 'gruvbox_material',
      icons_enabled = false,
      component_separators = '',
      section_separators = '',
    },
    sections = {
      lualine_a = {},
      lualine_b = {
        'branch',
        {
          'diff',
          color_added = '#a9b665', -- hi GreenSign
          color_modified = '#7daea3', -- hi BlueSign
          color_removed = '#ea6962', -- hi RedSign
        }
      },
      lualine_c = {
        'filename',
        {'diagnostics', sources = {'nvim_lsp'}}
      },
      lualine_x = {
        encoding,
        {'fileformat', format = function (x) return x ~= 'unix' and x or '' end},
        'filetype'
      },
      lualine_y = {'progress'},
      lualine_z = {'location'},
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = {{'filename', path = 1}},
      lualine_x = {'location'},
      lualine_y = {},
      lualine_z = {}
    },
  }
end

--- airblade/vim-gitgutter
local function vim_gitgutter_setup()
  local opts = { noremap = false, silent = true }
  map('n', '[c', '<plug>(GitGutterPrevHunk)', opts)
  map('n', ']c', '<plug>(GitGutterNextHunk)', opts)
  vim.g.gitgutter_map_keys = 0
  -- gitgutter symbols
  vim.g.gitgutter_sign_added = '▎'
  vim.g.gitgutter_sign_modified = '▎'
  vim.g.gitgutter_sign_removed = '▁'
  vim.g.gitgutter_sign_removed_first_line = '▔'
  vim.g.gitgutter_sign_removed_above_and_below = '░'
  vim.g.gitgutter_sign_modified_removed = '▎'
end

--- preservim/nerdtree
local function nerdtree_setup()
  local opts = { noremap = true, silent = true }
  map('n', '<localleader>n', '<cmd>NERDTreeToggle<cr>', opts)
end

-- akinsho/nvim-toggleterm.lua
local function nvim_toggleterm_lua_setup()
  local opts = { noremap = true, silent = true }
  map('n', '<localleader>t', ':<c-u>execute v:count . "ToggleTerm"<cr>', opts)
  map('t', '<localleader>t', '<c-\\><c-n>:<c-u>execute v:count . "ToggleTerm"<cr>', opts)
end
local function nvim_toggleterm_lua_config()
  require'toggleterm'.setup{
    start_in_insert = false,
    persist_size = false,
  }
end

--- Load all plugins
function M.load_all()
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
    use {'hoob3rt/lualine.nvim'}
    use {'sainnhe/gruvbox-material'}

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
      config = nvim_toggleterm_lua_config,
    }

    -- vcs
    use {'airblade/vim-gitgutter'}

    -- filetype
    use {'sheerun/vim-polyglot', event = {'BufNew'}}
    use {
      'nvim-treesitter/nvim-treesitter',
      opt = true,
      config = nvim_treesitter_config,
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

    -- dap
    use {
      'rcarriga/nvim-dap-ui',
      ft = {'rust', 'go'},
      wants = {'nvim-dap'},
      requires = {{'mfussenegger/nvim-dap', opt = true}},
      config = function() require'dap-configs'.setup() end
    }

    -- registers
    use {'tversteeg/registers.nvim'}

    -- profiling startup time
    use {'dstein64/vim-startuptime', cmd = 'StartupTime'}
  end)

  -- Configure plugins
  lualine_setup()
  nerdtree_setup()
  fzf_vim_setup()
  nvim_toggleterm_lua_setup()
  vim_gitgutter_setup()
  vim.g.vista_default_executive = 'nvim_lsp'
  vim.g['vista#renderer#enable_icon'] = false
  -- Disable keymaps from ocaml/vim-ocaml (https://git.io/JYbMm)
  vim.g.no_ocaml_maps = true
end

return M
