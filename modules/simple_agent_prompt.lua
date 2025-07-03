-- Simple Agent Prompt & Draft Tool for DevToolbox

local M = {}
local user_prompt = ""
local log_status = ""
local draft_script = ""

function M.draw(ctx)
    reaper.ImGui_Text(ctx, "Describe your new tool/module below:")
    local changed
    changed, user_prompt = reaper.ImGui_InputTextMultiline(
        ctx, "Prompt", user_prompt, 2000, reaper.ImGui_InputTextFlags_AllowTabInput()
    )

    -- Log prompt to file
    if reaper.ImGui_Button(ctx, "Log Prompt") then
        local dir = reaper.GetResourcePath() .. "/Scripts/devtoolbox/logs/"
        os.execute('mkdir "'..dir..'"') -- Ensure directory exists (Windows-safe)
        local f = io.open(dir .. "agent_prompt.log", "a")
        if f then
            f:write(os.date("[%Y-%m-%d %H:%M:%S] ") .. user_prompt .. "\n")
            f:close()
            log_status = "Prompt logged!"
        else
            log_status = "Failed to log prompt."
        end
    end

    -- Copy prompt for agent/AI
    reaper.ImGui_SameLine(ctx)
    if reaper.ImGui_Button(ctx, "Copy Prompt for Agent") then
        reaper.ImGui_SetClipboardText(ctx, user_prompt)
        log_status = "Prompt copied to clipboard."
    end

    -- Generate draft script
    if reaper.ImGui_Button(ctx, "Draft Lua Script") then
        draft_script = string.format("-- %s.lua\n-- %s\n-- Generated: %s\n\nlocal M = {}\n\nfunction M.init()\n    -- Setup code here\nend\n\nfunction M.draw(ctx)\n    -- ImGui/Lua UI code here\nend\n\nreturn M\n", user_prompt:gsub("[^%w_]", "_"):sub(1,32), user_prompt, os.date("%Y-%m-%d"))
        log_status = "Draft script generated below."
    end

    reaper.ImGui_SameLine(ctx)
    if draft_script ~= "" and reaper.ImGui_Button(ctx, "Copy Draft Script") then
        reaper.ImGui_SetClipboardText(ctx, draft_script)
        log_status = "Draft script copied to clipboard."
    end

    -- Status message
    if log_status ~= "" then
        reaper.ImGui_Text(ctx, log_status)
    end

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
