-- Font Selector Panel for DevToolbox
-- Following FONT_MANAGER_API_SOP.txt guidelines
-- Provides UI for font selection, preview, and application

local font_manager = require("modules.font_manager")
local font_config = require("font_config")

local font_selector = {
    -- State
    current_font_index = 1,
    current_size = 14,
    preview_text = "The quick brown fox jumps over the lazy dog",
    show_preview = true,
    
    -- Available font sizes
    font_sizes = {8, 9, 10, 11, 12, 14, 16, 18, 20, 22, 24, 28, 32, 36, 48, 64},
    current_size_index = 6, -- Default to 14pt
    
    -- UI state
    is_initialized = false
}

-- Initialize the font selector
function font_selector.init()
    if not font_selector.is_initialized then
        -- Initialize font manager if not already done
        if font_manager and type(font_manager.init) == "function" then
            font_manager.init()
        end
        
        font_selector.is_initialized = true
        print("Font Selector Panel initialized")
    end
end

-- Get font list for combo box
local function get_font_list()
    local font_list = {}
    local index = 1
    
    if font_config and font_config.fonts then
        for _, font in ipairs(font_config.fonts) do
            table.insert(font_list, font.name)
            index = index + 1
        end
    end
    
    return font_list
end

-- Get size list for combo box
local function get_size_list()
    local size_list = {}
    for _, size in ipairs(font_selector.font_sizes) do
        table.insert(size_list, tostring(size))
    end
    return size_list
end

-- Apply selected font (following SOP guidelines)
local function apply_font(ctx)
    if not font_config or not font_config.fonts then
        return false
    end
    
    local font_info = font_config.fonts[font_selector.current_font_index]
    if not font_info then
        return false
    end
    
    local size = font_selector.font_sizes[font_selector.current_size_index] or 14
    
    -- Use font manager to push font (SOP required)
    if font_manager and type(font_manager.push_font) == "function" then
        local success = font_manager.push_font(ctx, font_info.name, size)
        if success and type(font_manager.test_font_creation) == "function" then
            -- Call test_font_creation as required by SOP
            font_manager.test_font_creation(font_info.name, size)
        end
        return success
    end
    
    return false
end

-- Pop font (following SOP guidelines)
local function pop_font(ctx)
    if font_manager and type(font_manager.pop_font) == "function" then
        font_manager.pop_font(ctx)
    end
end

-- Render the font selector panel
function font_selector.render(ctx)
    if not font_selector.is_initialized then
        font_selector.init()
    end
    
    reaper.ImGui_Text(ctx, "Font Selection")
    reaper.ImGui_Separator(ctx)
    
    -- Font combo box
    local font_list = get_font_list()
    if #font_list > 0 then
        local font_names = table.concat(font_list, "\0") .. "\0"
        local changed, new_index = reaper.ImGui_Combo(ctx, "Font Family", font_selector.current_font_index - 1, font_names)
        if changed then
            font_selector.current_font_index = new_index + 1
        end
    else
        reaper.ImGui_Text(ctx, "No fonts available")
    end
    
    -- Size combo box
    local size_list = get_size_list()
    local size_names = table.concat(size_list, "\0") .. "\0"
    local size_changed, new_size_index = reaper.ImGui_Combo(ctx, "Font Size", font_selector.current_size_index - 1, size_names)
    if size_changed then
        font_selector.current_size_index = new_size_index + 1
    end
    
    -- Preview text input
    reaper.ImGui_Text(ctx, "Preview Text:")
    local text_changed, new_text = reaper.ImGui_InputText(ctx, "##preview_text", font_selector.preview_text)
    if text_changed then
        font_selector.preview_text = new_text
    end
    
    -- Show preview toggle
    local preview_changed, new_preview = reaper.ImGui_Checkbox(ctx, "Show Preview", font_selector.show_preview)
    if preview_changed then
        font_selector.show_preview = new_preview
    end
    
    -- Apply button
    if reaper.ImGui_Button(ctx, "Apply Font") then
        apply_font(ctx)
    end
    
    -- Preview area (following SOP PushFont/PopFont pattern)
    if font_selector.show_preview then
        reaper.ImGui_Separator(ctx)
        reaper.ImGui_Text(ctx, "Preview:")
        
        -- Apply font for preview (SOP required pattern)
        local font_applied = apply_font(ctx)
        
        if font_applied then
            -- Show preview with applied font
            reaper.ImGui_Text(ctx, font_selector.preview_text)
            
            -- Pop font (SOP required)
            pop_font(ctx)
        else
            -- Fallback preview without font change
            reaper.ImGui_Text(ctx, font_selector.preview_text .. " (Font not available)")
        end
    end
    
    -- Font info display
    if font_config and font_config.fonts and font_selector.current_font_index <= #font_config.fonts then
        local font_info = font_config.fonts[font_selector.current_font_index]
        local size = font_selector.font_sizes[font_selector.current_size_index] or 14
        
        reaper.ImGui_Separator(ctx)
        reaper.ImGui_Text(ctx, "Selected Font:")
        reaper.ImGui_Text(ctx, "Name: " .. (font_info.name or "Unknown"))
        reaper.ImGui_Text(ctx, "Family: " .. (font_info.family or "Unknown"))
        reaper.ImGui_Text(ctx, "Size: " .. tostring(size) .. "px")
        
        if font_info.path then
            reaper.ImGui_Text(ctx, "Path: " .. font_info.path)
        end
    end
end

-- Cleanup function
function font_selector.cleanup()
    if font_manager and type(font_manager.cleanup) == "function" then
        font_manager.cleanup()
    end
end

-- Return the module
return font_selector
