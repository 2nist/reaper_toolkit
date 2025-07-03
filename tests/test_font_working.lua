-- Test the working font manager
print("=== Testing Working Font Manager ===")

local font_manager = require('modules.font_manager_working')

if font_manager then
    print("✅ Working font manager loaded successfully")
    
    -- Initialize it
    local ok, err = pcall(font_manager.init)
    if ok then
        print("✅ Font manager initialized successfully")
        
        -- Check API availability
        print("\n--- Checking ReaImGui API ---")
        if font_manager.check_font_api then
            font_manager.check_font_api()
        end
        
        -- Test basic functions
        local fonts = font_manager.get_available_fonts()
        print("\n📋 Available fonts:", #fonts)
        for i, font in ipairs(fonts) do
            print("  " .. i .. ". " .. font.name .. " (" .. (font.family or "unknown") .. ")")
            if font.path then
                print("      Path:", font.path)
            end
        end
        
        local sizes = font_manager.get_font_sizes()
        print("\n📐 Available sizes:", #sizes, "sizes")
        
        local current_font, current_size = font_manager.get_current_font()
        print("\n🔤 Current font:", current_font and current_font.name or "none", "@ " .. current_size .. "px")
        
    else
        print("❌ Font manager initialization failed:", err)
    end
else
    print("❌ Working font manager loading failed")
end

print("\n=== Working Font Manager Test Complete ===")
