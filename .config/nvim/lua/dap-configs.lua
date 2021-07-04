-- Please put each debug adapter and debugee under "$XDG_DATA_HOME/nvim/daps"
-- directory, which equals `vim.fn.stdpath('data')`.

local vim = vim
local M = {}

function M.setup()
  local dap = require('dap')
  require'dapui'.setup()

  local function get_file(prompt, path)
    return function()
      path = path or ''
      return vim.fn.input(prompt, vim.fn.getcwd() .. '/' .. path, 'file')
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
      program = get_file('Executable to debug: ', 'target/debug/'),
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      args = {},
      runInTerminal = false,
  --- Adapter: GO delve dap
  --
  -- `go get -u github.com/go-delve/delve/cmd/dlv`
  -- `dlv help dap`
  -- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
  dap.adapters.go = function(callback, config)
    local function echoerr(msg) vim.api.nvim_echo({{msg, 'ErrorMsg'}}, true, {}) end
    local function echowarn(msg) vim.api.nvim_echo({{msg, 'WarningMsg'}}, true, {}) end
    local function parse_port(data)
      -- stdout example: "DAP server listening at: 127.0.0.1:51576"
      local res = ''
      res = string.gsub(data, '%s+', '')
      res = string.match(res, ':%d+$')
      res = string.sub(res, 2)
      return tonumber(res)
    end
    local dlv_started = false
    local function on_event(_, data, event)
      if event == 'stdout' then
        if dlv_started or not data or data == '' then
          return
        end
        data = table.concat(data)
        local port = parse_port(data)
        if not port then
          echoerr('[DAP] Cannot parse port from stdout of `delve dap`')
        else
          echowarn('[DAP] listening on port '..port)
          dlv_started = true
          callback({type = 'server', host = '127.0.0.1', port = port})
        end
      elseif event == 'stderr' then
          echowarn('[DAP] stderr: '..table.concat(data))
      else
        echowarn('[DAP] `delve dap` is exitting')
      end
    end

    vim.fn.jobstart(
      {'dlv', 'dap', '--build-flags="-v"'},
      {
        on_exit = on_event,
        on_stdout = on_event,
        on_stderr = on_event,
      }
    )
  end

  --- Debugee: Go delve dap
  --
  -- https://github.com/go-delve/delve/blob/de117a2f/service/dap/server.go#L135-L148
  -- https://github.com/go-delve/delve/blob/9dfd164c/service/dap/server.go#L737-L901
  -- https://github.com/golang/vscode-go/blob/master/package.json
  dap.configurations.go = {
    {
      type = 'go',
      name = 'Debug Go pkg',
      request = 'launch',
      mode = 'debug',
      stopOnEntry = false,
      program = get_file('Pkg to debug: '),
      args = {}, -- array to progarm args
      env = {}, -- env var table
    },
    {
      type = 'go',
      name = 'Debug Go tests',
      request = 'launch',
      mode = 'test',
      program = get_file('Pkg to debug: ', 'pkg'),
      args = {}, -- array to progarm args
      env = {}, -- env var table
    },
    {
      type = 'go',
      name = 'Debug Go executable',
      request = 'launch',
      mode = 'exec',
      trace = true,
      program = get_file('Executable to debug: '),
      args = {}, -- array to progarm args
      env = {}, -- env var table
    },
  }

  -- Merge VSCode `.vscode/launch.json` under current workspace
  require'dap.ext.vscode'.load_launchjs()
end

return M
