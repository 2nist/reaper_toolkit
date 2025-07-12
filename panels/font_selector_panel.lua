-- Font Selector Panel for DevToolbox
-- Implements the FONT_MANAGER_API_SOP.txt guidelines

local font_manager = require('modules.font_manager')

local M = {}

-- Panel state
local panel_state = {
    font_list = {},
    size_list = {},
    selected_font_index = 1,
    selected_size_index = 8, -- Default to 14px
    preview_text = "The quick brown fox jumps over the lazy dog 0123456789",
    show_preview = true,
    status_message = "",
    current_font_instance = nil
}

function M.init()
    -- Initialize font manager
    font_manager.init()
    
    -- Get available fonts and sizes
    panel_state.font_list = font_manager.get_available_fonts()
    panel_state.size_list = font_manager.get_font_sizes()
    
    -- Find current font selection
    local current_font, current_size = font_manager.get_current_font()
    
    if current_font then
        for i, font in ipairs(panel_state.font_list) do
            if font.name == current_font.name then
                panel_state.selected_font_index = i
                break
            end
        end
    end
    
    if current_size then
        for i, size in ipairs(panel_state.size_list) do
            if size == current_size then
                panel_state.selected_size_index = i
                break
            end
        end
    end
    
    panel_state.status_message = "Font selector initialized"
end

function M.draw(ctx)
    local changed = false
    
    -- Font selection combo
    if reaper.ImGui_BeginCombo(ctx, "Font", panel_state.font_list[panel_state.selected_font_index].name) then
        for i, font in ipairs(panel_state.font_list) do
            local is_selected = (i == panel_state.selected_font_index)
            if reaper.ImGui_Selectable(ctx, font.name, is_selected) then
                panel_state.selected_font_index = i
                changed = true
            end
            -- Remove problematic SetItemDefaultFocus call
        end
        reaper.ImGui_EndCombo(ctx)
    end
    
    -- Size selection combo
    if reaper.ImGui_BeginCombo(ctx, "Size", tostring(panel_state.size_list[panel_state.selected_size_index])) then
        for i, size in ipairs(panel_state.size_list) do
            local is_selected = (i == panel_state.selected_size_index)
            if reaper.ImGui_Selectable(ctx, tostring(size), is_selected) then
                panel_state.selected_size_index = i
                changed = true
            end
            -- Remove problematic SetItemDefaultFocus call
        end
        reaper.ImGui_EndCombo(ctx)
    end
    
    reaper.ImGui_Separator(ctx)
    
    -- Apply button
    if reaper.ImGui_Button(ctx, "Apply Font") then
        local selected_font = panel_state.font_list[panel_state.selected_font_index]
        local selected_size = panel_state.size_list[panel_state.selected_size_index]
        
        -- Test font creation first (following SOP guidelines)
        local test_ok, test_message = font_manager.test_font_creation(selected_font, selected_size)
        
        if test_ok then
            -- Apply the font selection
            font_manager.set_current_font(selected_font, selected_size)
            
            -- Create font instance for preview (following SOP guidelines)
            panel_state.current_font_instance = font_manager.create_font(selected_font, selected_size, ctx)
            
            panel_state.status_message = "✅ Font applied: " .. selected_font.name .. " " .. selected_size .. "px"
        else
            panel_state.status_message = "❌ Font test failed: " .. test_message
        end
        
        changed = true
    end
    
    reaper.ImGui_SameLine(ctx)
    
    -- Reset to default button
    if reaper.ImGui_Button(ctx, "Reset to Default") then
        local default_font = { name = "Default ImGui", family = "default" }
        font_manager.set_current_font(default_font, 14)
        panel_state.current_font_instance = nil
        panel_state.status_message = "✅ Reset to default font"
        changed = true
    end
    
    reaper.ImGui_Separator(ctx)
    
    -- Preview section
    _, panel_state.show_preview = reaper.ImGui_Checkbox(ctx, "Show Preview", panel_state.show_preview)
    
    if panel_state.show_preview then
        -- Preview text input
        _, panel_state.preview_text = reaper.ImGui_InputText(ctx, "Preview Text", panel_state.preview_text)
        
        -- Preview area with custom font (following SOP guidelines for PushFont/PopFont)
        reaper.ImGui_BeginChild(ctx, "FontPreview", 0, 100, true)
        
        -- Apply custom font if available (SOP guideline implementation)
        if panel_state.current_font_instance then
            reaper.ImGui_PushFont(ctx, panel_state.current_font_instance)
        end
        
        -- Draw preview text
        reaper.ImGui_TextWrapped(ctx, panel_state.preview_text)
        
        -- Pop font if we pushed it (SOP guideline implementation)
        if panel_state.current_font_instance then
            reaper.ImGui_PopFont(ctx)
        end
        
        reaper.ImGui_EndChild(ctx)
    end
    
    reaper.ImGui_Separator(ctx)
    
    -- Status message
    if panel_state.status_message ~= "" then
        reaper.ImGui_TextWrapped(ctx, panel_state.status_message)
    end
    
    -- Font info section
    reaper.ImGui_Separator(ctx)
    reaper.ImGui_Text(ctx, "Font Information:")
    
    local current_font, current_size = font_manager.get_current_font()
    
    if current_font then
        reaper.ImGui_Text(ctx, "Current Font: " .. current_font.name)
        reaper.ImGui_Text(ctx, "Current Size: " .. current_size .. "px")
        
        if current_font.family then
            reaper.ImGui_Text(ctx, "Font Family: " .. current_font.family)
        end
        
        if current_font.path then
            reaper.ImGui_Text(ctx, "Font Path: " .. current_font.path)
        end
    else
        reaper.ImGui_Text(ctx, "Using default ImGui font")
    end
    
    -- Cache information
    local cache_info = font_manager.get_cache_info()
    reaper.ImGui_Text(ctx, "Cached Fonts: " .. cache_info.cached_fonts)
    
    if reaper.ImGui_Button(ctx, "Clear Font Cache") then
        font_manager.clear_font_cache()
        panel_state.status_message = "Font cache cleared"
    end
    
    return changed
end

return M
