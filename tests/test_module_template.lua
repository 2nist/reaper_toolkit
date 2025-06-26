-- Template for future DevToolbox module tests
-- Copy and adapt this file for each new module/tool
-- Run with: lua EnviREAment/enviREAment_core_lib/enhanced_virtual_reaper.lua --test tests/test_module_template.lua

local EnhancedVirtualReaper = require('EnviREAment.enviREAment_core_lib.enhanced_virtual_reaper')
EnhancedVirtualReaper.create_environment()

-- Replace with your module path
local module = dofile('./modules/your_module.lua')

assert(type(module) == 'table', 'Module should return a table')
-- Add assertions for expected functions/fields
-- assert(type(module.init) == 'function', 'Module should have an init function')
-- assert(type(module.draw) == 'function', 'Module should have a draw function')

-- Optionally, call main functions and check for side effects
-- local ok, err = pcall(module.draw, {})
-- assert(ok, 'Calling draw() should not error: ' .. tostring(err))

print('Module template test passed.')
