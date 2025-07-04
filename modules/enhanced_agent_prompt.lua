-- Enhanced Agent Prompt - Efficient Tool Generator for DevToolbox

local M = {}
local user_prompt = ""
local log_status = ""
local tool_name = ""
local tool_type = "track_tool"
local ui_elements = {}
local generated_script = ""

-- Tool type templates
local tool_templates = {
    track_tool = {
        name = "Track Management Tool",
        apis = {"reaper.CountTracks", "reaper.GetTrack", "reaper.SetTrackColor"},
        ui = {"track list", "color picker", "mute/solo buttons"}
    },
    fx_tool = {
        name = "FX Management Tool", 
        apis = {"reaper.TrackFX_GetCount", "reaper.TrackFX_GetParam", "reaper.TrackFX_SetParam"},
        ui = {"FX list", "parameter sliders", "bypass buttons"}
    },
    automation_tool = {
        name = "Automation Helper",
        apis = {"reaper.GetEnvelopeByName", "reaper.InsertEnvelopePoint", "reaper.DeleteEnvelopePoint"},
        ui = {"envelope list", "value sliders", "time controls"}
    },
    project_tool = {
        name = "Project Utility",
        apis = {"reaper.GetProjectLength", "reaper.GetProjectName", "reaper.SaveProject"},
        ui = {"project info", "action buttons", "status display"}
    }
}

-- UI element generators
local ui_generators = {
    slider = "reaper.ImGui_SliderFloat(ctx, label, value, min, max)",
    button = "reaper.ImGui_Button(ctx, label)",
    text = "reaper.ImGui_Text(ctx, text)",
    list = "reaper.ImGui_ListBox(ctx, label, current_item, items)",
    color_picker = "reaper.ImGui_ColorEdit3(ctx, label, color)"
}

function M.draw(ctx)
    reaper.ImGui_Text(ctx, "🚀 Enhanced Tool Generator")
    reaper.ImGui_Separator(ctx)
    
    -- Tool name input
    reaper.ImGui_Text(ctx, "Tool Name:")
    local changed
    changed, tool_name = reaper.ImGui_InputText(ctx, "##tool_name", tool_name, 100)
    
    -- Tool type selection
    reaper.ImGui_Text(ctx, "Tool Type:")
    local tool_types = {"track_tool", "fx_tool", "automation_tool", "project_tool"}
    for i, key in ipairs(tool_types) do
        local template = tool_templates[key]
        if reaper.ImGui_RadioButton(ctx, template.name, tool_type == key) then
            tool_type = key
        end
        if i % 2 == 0 then reaper.ImGui_SameLine(ctx) end
    end
    
    -- Description input (smaller, more focused)
    reaper.ImGui_Text(ctx, "Specific Requirements:")
    changed, user_prompt = reaper.ImGui_InputTextMultiline(
        ctx, "##prompt", user_prompt, 1000, 
        reaper.ImGui_InputTextFlags_AllowTabInput()
    )
    
    -- Generate button (does everything at once)
    if reaper.ImGui_Button(ctx, "🎯 Generate & Test Tool", 200, 40) then
        generated_script = generate_complete_script()
        save_and_reload_tool()
        log_status = "Tool generated and ready for testing!"
    end
    
    reaper.ImGui_SameLine(ctx)
    if reaper.ImGui_Button(ctx, "📋 Copy for AI", 120, 40) then
        local ai_prompt = create_ai_prompt()
        reaper.ImGui_SetClipboardText(ctx, ai_prompt)
        log_status = "AI prompt copied - paste into ChatGPT/Claude"
    end
    
    -- Status and preview
    if log_status ~= "" then
        reaper.ImGui_Text(ctx, "Status: " .. log_status)
    end
    
    if generated_script ~= "" then
        reaper.ImGui_Separator(ctx)
        reaper.ImGui_Text(ctx, "Generated Script Preview:")
        reaper.ImGui_InputTextMultiline(
            ctx, "##script_preview", generated_script, 2000,
            reaper.ImGui_InputTextFlags_ReadOnly()
        )
    end
end

function generate_complete_script()
    local template = tool_templates[tool_type]
    local script_name = tool_name:gsub("[^%w_]", "_"):lower()
    
    local script = string.format([[-- %s.lua
-- %s
-- Generated: %s
-- Type: %s

local M = {}
local console_logger = _G.console_logger

function M.init()
    console_logger.log("Initializing %s")
end

function M.draw(ctx)
    reaper.ImGui_Text(ctx, "%s")
    reaper.ImGui_Separator(ctx)
    
    -- Tool-specific implementation based on type
%s
    
    -- User requirements implementation
    -- %s
end

return M
]], script_name, user_prompt, os.date("%Y-%m-%d"), template.name, 
    tool_name, tool_name, generate_tool_implementation(), user_prompt)
    
    return script
end

function generate_tool_implementation()
    local template = tool_templates[tool_type]
    local impl = ""
    
    if tool_type == "track_tool" then
        impl = [[    
    -- Track management implementation
    local track_count = reaper.CountTracks(0)
    reaper.ImGui_Text(ctx, "Tracks: " .. track_count)
    
    for i = 0, track_count - 1 do
        local track = reaper.GetTrack(0, i)
        if track then
            local _, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", false)
            if reaper.ImGui_Button(ctx, track_name .. "##" .. i) then
                -- Track action here
                console_logger.log("Selected track: " .. track_name)
            end
        end
    end]]
    elseif tool_type == "fx_tool" then
        impl = [[
    -- FX management implementation  
    local selected_track = reaper.GetSelectedTrack(0, 0)
    if selected_track then
        local fx_count = reaper.TrackFX_GetCount(selected_track)
        reaper.ImGui_Text(ctx, "FX Count: " .. fx_count)
        
        for i = 0, fx_count - 1 do
            local _, fx_name = reaper.TrackFX_GetFXName(selected_track, i, "")
            reaper.ImGui_Text(ctx, fx_name)
        end
    else
        reaper.ImGui_Text(ctx, "No track selected")
    end]]
    end
    
    return impl
end

function create_ai_prompt()
    local template = tool_templates[tool_type]
    return string.format([[Create a REAPER ReaImGui script with these specifications:

TOOL TYPE: %s
REQUIREMENTS: %s

Technical Requirements:
- Use reaper.ImGui_* functions for UI
- Include these REAPER APIs: %s
- Return module with init() and draw(ctx) functions  
- Add error handling with pcall()
- Log debug info with console_logger.log()
- Save settings to REAPER resource folder if needed

UI Elements to include: %s

Make it production-ready with proper error handling and user feedback.]], 
        template.name, user_prompt, 
        table.concat(template.apis, ", "),
        table.concat(template.ui, ", "))
end

function save_and_reload_tool()
    if tool_name == "" then 
        log_status = "Error: Please enter a tool name"
        return 
    end
    
    local script_name = tool_name:gsub("[^%w_]", "_"):lower()
    local file_path = reaper.GetResourcePath() .. "/Scripts/devtoolbox/panels/" .. script_name .. ".lua"
    
    -- Ensure directory exists
    local dir = reaper.GetResourcePath() .. "/Scripts/devtoolbox/panels/"
    os.execute('mkdir -p "' .. dir .. '"')
    
    -- Save script
    local f = io.open(file_path, "w")
    if f then
        f:write(generated_script)
        f:close()
        
        -- Trigger DevToolbox reload (if function exists)
        if _G.script_manager and _G.script_manager.reload_scripts then
            _G.script_manager.reload_scripts()
            log_status = "Tool saved and DevToolbox reloaded! Check UI Panels list."
        else
            log_status = "Tool saved to: " .. file_path .. " (restart DevToolbox to load)"
        end
    else
        log_status = "Error: Could not save script file"
    end
end

return M
