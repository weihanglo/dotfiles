-- Please put each debug adapter and debugee under "$XDG_DATA_HOME/nvim/daps"
-- directory, which equals `vim.fn.stdpath('data')`.

local vim = vim
local M = {}
local dap = require('dap')

local function get_file(prompt, path)
  return function()
    path = path or ''
    return vim.fn.input(prompt, vim.fn.getcwd() .. '/' .. path, 'file')
  end
end

function M.setup()
  require('dapui').setup()

  -- Vim commands setup
  vim.api.nvim_exec(
    [[
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
    command! DapReloadConfigs       lua require'dap-configs'.load_configs(true)
  ]],
    false
  )

  -- Vim keymaps setup
  local map = vim.api.nvim_set_keymap
  local opts = { noremap = true, silent = true }
  -- Yep. Function keys with modifier are usually mulfunctional.
  map('n', '<f5>', '<cmd>DapContinue<cr>', opts)
  map('n', '<s-f5>', '<cmd>DapStop<cr>', opts)
  map('n', '<f6>', '<cmd>DapStepPause<cr>', opts)
  map('n', '<f9>', '<cmd>DapToggleBreakpoint<cr>', opts)
  map('n', '<f10>', '<cmd>DapStepOver<cr>', opts)
  map('n', '<c-f10>', '<cmd>DapRunToCursor<cr>', opts)
  map('n', '<f11>', '<cmd>DapStepInto<cr>', opts)
  map('n', '<s-f11>', '<cmd>DapStepOut<cr>', opts)

  -- Debug signs setups
  local signdef = vim.fn.sign_define
  signdef('DapBreakpoint', { text = '●', texthl = 'WarningMsg' })
  signdef('DapLogPoint', { text = '◆', texthl = 'WarningMsg' })
  signdef('DapBreakpointRejected', { text = '●', texthl = 'LineNr' })
  signdef('DapStopped', { text = '→', texthl = 'MatchParen' })

  -- Load debugger adapter configurations
  M.adapter_lldb()
  M.adapter_go()

  M.load_configs()
end

--- Adapter: lldb
--
-- `lldb-vscode --help`
-- Modern LLVM installations are shipped with lldb-vscode,
-- so you only need to add it to your PATH.
function M.adapter_lldb()
  dap.adapters.lldb = {
    type = 'executable',
    command = 'lldb-vscode',
    args = {},
  }
end

--- Adapter: GO delve dap
--
-- `go install github.com/go-delve/delve/cmd/dlv@latest`
-- `dlv help dap`
-- https://github.com/go-delve/delve/blob/master/Documentation/usage/dlv_dap.md
function M.adapter_go()
  dap.adapters.go = function(callback, config)
    local function parse_port(data)
      -- stdout example: "DAP server listening at: 127.0.0.1:51576"
      return tonumber(data:gsub('%s+', ''):match(':%d+$'):sub(2))
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
          vim.notify('[DAP] Cannot parse port from stdout of `delve dap`', vim.log.levels.ERROR)
        else
          vim.notify('[DAP] listening on port ' .. port, vim.log.levels.INFO)
          dlv_started = true
          callback({ type = 'server', host = '127.0.0.1', port = port })
        end
      elseif event == 'stderr' then
        vim.notify('[DAP] stderr:\n' .. table.concat(data), vim.log.levels.WARN)
      else
        vim.notify('[DAP] `delve dap` is exitting', vim.log.levels.WARN)
      end
    end

    vim.fn.jobstart({ 'dlv', 'dap', '--build-flags="-v"' }, {
      on_exit = on_event,
      on_stdout = on_event,
      on_stderr = on_event,
    })
  end
end

--- Debugee: Rust
--
-- https://github.com/llvm/llvm-project/tree/main/lldb/tools/lldb-vscode#configurations
-- https://github.com/llvm/llvm-project/blob/release/12.x/lldb/tools/lldb-vscode/package.json
local function debugee_rust()
  local function get_test_executable()
    vim.notify('\n[DAP] building Rust tests...', vim.log.levels.INFO)
    local result = vim.fn.system([[
      cargo test --no-run --message-format=json 2> /dev/null | jq -r 'select((.executable != null) and (.target.kind | contains(["lib"]))) | .executable'
    ]])
    local test_targets = {}
    for target in result:gmatch('[^\r\n]+') do
      table.insert(test_targets, target)
    end
    if #test_targets == 1 then
      return test_targets[1]
    elseif #test_targets > 2 then
      local inputlist = { 'Select a test target' }
      for i, target in ipairs(test_targets) do
        table.insert(inputlist, i .. ': ' .. target)
      end
      local selected = vim.fn.inputlist(inputlist)
      return test_targets[selected]
    else
      vim.notify('[DAP] no test targest found', vim.log.levels.INFO)
    end
  end

  dap.configurations.rust = {
    {
      name = 'Debug Rust executable',
      type = 'lldb',
      request = 'launch',
      program = get_file('Executable to debug: ', 'target/debug/'),
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      runInTerminal = false,
      args = {},
      env = {},
    },
    {
      name = 'Debug Rust tests',
      type = 'lldb',
      request = 'launch',
      program = get_test_executable,
      cwd = '${workspaceFolder}',
      stopOnEntry = false,
      runInTerminal = false,
      args = {},
      env = {},
    },
  }
  -- HACK: `type` needs to be "rust" but vscode only recognize "lldb"
  -- Let's setup a compatible layer then.
  dap.configurations.lldb = dap.configurations.rust
end

--- Debugee: Go delve dap
--
-- https://github.com/go-delve/delve/blob/de117a2f/service/dap/server.go#L135-L148
-- https://github.com/go-delve/delve/blob/9dfd164c/service/dap/server.go#L737-L901
-- https://github.com/golang/vscode-go/blob/master/package.json
local function debugee_go()
  dap.configurations.go = {
    {
      type = 'go',
      name = 'Debug Go pkg',
      request = 'launch',
      mode = 'debug',
      stopOnEntry = false,
      program = get_file('Pkg to debug: '),
      args = {}, -- array to progarm args
      -- env = {}, -- env var table
    },
    {
      type = 'go',
      name = 'Debug Go tests',
      request = 'launch',
      mode = 'test',
      program = get_file('Pkg to debug: ', 'pkg'),
      args = {}, -- array to progarm args
      -- env = {}, -- env var table
    },
    {
      type = 'go',
      name = 'Debug Go executable',
      request = 'launch',
      mode = 'exec',
      trace = true,
      program = get_file('Executable to debug: '),
      args = {}, -- array to progarm args
      -- env = {}, -- env var table
    },
  }
end

--- Loads global configurations for each debugee and merges VSCode
-- `.vscode/launch.json` under current workspace.
function M.load_configs(show_notification)
  debugee_rust()
  debugee_go()
  require('dap.ext.vscode').load_launchjs()
  if show_notification then
    vim.notify('Reload DAP configurations', vim.log.levels.INFO)
  end
end

return M
