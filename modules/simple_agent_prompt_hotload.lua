-- /modules/simple_agent_prompt_hotload.lua
-- Agent Prompt, Script Draft, and Hot Loader for DevToolbox

local M = {}
local user_prompt = ""
local log_status = ""
local draft_script = ""
local module_basename = ""
local module_status = ""
local write_status = ""

function M.draw(ctx)
    reaper.ImGui_Text(ctx, "Describe your new tool/module:")
    local changed
    changed, user_prompt = reaper.ImGui_InputTextMultiline(
        ctx, "Prompt", user_prompt, 2000, reaper.ImGui_InputTextFlags_AllowTabInput()
    )

    -- Module name input
    changed, module_basename = reaper.ImGui_InputText(ctx, "Module Filename (no .lua, e.g. my_mod)", module_basename)
    if module_basename == "" and user_prompt ~= "" then
        -- Auto-fill from prompt for convenience
        module_basename = user_prompt:gsub("[^%w_]", "_"):sub(1, 32):lower()
    end

    -- Log prompt
    if reaper.ImGui_Button(ctx, "Log Prompt") then
        local dir = reaper.GetResourcePath() .. "/Scripts/devtoolbox/logs/"
        os.execute('mkdir "'..dir..'"') -- ensure logs folder exists
        local f = io.open(dir .. "agent_prompt.log", "a")
        if f then
            f:write(os.date("[%Y-%m-%d %H:%M:%S] ") .. user_prompt .. "\n")
            f:close()
            log_status = "Prompt logged!"
        else
            log_status = "Failed to log prompt."
        end
    end

    reaper.ImGui_SameLine(ctx)
    if reaper.ImGui_Button(ctx, "Copy Prompt for Agent") then
        reaper.ImGui_SetClipboardText()
        log_status = "Prompt copied to clipboard."
    end

    -- Generate draft script
    if reaper.ImGui_Button(ctx, "Draft Lua Script") then
        draft_script = string.format([[
-- %s.lua
-- %s
-- Generated: %s

local M = {}

function M.init()
    -- Setup code here
end

function M.draw(ctx)
    -- ImGui/Lua UI code here
end

return M
]], module_basename, user_prompt, os.date("%Y-%m-%d"))
        log_status = "Draft script generated below."
    end

    reaper.ImGui_SameLine(ctx)
    if draft_script ~= "" and reaper.ImGui_Button(ctx, "Copy Draft Script") then
        reaper.ImGui_SetClipboardText(draft_script)
        log_status = "Draft script copied to clipboard."
    end

    -- Write script to /modules/ as .lua
    if draft_script ~= "" and reaper.ImGui_Button(ctx, "Write Script to /modules/") then
        local moddir = reaper.GetResourcePath() .. "/Scripts/devtoolbox/modules/"
        os.execute('mkdir "'..moddir..'"')
        local fname = moddir .. module_basename .. ".lua"
        local f = io.open(fname, "w")
        if f then
            f:write(draft_script)
            f:close()
            write_status = "Script written to: " .. fname
        else
            write_status = "Failed to write script!"
        end
    end

    -- Refresh (hot-load) the module
    if module_basename ~= "" and reaper.ImGui_Button(ctx, "Refresh/Hot-Load This Module") then
        package.loaded["modules."..module_basename] = nil
        local ok, result = pcall(require, "modules."..module_basename)
        if ok then
            module_status = "Module '"..module_basename.."' loaded successfully!"
        else
            module_status = "Error: " .. tostring(result)
        end
    end

    -- Status messages
    if log_status ~= "" then reaper.ImGui_Text(ctx, log_status) end
    if write_status ~= "" then reaper.ImGui_Text(ctx, write_status) end
    if module_status ~= "" then reaper.ImGui_Text(ctx, module_status) end

    -- Script preview
    if draft_script ~= "" then
        reaper.ImGui_Separator(ctx)
        reaper.ImGui_Text(ctx, "---- Draft Script Preview ----")
        reaper.ImGui_InputTextMultiline(
            ctx, "Script Preview", draft_script, 3000, 
            reaper.ImGui_InputTextFlags_ReadOnly() + reaper.ImGui_InputTextFlags_AllowTabInput()
        )
    end
end

return M
