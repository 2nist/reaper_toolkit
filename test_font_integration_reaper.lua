-- REAPER Font Integration Test
-- Test the font selector panel in actual REAPER environment
-- Run this script in REAPER to verify font integration works

-- Setup paths
local script_path = debug.getinfo(1, 'S').source:match("@(.*)"):gsub("\\[^\\]*$", "")
package.path = script_path .. "\\modules\\?.lua;" .. package.path
package.path = script_path .. "\\?.lua;" .. package.path

-- Import required modules
local font_selector = require("modules.font_selector_panel")

-- REAPER ReaImGui context
local ctx = nil
local is_running = false

-- Initialize
local function init()
    if reaper.ImGui_CreateContext then
        ctx = reaper.ImGui_CreateContext("Font Integration Test")
        if ctx then
            is_running = true
            font_selector.init()
            reaper.ShowConsoleMsg("Font Integration Test: Started\n")
            return true
        else
            reaper.ShowConsoleMsg("Font Integration Test: Failed to create ImGui context\n")
            return false
        end
    else
        reaper.ShowConsoleMsg("Font Integration Test: ReaImGui not available\n")
        return false
    end
end

-- Main loop
local function loop()
    if not ctx or not is_running then
        return
    end
    
    -- Begin main window
    local window_flags = reaper.ImGui_WindowFlags_None()
    reaper.ImGui_SetNextWindowSize(ctx, 500, 400, reaper.ImGui_Cond_FirstUseEver())
    
    local visible, open = reaper.ImGui_Begin(ctx, "Font Integration Test", true, window_flags)
    
    if visible then
        reaper.ImGui_Text(ctx, "DevToolbox Font Integration Test")
        reaper.ImGui_Text(ctx, "Testing font selector panel in REAPER environment")
        reaper.ImGui_Separator(ctx)
        
        -- Test the font selector panel
        local success, error_msg = pcall(function()
            font_selector.render(ctx)
        end)
        
        if not success then
            reaper.ImGui_TextColored(ctx, 0xFF0000FF, "Error: " .. tostring(error_msg))
        end
        
        reaper.ImGui_Separator(ctx)
        
        -- Status info
        reaper.ImGui_Text(ctx, "Test Status:")
        reaper.ImGui_BulletText(ctx, "Font Selector Panel: " .. (success and "✓ Working" or "✗ Error"))
        reaper.ImGui_BulletText(ctx, "ImGui Context: ✓ Active")
        reaper.ImGui_BulletText(ctx, "Font Manager: " .. (package.loaded["modules.font_manager"] and "✓ Loaded" or "✗ Not Loaded"))
        reaper.ImGui_BulletText(ctx, "Font Config: " .. (package.loaded["font_config"] and "✓ Loaded" or "✗ Not Loaded"))
        
        -- Instructions
        reaper.ImGui_Separator(ctx)
        reaper.ImGui_Text(ctx, "Instructions:")
        reaper.ImGui_BulletText(ctx, "1. Select a font from the dropdown")
        reaper.ImGui_BulletText(ctx, "2. Choose a font size")
        reaper.ImGui_BulletText(ctx, "3. Modify preview text")
        reaper.ImGui_BulletText(ctx, "4. Toggle preview on/off")
        reaper.ImGui_BulletText(ctx, "5. Click 'Apply Font' to test font application")
        
        reaper.ImGui_End(ctx)
    end
    
    if open then
        reaper.defer(loop)
    else
        -- Cleanup
        if font_selector and font_selector.cleanup then
            font_selector.cleanup()
        end
        reaper.ImGui_DestroyContext(ctx)
        reaper.ShowConsoleMsg("Font Integration Test: Stopped\n")
    end
end

-- Start the test
if init() then
    loop()
else
    reaper.ShowMessageBox("Failed to initialize Font Integration Test.\n\nPlease check:\n1. ReaImGui is installed\n2. DevToolbox modules are in correct path", "Font Integration Test Error", 0)
end
