local M = {}

local map = vim.api.nvim_set_keymap

--- sainnhe/gruvbox-material
local function gruvbox_material_setup()
  vim.g.gruvbox_material_background = 'soft'
  vim.g.gruvbox_material_better_performance = 1
  vim.g.gruvbox_material_diagnostic_line_highlight = 1
  vim.g.gruvbox_material_diagnostic_text_highlight = 1
  vim.g.gruvbox_material_diagnostic_virtual_text = 'colored'
  vim.g.gruvbox_material_enable_italic = 1
  vim.g.gruvbox_material_transparent_background = 1
  vim.cmd [[colorscheme gruvbox-material]]
  -- hi! Normal  ctermbg=NONE guibg=NONE
  -- hi! NonText ctermbg=NONE guibg=NONE
  -- hi! EndOFBuffer ctermbg=NONE guibg=NONE
end


--- troydm/zoomwintab.vim
local function zoomwintab_vim_setup()
  local opts = { noremap = true, silent = false }
  map('n', '<localleader>z',    '<cmd>ZoomWinTabToggle<cr>', opts)
  map('n', '<c-w>z',            '<cmd>ZoomWinTabToggle<cr>', opts)
  map('t', '<localleader>z',    '<c-\\><c-n><cmd>ZoomWinTabToggle<cr><cmd>startinsert<cr>', opts)
  map('t', '<c-w>z',            '<c-\\><c-n><cmd>ZoomWinTabToggle<cr><cmd>startinsert<cr>', opts)
  vim.g.zoomwintab_remap = 0
end

--- nvim-treesitter/nvim-treesitter
local function nvim_treesitter_config()
  return require'nvim-treesitter.configs'.setup{
    ensure_installed = "maintained",
    highlight = { enable = true },
    incremental_selection = { enable = true },
    indent = { enabled = true },
  }
end

--- nvim-telescope/telescope.nvim
local function telescope_nvim_setup()
  local opts = { noremap = true, silent = true }
  vim.api.nvim_command('command! GStatus Telescope git_status')
  vim.api.nvim_command('command! GBcommits Telescope git_bcommits')
  map('n', '<localleader>b',     '<cmd>Telescope buffers<cr>', opts)
  map('n', '<localleader>c',     '<cmd>Telescope commands theme=get_dropdown<cr>', opts)
  map('n', '<c-p>',              '<cmd>Telescope find_files<cr>', opts)
  local find = 'rg,--files,--smart-case,-uu,--glob,!.git'
  map('n', '<localleader><c-p>', '<cmd>Telescope find_files find_command='..find..'<cr>', opts)
  map('n', '<localleader>g',     '<cmd>Telescope live_grep<cr>', opts)
  map('n', '<localleader>*',     "<cmd>exec 'Telescope grep_string prompt_prefix='.expand('<cword>').'>\\ '<cr>", opts)
end
local function telescope_nvim_config()
  require('telescope').setup{
    defaults = {
      disable_devicons = true,
      layout_config = {
        horizontal = {
          preview_width = 0.5,
          width = 0.90,
        },
      },
    },
    pickers = {
      buffers = {
        theme = 'dropdown',
        previewer = false,
        mappings = {
          i = {
            ['<c-d>'] = 'delete_buffer',
          },
        },
      },
      commands = {theme = 'dropdown'},
    },
  }
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
      lualine_a = {'mode'},
      lualine_b = {
        'branch',
        {
          'diff',
          color_added = '#a9b665', -- hi GreenSign
          color_modified = '#7daea3', -- hi BlueSign
          color_removed = '#ea6962', -- hi RedSign
        }
      },
      lualine_c = {'filename'},
      lualine_x = {
        {'diagnostics', sources = {'nvim_lsp'}},
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
    use {'tversteeg/registers.nvim'}
    use {
      'kevinhwang91/nvim-bqf', -- yep, this is UI. Currently I use only preview window.
      ft = 'qf',
      config = function () require'bqf'.setup{preview = {auto_preview = false}} end
    }

    -- nvim-lsp
    use {
      'neovim/nvim-lspconfig',
      event = {'BufNew'},
      wants = {
          'nvim-compe',
          'lsp_extensions.nvim',
          'nvim-lightbulb',
          'nvim-treesitter-context',
      },
      config = function() require'lsp'.setup() end,
    }
    use {'hrsh7th/nvim-compe', opt = true}
    use {'nvim-lua/lsp_extensions.nvim', opt = true}
    use {'kosayoda/nvim-lightbulb', opt = true}

    -- fast moves
    use {'preservim/nerdtree', cmd = 'NERDTreeToggle'}
    use {'troydm/zoomwintab.vim', cmd = 'ZoomWinTabToggle'}
    use {'mg979/vim-visual-multi', opt = true}
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
      'romgrk/nvim-treesitter-context',
      opt = true,
      wants = {'nvim-treesitter'},
      requires = {
        {
          'nvim-treesitter/nvim-treesitter',
          opt = true,
          config = nvim_treesitter_config,
          branch = '0.5-compat',
        },
      },
      config = function() require'treesitter-context'.setup() end,
    }

    -- search
    use {'google/vim-searchindex', opt = true} -- show search index beyond [>99/>99]
    use {
      'nvim-telescope/telescope.nvim',
      wants = {'plenary.nvim'},
      requires = {{'nvim-lua/plenary.nvim', opt = true}},
      cmd = {'Telescope'},
      config = telescope_nvim_config,
    }

    -- dap
    use {
      'rcarriga/nvim-dap-ui',
      ft = {'rust', 'go'},
      wants = {'nvim-dap'},
      requires = {{'mfussenegger/nvim-dap', opt = true}},
      config = function() require'dap-configs'.setup() end
    }
  end)

  -- Configure plugins
  gruvbox_material_setup()
  zoomwintab_vim_setup()
  lualine_setup()
  nerdtree_setup()
  telescope_nvim_setup()
  nvim_toggleterm_lua_setup()
  vim_gitgutter_setup()
  -- Disable keymaps from ocaml/vim-ocaml (https://git.io/JYbMm)
  vim.g.no_ocaml_maps = true
  -- Enable vim-visual-multi mouse mappings
  vim.g.VM_mouse_mappings = 1
end

return M
