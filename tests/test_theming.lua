-- Automated test for theming module in DevToolbox
-- Run with: lua EnviREAment/enviREAment_core_lib/enhanced_virtual_reaper.lua --test tests/test_theming.lua

local EnhancedVirtualReaper = require('EnviREAment.enviREAment_core_lib.enhanced_virtual_reaper')
EnhancedVirtualReaper.create_environment()

local theming = dofile('./modules/theming.lua')

assert(type(theming) == 'table', 'theming.lua should return a table')
assert(type(theming.apply_theme) == 'function', 'theming should have an apply_theme function')
assert(type(theming.save_theme) == 'function', 'theming should have a save_theme function')
assert(type(theming.load_theme) == 'function', 'theming should have a load_theme function')

-- Test theme application (mock context)
local ctx = {}
local ok, err = pcall(theming.apply_theme, ctx, {background = 0x000000, text = 0xFFFFFF})
assert(ok, 'apply_theme should not error: ' .. tostring(err))

print('theming test passed.')
