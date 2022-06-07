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
  vim.cmd([[colorscheme gruvbox-material]])
  -- hi! Normal  ctermbg=NONE guibg=NONE
  -- hi! NonText ctermbg=NONE guibg=NONE
  -- hi! EndOFBuffer ctermbg=NONE guibg=NONE
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
  return require('nvim-treesitter.configs').setup({
    ensure_installed = 'all',
    highlight = { enable = true },
    incremental_selection = { enable = true },
    indent = { enabled = true },
  })
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
      theme = 'gruvbox-material',
      icons_enabled = false,
      component_separators = '',
      section_separators = '',
    },
    sections = {
      lualine_a = { 'mode' },
      lualine_b = {
        'branch',
        {
          'diff',
          color_added = '#a9b665', -- hi GreenSign
          color_modified = '#7daea3', -- hi BlueSign
          color_removed = '#ea6962', -- hi RedSign
        },
      },
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

--- rcarriga/nvim-notify
local function nvim_notify_config()
  require('notify').setup({
    background_colour = '#000000',
    minimum_width = 40,
    stages = 'slide',
    icons = {
      ERROR = '[ERROR]',
      WARN = '[WARN]',
      INFO = '[INFO]',
      DEBUG = '[DEBUG]',
      TRACE = '[TRACE]',
    },
  })
  vim.notify = require('notify') -- override built-in notify
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

--- kyazdani42/nvim-tree.lua
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
            filetype = { 'packer', 'qf', 'toggleterm', 'notify', 'diff' },
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
    mapping =  cmp.mapping.preset.insert({
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

  cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
      { name = 'nvim_lsp_document_symbol' },
    }, {
      { name = 'buffer' },
    }),
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

--- j-hui/fidget.nvim (show progress bar)
local function fidget_nvim_config()
  require('fidget').setup({
    text = { spinner = 'dots' },
    window = { blend = 0 },
  })
end

local function copilot_setup()
  vim.cmd([[imap <silent><script><expr> <c-space> copilot#Accept("")]])
  vim.g.copilot_no_tab_map = true
end

--- Declare all plugins
local function declare_plugins(use)
  local lazy_events = { 'BufRead', 'CursorHold', 'CursorMoved', 'BufNewFile', 'InsertEnter' }

  use({ 'wbthomason/packer.nvim', opt = true })

  -- user interface
  use({ 'nvim-lualine/lualine.nvim' })
  use({ 'sainnhe/gruvbox-material' })
  use({ 'tversteeg/registers.nvim', event = lazy_events })
  use({ 'rcarriga/nvim-notify', config = nvim_notify_config })
  use({ 'lukas-reineke/indent-blankline.nvim', cmd = 'IndentBlanklineToggle' })
  use({
    'kevinhwang91/nvim-bqf', -- yep, this is UI. Currently I use only preview window.
    ft = 'qf',
    config = function()
      require('bqf').setup({ preview = { auto_preview = false } })
    end,
  })

  -- auto-completion
  local cmdline_lazy_events = { 'CmdLineEnter', unpack(lazy_events) }
  use({ 'hrsh7th/nvim-cmp', event = cmdline_lazy_events, config = nvim_cmp_config })
  use({ 'hrsh7th/cmp-buffer', after = 'nvim-cmp' })
  use({ 'hrsh7th/cmp-cmdline', after = 'nvim-cmp' })
  use({ 'hrsh7th/cmp-emoji', after = 'nvim-cmp' })
  use({ 'hrsh7th/cmp-path', after = 'nvim-cmp' })
  use({ 'hrsh7th/cmp-nvim-lsp', after = 'nvim-cmp' })
  use({ 'hrsh7th/cmp-nvim-lsp-document-symbol', after = 'nvim-cmp' })
  use({ 'hrsh7th/cmp-nvim-lua', after = 'nvim-cmp' })
  use({ 'github/copilot.vim', event = lazy_events })

  -- nvim-lsp
  use({
    'neovim/nvim-lspconfig',
    after = 'cmp-nvim-lsp', -- We have the auto-completion capabilities!
    wants = { 'lsp_extensions.nvim', 'nvim-lightbulb', 'lsp_signature.nvim', 'fidget.nvim' },
    config = function()
      require('lsp').setup()
    end,
  })
  use({ 'nvim-lua/lsp_extensions.nvim', opt = true })
  use({ 'kosayoda/nvim-lightbulb', opt = true })
  use({ 'ray-x/lsp_signature.nvim', opt = true, config = lsp_signature_nvim_config })
  use({ 'j-hui/fidget.nvim', opt = true, config = fidget_nvim_config })

  -- fast moves
  use({
    'kyazdani42/nvim-tree.lua',
    cmd = 'NvimTreeToggle',
    config = nvim_tree_config,
  })
  use({ 'troydm/zoomwintab.vim', cmd = 'ZoomWinTabToggle' })
  use({ 'mg979/vim-visual-multi', event = lazy_events })
  use({
    'akinsho/toggleterm.nvim',
    cmd = 'ToggleTerm',
    config = toggleterm_nvim_config,
  })

  -- vcs
  use({
    'lewis6991/gitsigns.nvim',
    wants = { 'plenary.nvim' },
    requires = { { 'nvim-lua/plenary.nvim', opt = true } },
    event = lazy_events,
    config = gitsigns_nvim_config,
  })

  -- filetype
  use({ 'sheerun/vim-polyglot', event = lazy_events })
  use({
    'nvim-treesitter/nvim-treesitter',
    event = lazy_events,
    run = ':TSUpdate',
    config = nvim_treesitter_config,
  })
  use({
    'nvim-treesitter/nvim-treesitter-context',
    after = 'nvim-treesitter',
    config = function()
      require('treesitter-context').setup()
    end,
  })

  -- search
  use({ 'google/vim-searchindex', opt = true }) -- show search index beyond [>99/>99]
  use({
    'nvim-telescope/telescope.nvim',
    wants = { 'plenary.nvim' },
    requires = { { 'nvim-lua/plenary.nvim', opt = true } },
    cmd = { 'Telescope' },
    config = telescope_nvim_config,
  })

  -- dap
  use({ 'mfussenegger/nvim-dap', cmd = 'DapPluginLoad' })
  use({ 'rcarriga/nvim-dap-ui', after = 'nvim-dap' })
end

--- Load all plugins
function M.load_all()
  -- Auto install packer.nvim
  local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim'
  if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
  end

  vim.cmd('packadd packer.nvim')
  vim.cmd([[
    augroup packer_user_config
      autocmd!
      autocmd BufWritePost plugins.lua source <afile> | PackerCompile
    augroup end
  ]])

  -- Declare and load plugins
  require('packer').startup({ declare_plugins, config = { display = { open_fn = require('packer.util').float } } })

  -- Configure plugins
  gruvbox_material_setup()
  zoomwintab_vim_setup()
  lualine_setup()
  nvim_tree_setup()
  telescope_nvim_setup()
  toggleterm_nvim_setup()
  copilot_setup()
  -- Disable keymaps from ocaml/vim-ocaml (https://git.io/JYbMm)
  vim.g.no_ocaml_maps = true
  -- Enable vim-visual-multi mouse mappings
  vim.g.VM_mouse_mappings = 1
  -- Configure nvim-dap on demand
  vim.cmd([[command! DapPluginLoad execute 'PackerLoad nvim-dap' | lua require('dap-configs').setup()]])
end

return M
