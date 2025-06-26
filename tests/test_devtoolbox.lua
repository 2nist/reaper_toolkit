-- Automated tests for DevToolbox scripts using EnviREAment
-- Run with: lua EnviREAment/enviREAment_core_lib/enhanced_virtual_reaper.lua --test tests/test_devtoolbox.lua

local EnhancedVirtualReaper = require('EnviREAment.enviREAment_core_lib.enhanced_virtual_reaper')
EnhancedVirtualReaper.create_environment()

-- Load main.lua and check for errors
local ok, err = pcall(dofile, './main.lua')
assert(ok, 'DevToolbox main.lua should load without error. Error: ' .. tostring(err))

print('All DevToolbox tests passed.')
