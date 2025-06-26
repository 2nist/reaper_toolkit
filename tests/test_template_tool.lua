-- Automated test for template_tool in DevToolbox
-- Run with: lua EnviREAment/enviREAment_core_lib/enhanced_virtual_reaper.lua --test tests/test_template_tool.lua

local EnhancedVirtualReaper = require('EnviREAment.enviREAment_core_lib.enhanced_virtual_reaper')
EnhancedVirtualReaper.create_environment()

local tool = dofile('./scripts/template_tool.lua')
assert(type(tool) == 'table', 'template_tool.lua should return a table')
assert(type(tool.draw) == 'function', 'template_tool.lua should have a draw function')

-- Simulate a draw call (pass a mock context)
local ok, err = pcall(tool.draw, {})
assert(ok, 'Calling draw() should not error: ' .. tostring(err))

print('template_tool test passed.')
