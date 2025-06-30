-- Test script for font manager functionality
-- This script tests the font manager module independently

local function test_font_manager()
    print("Testing Font Manager...")
    
    -- Test module loading
    local ok, font_manager = pcall(require, 'modules.font_manager')
    if not ok then
        print("❌ Failed to load font_manager:", font_manager)
        return false
    end
    print("✅ Font manager module loaded successfully")
    
    -- Test initialization
    local init_ok, init_err = pcall(font_manager.init)
    if not init_ok then
        print("❌ Failed to initialize font_manager:", init_err)
        return false
    end
    print("✅ Font manager initialized successfully")
    
    -- Test getting available fonts
    local fonts = font_manager.get_available_fonts()
    print("📋 Available fonts:")
    for i, font in ipairs(fonts) do
        print("  " .. i .. ". " .. font.name)
        if font.family then
            print("     Family: " .. font.family)
        end
        if font.path then
            print("     Path: " .. font.path)
        end
    end
    
    -- Test getting font sizes
    local sizes = font_manager.get_font_sizes()
    print("📏 Available sizes:", table.concat(sizes, ", "))
    
    -- Test font directory
    local fonts_dir = font_manager.get_fonts_directory()
    print("📁 Fonts directory:", fonts_dir)
    
    -- Test export functionality
    local export_text = font_manager.export_font_list()
    print("📤 Export preview:")
    print(export_text:sub(1, 200) .. "...")
    
    print("✅ All font manager tests passed!")
    return true
end

-- Run the test
test_font_manager()
