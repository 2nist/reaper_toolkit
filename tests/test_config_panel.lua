-- Automated test for config_panel tool in DevToolbox
-- Run with: lua EnviREAment/enviREAment_core_lib/enhanced_virtual_reaper.lua --test tests/test_config_panel.lua

local EnhancedVirtualReaper = require('EnviREAment.enviREAment_core_lib.enhanced_virtual_reaper')
EnhancedVirtualReaper.create_environment()

local tool = dofile('./scripts/config_panel.lua')
assert(type(tool) == 'table', 'config_panel.lua should return a table')
assert(type(tool.draw) == 'function', 'config_panel.lua should have a draw function')

-- Simulate a draw call (pass a mock context)
local ok, err = pcall(tool.draw, {})
assert(ok, 'Calling draw() should not error: ' .. tostring(err))

print('config_panel test passed.')
