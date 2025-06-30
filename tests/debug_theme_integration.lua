-- Theme Integration Debug Script
-- Run this to test the theme integration between enhanced_theming_panel and main.lua

print("=== DevToolbox Theme Integration Debug ===")

-- Set up paths
local info = debug.getinfo(1, 'S')
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
if not script_path then script_path = './' end
package.path = script_path .. 'modules/?.lua;' .. script_path .. 'panels/?.lua;' .. package.path

-- Load modules like main.lua does
local script_manager = require 'script_manager'
local console_logger = require 'console_logger'
local theming_panel = require 'enhanced_theming_panel'

-- Initialize like main.lua does
script_manager.init(script_path)

print("\n=== Testing Direct Panel Access ===")
if theming_panel and theming_panel.get_theme_colors then
    local colors = theming_panel.get_theme_colors()
    print("Direct panel colors:")
    for name, color in pairs(colors) do
        print(string.format("  %s = 0x%08X", name, color))
    end
else
    print("❌ Direct panel access failed")
end

print("\n=== Testing Script Manager Access ===")
script_manager.reload_scripts()
script_manager.init_all()

local active_panel = script_manager.get_tool('enhanced_theming_panel')
if active_panel and active_panel.get_theme_colors then
    local colors = active_panel.get_theme_colors()
    print("Script manager panel colors:")
    for name, color in pairs(colors) do
        print(string.format("  %s = 0x%08X", name, color))
    end
else
    print("❌ Script manager panel access failed")
end

print("\n=== Testing Theme Changes ===")
print("Simulating 'Apply Dark' theme...")
if active_panel and active_panel.set_theme_colors then
    -- Simulate applying Dark theme
    local dark_colors = {
        background = 0x121212FF,
        text = 0xFFFFFFFF,
        button = 0x4D4D80FF,
        button_hovered = 0x6666B3FF,
        button_active = 0x333366FF,
    }
    active_panel.set_theme_colors(dark_colors)
    
    -- Check if the change persisted
    local new_colors = active_panel.get_theme_colors()
    print("After applying dark theme:")
    for name, color in pairs(new_colors) do
        print(string.format("  %s = 0x%08X", name, color))
    end
    
    if new_colors.background == 0x121212FF then
        print("✅ Theme change successful!")
    else
        print("❌ Theme change failed - colors didn't update")
    end
else
    print("❌ Cannot test theme changes - set_theme_colors not available")
end

print("\n=== Integration Test Complete ===")
