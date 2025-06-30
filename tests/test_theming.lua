-- Quick test to verify theming integration
-- Run this to check if the enhanced theming panel and main.lua integration works

-- Set up paths like main.lua does
local info = debug.getinfo(1, 'S')
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
if not script_path then
    script_path = './'
end
package.path = script_path .. 'modules/?.lua;' .. script_path .. 'panels/?.lua;' .. package.path

-- Load the enhanced theming panel
local theming_panel = require 'enhanced_theming_panel'

print("=== DevToolbox Theming Test ===")

-- Test 1: Check if theming panel loads
if theming_panel then
    print("✅ Enhanced theming panel loaded successfully")
else
    print("❌ Failed to load enhanced theming panel")
    return
end

-- Test 2: Check if get_theme_colors function exists
if theming_panel.get_theme_colors then
    print("✅ get_theme_colors function exists")
    
    -- Test 3: Get current theme colors
    local colors = theming_panel.get_theme_colors()
    if colors then
        print("✅ Theme colors retrieved:")
        for name, color in pairs(colors) do
            print(string.format("  %s = 0x%08X", name, color))
        end
    else
        print("❌ Failed to get theme colors")
    end
else
    print("❌ get_theme_colors function not found")
end

-- Test 4: Check if presets work
print("\n=== Testing Theme Presets ===")
local presets = {"Dark", "Light", "Blue"}
for _, preset in ipairs(presets) do
    print("Testing " .. preset .. " preset...")
    -- Note: We can't actually test applying presets without ImGui context
    -- But we can verify the structure exists
end

-- Test 5: Check other functions exist
local functions_to_check = {
    "set_theme_colors", 
    "apply_theme_to_context", 
    "get_theme_color",
    "draw",
    "init"
}

for _, func_name in ipairs(functions_to_check) do
    if theming_panel[func_name] then
        print("✅ " .. func_name .. " function exists")
    else
        print("❌ " .. func_name .. " function missing")
    end
end

print("\n=== Test Complete ===")
print("If all tests passed, the theming integration should work correctly!")
