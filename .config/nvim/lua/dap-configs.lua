-- Please put each debug adapter and debugee under "$XDG_DATA_HOME/nvim/daps"
-- directory, which equals `vim.fn.stdpath('data')`.

local vim = vim
local M = {}

function M.setup()
  local dap = require('dap')
  require'dapui'.setup()

  local function get_executable(path)
    return function()
      path = path or ''
      return vim.fn.input('Executable to debug: ', vim.fn.getcwd() .. '/' .. path, 'file')
    end
  end

  -- Vim commands setup

  vim.api.nvim_exec([[
    command! DapContinue            lua require'dap'.continue()
    command! DapRun                 lua require'dap'.run()
    command! DapRunToCursor         lua require'dap'.run_to_cursor()
    command! DapRunLast             lua require'dap'.run_last()
    command! DapPause               lua require'dap'.pause()
    command! DapStop                lua require'dap'.stop()
    command! DapStepOver            lua require'dap'.step_over()
    command! DapStepInto            lua require'dap'.step_into()
    command! DapStepOut             lua require'dap'.step_out()
    command! DapToggleBreakpoint    lua require'dap'.toggle_breakpoint()
    command! DapConditionBreakpoint lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))
    command! DapLogBreakpoint       lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
    command! DapListBreakpoints     lua require'dap'.list_breakpoints()
    command! DapReplOpen            lua require'dap'.repl.open()
    command! DapReplClose           lua require'dap'.repl.close()
    command! DapUiToggle            lua require'dapui'.toggle()
  ]], false)

  -- Vim keymaps setup
  local map = vim.api.nvim_set_keymap
  local opts = { noremap = true, silent = true }
  -- Yep. Function keys with modifier are usually mulfunctional.
  map('n', '<f5>',    '<cmd>DapContinue<cr>', opts)
  map('n', '<s-f5>',  '<cmd>DapStop<cr>', opts)
  map('n', '<f6>',    '<cmd>DapStepPause<cr>', opts)
  map('n', '<f9>',    '<cmd>DapToggleBreakpoint<cr>', opts)
  map('n', '<f10>',   '<cmd>DapStepOver<cr>', opts)
  map('n', '<c-f10>', '<cmd>DapRunToCursor<cr>', opts)
  map('n', '<f11>',   '<cmd>DapStepInto<cr>', opts)
  map('n', '<s-f11>', '<cmd>DapStepOut<cr>', opts)

  -- Debug signs setups
  local signdef = vim.fn.sign_define
  signdef('DapBreakpoint',         {text='●', texthl='WarningMsg'})
  signdef('DapLogPoint',           {text='◆', texthl='WarningMsg'})
  signdef('DapBreakpointRejected', {text='●', texthl='LineNr'})
  signdef('DapStopped',            {text='→', texthl='MatchParen'})

  --- Adapter: lldb
  -- Modern LLVM installations are shipped with lldb-vscode,
  -- so you only need to add it to your PATH.
  dap.adapters.lldb = {
    type = 'executable',
    command = 'lldb-vscode'
  }

  --- Debugee: Rust
  dap.configurations.rust = {
    {
      name = 'Launch LLDB for Rust',
      type = 'lldb',
      request = 'launch',
      program = get_executable('target/debug/'),
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},
      runInTerminal = false,
    },
  }

  -- Merge VSCode `.vscode/launch.json` under current workspace
  require'dap.ext.vscode'.load_launchjs()
end

return M
