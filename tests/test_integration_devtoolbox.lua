-- Integration test for DevToolbox: load main, simulate tool selection, check UI state and log output
-- Run with: lua EnviREAment/enviREAment_core_lib/enhanced_virtual_reaper.lua --test tests/test_integration_devtoolbox.lua

local EnhancedVirtualReaper = require('EnviREAment.enviREAment_core_lib.enhanced_virtual_reaper')
EnhancedVirtualReaper.create_environment()

-- Load main.lua as a module to ensure shared module instances
local ok, main_module = pcall(require, 'main')
assert(ok, 'main.lua should load without error: ' .. tostring(main_module))

-- Get modules from the main script to ensure shared state
local script_manager = main_module.script_manager
local logger = main_module.console_logger

-- Simulate selecting each tool and calling its draw function
local tools = script_manager.get_tools()

for name, tool in pairs(tools) do
  assert(type(tool.draw) == 'function', 'Tool ' .. name .. ' should have a draw function')
  local ok_draw, err_draw = pcall(tool.draw, {})
  assert(ok_draw, 'Drawing tool ' .. name .. ' should not error: ' .. tostring(err_draw))
  logger.log('Integration: drew tool ' .. name)
end

-- Check that log output contains expected entries
local messages = logger.get_messages()
local found = false
for _, msg in ipairs(messages) do
  if msg:find('Integration: drew tool') then found = true break end
end
assert(found, 'Log should contain integration draw messages')

print('Integration test passed. UI state exercised and log output verified.')
