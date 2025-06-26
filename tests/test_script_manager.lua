-- Automated test for script_manager module in DevToolbox
-- Run with: lua EnviREAment/enviREAment_core_lib/enhanced_virtual_reaper.lua --test tests/test_script_manager.lua

local EnhancedVirtualReaper = require('EnviREAment.enviREAment_core_lib.enhanced_virtual_reaper')
EnhancedVirtualReaper.create_environment()

local script_manager = dofile('./modules/script_manager.lua')

-- Test API
assert(type(script_manager) == 'table', 'script_manager.lua should return a table')
assert(type(script_manager.init) == 'function', 'script_manager should have an init function')
assert(type(script_manager.get_tools) == 'function', 'script_manager should have a get_tools function')

-- Test tool discovery and loading
script_manager.init('.')
local tools = script_manager.get_tools()
assert(type(tools) == 'table', 'get_tools should return a table')

-- If any tools are found, check their structure
for name, tool in pairs(tools) do
  assert(type(tool) == 'table', 'Tool ' .. name .. ' should be a table')
  assert(type(tool.draw) == 'function', 'Tool ' .. name .. ' should have a draw function')
end

print('script_manager test passed.')
