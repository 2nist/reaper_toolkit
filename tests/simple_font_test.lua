-- Simple font loading test for REAPER
-- Based on the ReaImGui font loading guide

local ctx = reaper.ImGui_CreateContext("Font Test")
local custom_font = nil

function init()
    -- Try to load a system font first
    custom_font = reaper.ImGui_CreateFont("monospace", 16)
    if custom_font then
        reaper.ImGui_AttachFont(ctx, custom_font)
        reaper.ShowConsoleMsg("Font loaded successfully\n")
    else
        reaper.ShowConsoleMsg("Font loading failed\n")
    end
end

function loop()
    if reaper.ImGui_Begin(ctx, "Font Test Window") then
        reaper.ImGui_Text(ctx, "Default font text")
        
        if custom_font then
            reaper.ImGui_PushFont(ctx, custom_font)
            reaper.ImGui_Text(ctx, "Custom monospace font text")
            reaper.ImGui_PopFont(ctx)
        else
            reaper.ImGui_Text(ctx, "Custom font not available")
        end
        
        reaper.ImGui_End(ctx)
    end
    
    reaper.defer(loop)
end

init()
loop()
