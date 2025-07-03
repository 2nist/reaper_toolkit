-- Debug font system
-- This script helps debug font loading issues

-- Simple test to check if font loading works
local function test_font_loading()
    print("=== Font System Debug ===")
    
    -- Check if REAPER is available
    if not reaper then
        print("ERROR: REAPER not available")
        return
    end
    
    -- Check theme file
    local theme_file_path = reaper.GetResourcePath() .. "/devtoolbox_theme.txt"
    print("Theme file path: " .. theme_file_path)
    
    local file = io.open(theme_file_path, "r")
    if file then
        print("Theme file contents:")
        for line in file:lines() do
            print("  " .. line)
        end
        file:close()
    else
        print("Theme file not found or cannot be opened")
    end
    
    -- Check fonts directory
    local script_path = "/Users/Matthew/devtoolbox-reaper-master/"
    local dymo_path = script_path .. "fonts/Dymo.ttf"
    print("Dymo font path: " .. dymo_path)
    
    local font_file = io.open(dymo_path, "r")
    if font_file then
        print("✓ Dymo font file exists")
        font_file:close()
    else
        print("✗ Dymo font file not found")
    end
    
    print("=== End Debug ===")
end

test_font_loading()
