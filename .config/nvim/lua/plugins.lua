local M = {}

local map = vim.api.nvim_set_keymap

--- catppuccin/nvim
local function catppuccin_config()
  require('catppuccin').setup({
    transparent_background = true,
  })
end

--- troydm/zoomwintab.vim
local function zoomwintab_vim_setup()
  local opts = { noremap = true, silent = false }
  map('n', '<localleader>z', '<cmd>ZoomWinTabToggle<cr>', opts)
  map('n', '<c-w>z', '<cmd>ZoomWinTabToggle<cr>', opts)
  map('t', '<localleader>z', '<c-\\><c-n><cmd>ZoomWinTabToggle<cr><cmd>startinsert<cr>', opts)
  map('t', '<c-w>z', '<c-\\><c-n><cmd>ZoomWinTabToggle<cr><cmd>startinsert<cr>', opts)
  vim.g.zoomwintab_remap = 0
end

--- nvim-treesitter/nvim-treesitter
local function nvim_treesitter_config()
  require('nvim-treesitter.configs').setup({
    ensure_installed = 'all',
    highlight = { enable = true },
    incremental_selection = { enable = true },
    indent = { enabled = true },
  })
end

--- nvim-treesitter/nvim-treesitter-context
local function nvim_treesitter_context_config()
  require('treesitter-context').setup({
    max_lines = 7,
    multiline_threshold = 1,
    mode = 'topline',
  })
end

--- neovim/nvim-lspconfig
local function nvim_lspconfig_config()
  require('lsp').setup()
end

--- nvim-telescope/telescope.nvim
local function telescope_nvim_setup()
  local opts = { noremap = true, silent = true }
  vim.cmd('command! GStatus Telescope git_status')
  vim.cmd('command! GBcommits Telescope git_bcommits')
  map('n', '<localleader>b', '<cmd>Telescope buffers<cr>', opts)
  map('n', '<localleader>c', '<cmd>Telescope commands theme=get_dropdown<cr>', opts)
  map('n', '<c-p>', '<cmd>Telescope find_files<cr>', opts)
  local find = 'rg,--files,--smart-case,-uu,--glob,!.git'
  map('n', '<localleader><c-p>', '<cmd>Telescope find_files find_command=' .. find .. '<cr>', opts)
  map('n', '<localleader>g', '<cmd>Telescope live_grep<cr>', opts)
  map('n', '<localleader>*', "<cmd>exec 'Telescope grep_string prompt_prefix='.expand('<cword>').'>\\ '<cr>", opts)
end
local function telescope_nvim_config()
  require('telescope').setup({
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
      commands = { theme = 'dropdown' },
    },
  })
end

--- hoob3rt/lualine.nvim
local function lualine_setup()
  local function encoding()
    local enc = vim.o.fenc:len() > 0 and vim.o.fenc or vim.o.enc
    return enc ~= 'utf-8' and enc or ''
  end
  require('lualine').setup({
    options = {
      icons_enabled = false,
      component_separators = '',
      section_separators = '',
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = { 'branch', { 'diff' } },
      lualine_c = { 'filename' },
      lualine_x = {
        { 'diagnostics', sources = { 'nvim_diagnostic' } },
        encoding,
        {
          'fileformat',
          format = function(x)
            return x ~= 'unix' and x or ''
          end,
        },
        'filetype',
      },
      lualine_y = { 'progress' },
      lualine_z = { 'location' },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { { 'filename', path = 1 } },
      lualine_x = { 'location' },
      lualine_y = {},
      lualine_z = {},
    },
  })
end

--- nacro90/numb.nvim
local function numb_nvim_config()
  require('numb').setup({
    show_numbers = false,
    number_only = true,
  })
end

--- lewis6991/gitsigns.nvim
local function gitsigns_nvim_config()
  require('gitsigns').setup({
    on_attach = function(bufnr)
      local opts = { noremap = false, silent = true, expr = true }
      local map = function(...)
        vim.api.nvim_buf_set_keymap(bufnr, ...)
      end

      map('n', ']c', "&diff ? ']c' : '<cmd>Gitsigns next_hunk<CR>'", opts)
      map('n', '[c', "&diff ? '[c' : '<cmd>Gitsigns prev_hunk<CR>'", opts)
    end,
    signs = {
      add = { text = '▎' },
      change = { text = '▎' },
      delete = { text = '▁' },
      topdelete = { text = '▔' },
      changedelete = { text = '░' },
    },
  })
end

--- linrongbin16/gitlinker.nvim
local function gitlinker_nvim_config()
  require('gitlinker').setup()
end

--- nvim-tree/nvim-tree.lua
local function nvim_tree_setup()
  local opts = { noremap = true, silent = true }
  map('n', '<localleader>n', '<cmd>NvimTreeToggle<cr>', opts)
end

local function nvim_tree_config()
  require('nvim-tree').setup({
    view = {
      side = 'right',
      signcolumn = 'no',
    },
    actions = {
      open_file = {
        window_picker = {
          exclude = {
            filetype = { 'packer', 'qf', 'toggleterm', 'diff' },
            buftype = { 'nofile', 'terminal', 'help' },
          },
        },
      },
    },
    renderer = {
      add_trailing = true,
      group_empty = true,
      highlight_git = true,
      icons = {
        show = {
          file = true,
          folder_arrow = false,
          folder = true,
          git = false,
        },
        glyphs = {
          default = ' ',
          symlink = ' ',
          folder = {
            arrow_open = '▾',
            arrow_closed = '▸',
            default = '▸',
            open = '▾',
            empty = '▸',
            empty_open = '▾',
            symlink = '▸',
            symlink_open = '▾',
          },
        },
      },
    },
  })
end

-- akinsho/toggleterm.nvim
local function toggleterm_nvim_setup()
  local opts = { noremap = true, silent = true }
  map('n', '<localleader>t', ':<c-u>execute v:count . "ToggleTerm"<cr>', opts)
  map('t', '<localleader>t', '<c-\\><c-n>:<c-u>execute v:count . "ToggleTerm"<cr>', opts)
end
local function toggleterm_nvim_config()
  require('toggleterm').setup({
    start_in_insert = false,
    persist_size = false,
  })
end

--- hrsh7th/nvim-cmp
local function nvim_cmp_config()
  local cmp = require('cmp')

  cmp.setup({
    mapping = cmp.mapping.preset.insert({
      ['<cr>'] = cmp.mapping.confirm(),
      -- replace omnifunc?
      ['<c-x><c-o>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    }),
    sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'nvim_lua' },
    }, {
      { name = 'buffer' },
      { name = 'path' },
      { name = 'emoji' },
    }),
    experimental = { ghost_text = true },
  })

  cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'path' },
    }, {
      { name = 'cmdline' },
    }),
  })
end

--- ray-x/lsp_signature.nvim (show parameter signature while typing)
local function lsp_signature_nvim_config()
  require('lsp_signature').setup({
    bind = true,
    doc_lines = 5,
    transparency = 100,
    floating_window = false,
    floating_window_above_cur_line = false, -- set false to not overlay with pop menu
    toggle_key = '<c-k>', -- LspHover but in insert mode
  })
end

--- j-hui/fidget.nvim
local function fidget_nvim_config()
  require('fidget').setup({
    notification = {
      window = {
        max_width = 40,
        winblend = 0,
      },
    },
    integration = {
      ['nvim-tree'] = {
        enable = false,
      },
    },
  })
end

local function copilot_setup()
  vim.cmd([[imap <silent><script><expr> <c-space> copilot#Accept("")]])
  vim.g.copilot_no_tab_map = true
end

--- Declare all plugins
local function declare_plugins()
  local lazy_events = { 'BufRead', 'CursorHold', 'CursorMoved', 'BufNewFile', 'InsertEnter' }
  local cmdline_lazy_events = { 'CmdLineEnter', unpack(lazy_events) }
  return {
    -- user interface
    { 'catppuccin/nvim', name = 'catppuccin', config = catppuccin_config },
    { 'nvim-lualine/lualine.nvim' },
    { 'nacro90/numb.nvim', event = 'CmdLineEnter', config = true },
    { 'kevinhwang91/nvim-bqf', ft = 'qf', config = true }, -- yep, this is UI. Currently I use only preview window.

    -- auto-completion
    {
      'hrsh7th/nvim-cmp',
      event = cmdline_lazy_events,
      config = nvim_cmp_config,
      dependencies = {
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-cmdline',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-nvim-lua',
      },
    },
    { 'github/copilot.vim', lazy = true },

    -- vcs
    { 'lewis6991/gitsigns.nvim', event = lazy_events, config = gitsigns_nvim_config },
    { 'linrongbin16/gitlinker.nvim', cmd = 'GitLink', config = true },

    -- filetype
    {
      'nvim-treesitter/nvim-treesitter',
      event = lazy_events,
      dependencies = {
        'nvim-treesitter/nvim-treesitter-context',
      },
      build = ':TSUpdate',
      config = nvim_treesitter_config,
    },
    { 'nvim-treesitter/nvim-treesitter-context', lazy = true, config = nvim_treesitter_context_config },

    -- search
    { 'google/vim-searchindex', event = 'CmdLineEnter' }, -- show search index beyond [>99/>99]
    {
      'nvim-telescope/telescope.nvim',
      tag = '0.1.8',
      dependencies = {
        'nvim-lua/plenary.nvim',
      },
      cmd = 'Telescope',
      config = telescope_nvim_config,
    },

    -- nvim-lsp
    {
      'neovim/nvim-lspconfig',
      -- While in lsp module several server have a setup function
      -- This enables only languages I currently work on.
      ft = {
        -- rust-analyzer
        'rust',
        -- pylsp
        'python',
        -- clangd
        'c', 'cpp', 'objc', 'objcpp', 'cuda', 'proto',
      },
      dependencies = {
        'nvim-lua/lsp_extensions.nvim',
        'kosayoda/nvim-lightbulb',
        'ray-x/lsp_signature.nvim',
        'j-hui/fidget.nvim',
      },
      config = nvim_lspconfig_config,
    },
    { 'ray-x/lsp_signature.nvim', lazy = true, config = lsp_signature_nvim_config },
    { 'j-hui/fidget.nvim', lazy = true, config = fidget_nvim_config },

    -- fast moves
    { 'nvim-tree/nvim-tree.lua', cmd = 'NvimTreeToggle', config = nvim_tree_config },
    { 'troydm/zoomwintab.vim', cmd = 'ZoomWinTabToggle' },
    { 'mg979/vim-visual-multi', event = lazy_events },
    { 'akinsho/toggleterm.nvim', cmd = 'ToggleTerm', config = toggleterm_nvim_config },
  }
end

--- Load all plugins
function M.load_all()
  -- Bootstrap lazy.nvim
  local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
  if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
    local out = vim.fn.system({ 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({
        { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
        { out, 'WarningMsg' },
        { '\nPress any key to exit...' },
      }, true, {})
      vim.fn.getchar()
      os.exit(1)
    end
  end
  vim.opt.rtp:prepend(lazypath)

  -- Setup lazy.nvim
  require('lazy').setup({
    spec = declare_plugins(),
    -- automatically check for plugin updates
    checker = {
      enabled = true,
      frequency = 86400, -- everyday
    },
    pkg = {
      sources = {
        'lazy',
        'packspec',
      },
    },
  })

  -- Configure plugins
  vim.cmd.colorscheme('catppuccin')
  zoomwintab_vim_setup()
  lualine_setup()
  nvim_tree_setup()
  telescope_nvim_setup()
  toggleterm_nvim_setup()
  copilot_setup()
  -- Enable vim-visual-multi mouse mappings
  vim.g.VM_mouse_mappings = 1
end

return M
