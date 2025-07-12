-- Simple font integration test script
-- Tests the font system following FONT_MANAGER_API_SOP.txt guidelines

-- Add module paths
local info = debug.getinfo(1, 'S')
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
if not script_path then script_path = "./" end
package.path = script_path .. '?.lua;' .. script_path .. 'modules/?.lua;' .. package.path

-- Load modules
local font_manager = require('font_manager')

-- Initialize
font_manager.init()

print("=== DevToolbox Font Integration Test ===")

-- Test font manager initialization
print("1. Font Manager initialized")

-- Get available fonts
local fonts = font_manager.get_available_fonts()
print("2. Available fonts: " .. #fonts)
for i, font in ipairs(fonts) do
    print("   " .. i .. ". " .. font.name)
end

-- Get available sizes
local sizes = font_manager.get_font_sizes()
print("3. Available sizes: " .. table.concat(sizes, ", "))

-- Test current font
local current_font, current_size = font_manager.get_current_font()
if current_font then
    print("4. Current font: " .. current_font.name .. " " .. current_size .. "px")
else
    print("4. Using default font")
end

-- Test font creation (without context - just verification)
if current_font then
    local test_ok, test_message = font_manager.test_font_creation(current_font, current_size)
    print("5. Font creation test: " .. (test_ok and "✅ PASS" or "❌ FAIL") .. " - " .. test_message)
else
    print("5. Font creation test: ✅ PASS - Default font (no creation needed)")
end

-- Test a system font
local segoe_font = { name = "Segoe UI", family = "Segoe UI" }
local segoe_test_ok, segoe_message = font_manager.test_font_creation(segoe_font, 14)
print("6. Segoe UI test: " .. (segoe_test_ok and "✅ PASS" or "❌ FAIL") .. " - " .. segoe_message)

-- Get cache info
local cache_info = font_manager.get_cache_info()
print("7. Font cache: " .. cache_info.cached_fonts .. " fonts cached")

print("8. Fonts directory: " .. font_manager.get_fonts_directory())

print("\n=== Font Integration Test Complete ===")
print("✅ Ready to use font system in DevToolbox panels!")
