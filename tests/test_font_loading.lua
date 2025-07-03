-- Test font manager loading
print("=== Testing Font Manager Loading ===")

-- Test the simple font manager
local font_manager = require('modules.font_manager_simple')

if font_manager then
    print("✅ Font manager loaded successfully")
    
    -- Initialize it
    local ok, err = pcall(font_manager.init)
    if ok then
        print("✅ Font manager initialized successfully")
        
        -- Test basic functions
        local fonts = font_manager.get_available_fonts()
        print("📋 Available fonts:", #fonts)
        for i, font in ipairs(fonts) do
            print("  " .. i .. ". " .. font.name .. " (" .. (font.family or "unknown") .. ")")
        end
        
        local sizes = font_manager.get_font_sizes()
        print("📐 Available sizes:", #sizes, "sizes")
        
        local current_font, current_size = font_manager.get_current_font()
        print("🔤 Current font:", current_font and current_font.name or "none", "@ " .. current_size .. "px")
        
    else
        print("❌ Font manager initialization failed:", err)
    end
else
    print("❌ Font manager loading failed")
end

print("=== Font Manager Test Complete ===")
