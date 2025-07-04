-- REAPER DevToolbox
-- Main entry point. Run this script from the REAPER Action List.
--
-- This script sets up a development environment for creating and testing
-- other ReaImGui scripts (tools/modules) for REAPER.

-- Set up package paths to find our modules and scripts
local info = debug.getinfo(1, 'S')
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
local reaimgui_path_segment = ''
if reaper and reaper.ImGui_GetBuiltinPath then
    reaimgui_path_segment = reaper.ImGui_GetBuiltinPath() .. '/?.lua;'
end
package.path = reaimgui_path_segment .. script_path .. 'modules/?.lua;' .. script_path .. 'panels/?.lua;' .. script_path .. 'utils/?.lua;' .. package.path

-- Check for ReaImGui

-- Compatibility shim: use reaper.ImGui_* if available (EnviREAment), else require 'imgui'
-- Bitwise OR helper for flags (Lua 5.3+)
local function bor(a, b) return (a | b) end
local ImGui
if reaper and reaper.ImGui_CreateContext then
  ImGui = setmetatable({}, {
    __index = function(t, k)
      local v = reaper["ImGui_" .. k]
      if v ~= nil then return v end
      return rawget(t, k)
    end
  })
  -- Provide missing constants for compatibility
  ImGui.Cond_Once = type(reaper.ImGui_Cond_Once) == "number" and reaper.ImGui_Cond_Once or 1
  ImGui.WindowFlags_MenuBar = type(reaper.ImGui_WindowFlags_MenuBar) == "number" and reaper.ImGui_WindowFlags_MenuBar or 16
  ImGui.ChildFlags_Border = type(reaper.ImGui_ChildFlags_Border) == "number" and reaper.ImGui_ChildFlags_Border or 2
  ImGui.WindowFlags_NoDocking = type(reaper.ImGui_WindowFlags_NoDocking) == "number" and reaper.ImGui_WindowFlags_NoDocking or 8192
  ImGui.Col_Text = type(reaper.ImGui_Col_Text) == "number" and reaper.ImGui_Col_Text or 0
  ImGui.Col_WindowBg = type(reaper.ImGui_Col_WindowBg) == "number" and reaper.ImGui_Col_WindowBg or 2
  ImGui.Col_Button = type(reaper.ImGui_Col_Button) == "number" and reaper.ImGui_Col_Button or 21
else
  ImGui = require 'imgui' '0.9.2'
  if not ImGui then
    reaper.MB("ReaImGui not found. Please install ReaImGui from ReaPack.", "Error", 0)
    return
  end
  -- Provide missing constants for compatibility
  ImGui.Cond_Once = ImGui.Cond_Once or 1
  ImGui.WindowFlags_MenuBar = ImGui.WindowFlags_MenuBar or 16
  ImGui.ChildFlags_Border = ImGui.ChildFlags_Border or 2
  ImGui.WindowFlags_NoDocking = ImGui.WindowFlags_NoDocking or 8192
  ImGui.Col_Text = ImGui.Col_Text or 0
  ImGui.Col_WindowBg = ImGui.Col_WindowBg or 2
  ImGui.Col_Button = ImGui.Col_Button or 21
  ImGui.WindowFlags_NoDocking = ImGui.WindowFlags_NoDocking or 8192
  ImGui.Col_Text = ImGui.Col_Text or 0
end

-- Load core modules
local script_manager = require 'script_manager'
local console_logger = require 'console_logger'
local demo -- for the demo window, loaded on demand

-- Initialize script manager with the correct path
-- Initialize the script manager with the base path so it can locate and manage tools/scripts
script_manager.init(script_path)


-- Create a unique context for our toolbox

local ctx = ImGui.CreateContext('REAPER DevToolbox')

-- Set up global variables
_G.ctx = ctx
_G.ImGui = ImGui
_G.frame_in_progress = false

-- Font setup and attachment must happen BEFORE any ImGui frame is started

local function setup_fonts_early()
  console_logger.log("[INFO] Font system temporarily simplified for debugging...")
  local theme_file_path = reaper.GetResourcePath() .. "/devtoolbox_theme.txt"
  local file = io.open(theme_file_path, "r")
  if file then
    local font_index, font_size_index
    for line in file:lines() do
      local key, value = line:match("([^=]+)=(.+)")
      if key == "font_index" then
        font_index = tonumber(value)
      elseif key == "font_size_index" then
        font_size_index = tonumber(value)
      end
    end
    file:close()
    if font_index and font_size_index then
      console_logger.log("[INFO] Found saved font preferences: index=" .. font_index .. ", size_index=" .. font_size_index)
      local available_fonts = {
        {name = "Helvetica", description = "Clean, readable sans-serif"},
        {name = "Times New Roman", description = "Classic serif font"},
        {name = "Courier New", description = "Monospace font for code"},
        {name = "Arial", description = "Standard sans-serif"},
        {name = "Georgia", description = "Web-optimized serif"},
        {name = "Comic Sans MS", description = "Casual, friendly font"},
        {name = "Dymo", description = "Custom label font", path = script_path .. "fonts/Dymo.ttf"}
      }
      local font_sizes = {10, 11, 12, 13, 14, 15, 16, 18, 20, 22, 24}
      local selected_font = available_fonts[font_index]
      local selected_size = font_sizes[font_size_index]
      if selected_font and selected_size then
        console_logger.log("[INFO] Font preferences detected: " .. selected_font.name .. " @ " .. selected_size .. "pt")
        console_logger.log("[WARNING] Custom font loading temporarily disabled for debugging")
        console_logger.log("[INFO] Using default ReaImGui font until font system is resolved")
        return nil  -- Deliberately return nil to use default font
      end
    end
  else
    console_logger.log("[INFO] No theme file found - using default font")
  end
  console_logger.log("[INFO] Using default ReaImGui font")
  return nil
end

console_logger.log("[INFO] Initializing fonts (early, before any ImGui frame)...")
_G.custom_font = setup_fonts_early()

-- State variables
local active_tool_name = 'enhanced_agent_prompt' -- The tool to show by default
local show_demo_window = false
local should_close_devtoolbox = false -- For intentional closing
local console_expanded = true -- Track console state

-- Main GUI loop
local function loop()
  -- Handle pending font changes from the theming panel
  if _G.font_change_pending then
    console_logger.log("[INFO] Font change saved - restart script to apply")
    _G.font_change_pending = nil
  end
  
  -- Track if we pushed a font this frame (needs to be popped)
  local font_popped = false
  
  -- Note: Font loading removed from main loop to prevent frame conflicts
  -- Fonts are now loaded only during initialization (before any frames)
  
  -- Helper function to get theme colors safely
  local function get_theme_colors_safely()
    local active_theming_panel = script_manager.get_tool('enhanced_theming_panel')
    if active_theming_panel and active_theming_panel.get_theme_colors then
        local colors = active_theming_panel.get_theme_colors()
        if colors then
            return colors
        end
    end
    
    -- Fallback if panel or colors are not available
    console_logger.log("[WARNING] Could not get theme colors from panel. Using fallback colors.")
    return {
        background = 0x1A1A1AFF, -- AABBGGRR format
        text = 0xFFFFFFFF,
        button = 0x4D4D80FF,
        button_hovered = 0x6666B3FF,
        button_active = 0x333366FF,
    }
  end

  -- Mark that we're starting frame rendering
  _G.frame_in_progress = true
  
  -- Floating, always-on-top window
  local w, h = 800, 600
  -- Use Cond_FirstUseEver to allow user to resize and move the window
  local cond_first_use_ever = ImGui.Cond_FirstUseEver and ImGui.Cond_FirstUseEver() or 4
  ImGui.SetNextWindowSize(ctx, w, h, cond_first_use_ever)
  ImGui.SetNextWindowPos(ctx, 0, 0, cond_first_use_ever)
  
  -- Get theme colors once for this frame
  local theme_colors = get_theme_colors_safely()

  -- Set window transparency using theme background alpha
  local bg_alpha = ((theme_colors.background or 0xFF000000) & 0xFF) / 255.0
  ImGui.SetNextWindowBgAlpha(ctx, bg_alpha)
  
  -- Convert RGBA floats to packed integer color (0xAABBGGRR)
  local function rgba_to_packed(r, g, b, a)
    r = math.floor((r or 0.1) * 255)
    g = math.floor((g or 0.1) * 255)
    b = math.floor((b or 0.1) * 255)
    a = math.floor((a or 1.0) * 255)
    return (a << 24) | (b << 16) | (g << 8) | r
  end

  -- Apply comprehensive theme colors
  local col_window_bg = type(ImGui.Col_WindowBg) == "function" and ImGui.Col_WindowBg() or 2
  local col_text = type(ImGui.Col_Text) == "function" and ImGui.Col_Text() or 0
  local col_button = type(ImGui.Col_Button) == "function" and ImGui.Col_Button() or 21
  local col_button_hovered = type(ImGui.Col_ButtonHovered) == "function" and ImGui.Col_ButtonHovered() or 22
  local col_button_active = type(ImGui.Col_ButtonActive) == "function" and ImGui.Col_ButtonActive() or 23
  
  -- Push all theme colors
  ImGui.PushStyleColor(ctx, col_window_bg, theme_colors.background)
  ImGui.PushStyleColor(ctx, col_text, theme_colors.text)
  ImGui.PushStyleColor(ctx, col_button, theme_colors.button)
  ImGui.PushStyleColor(ctx, col_button_hovered, theme_colors.button_hovered)
  ImGui.PushStyleColor(ctx, col_button_active, theme_colors.button_active)
  
  local window_flags = ImGui.WindowFlags_NoDocking | (1 << 8) -- Only AlwaysOnTop, no AutoResize/NoMove
  
  local open, window_open = ImGui.Begin(ctx, 'DevToolbox', true, window_flags)
  if open then
    -- Font system temporarily disabled for debugging
    -- Using default ReaImGui fonts until custom font loading is resolved
    
    -- Move close button to a tab-like section at the top
    if ImGui.Button(ctx, "✕ Close", 80, 25) then
      should_close_devtoolbox = true
    end
    ImGui.SameLine(ctx)
    if ImGui.Button(ctx, "🔄 Reload", 80, 25) then
      console_logger.log("[INFO] Manual reload triggered")
      script_manager.reload_scripts()
      script_manager.init_all()
      console_logger.log("[INFO] All panels reloaded!")
    end
    ImGui.SameLine(ctx)
    ImGui.TextDisabled(ctx, "DevToolbox v1.0")
    
    ImGui.Separator(ctx)
    -- Enhanced theming panel creates its own window, so no special handling needed here
    -- ...existing code for panels...
    -- Calculate console height to adjust main content area
    local console_height = console_expanded and 145 or 25 -- 145 when expanded, 25 when collapsed
    
    if ImGui.BeginChild(ctx, 'panel_selector', 250, -console_height, ImGui.ChildFlags_Border) then
      ImGui.Text(ctx, "UI Panels")
      ImGui.Separator(ctx)
      local tools = script_manager.get_tools()
      
      -- Add Enhanced Agent Prompt to the tools list
      tools["enhanced_agent_prompt"] = require("enhanced_agent_prompt")
      
      -- Sort panel names for consistent ordering
      local sorted_names = {}
      for name in pairs(tools) do
        table.insert(sorted_names, name)
      end
      table.sort(sorted_names)
      
      for _, name in ipairs(sorted_names) do
        local tool = tools[name]
        ImGui.PushID(ctx, name)
        
        -- Panel selection button - makes it the active panel
        if ImGui.Button(ctx, "Select##"..name, 60) then
          active_tool_name = name
          console_logger.log("[INFO] Selected panel '"..name.."'")
        end
        ImGui.SameLine(ctx)
        
        -- Panel name - also selectable (display full name)
        local is_selected = (name == active_tool_name)
        if ImGui.Selectable(ctx, name, is_selected) then
          active_tool_name = name
          console_logger.log("[INFO] Selected panel '"..name.."'")
        end
        
        ImGui.PopID(ctx)
      end
      ImGui.EndChild(ctx)
    end
    ImGui.SameLine(ctx)
    -- Main content area for the selected panel
    if ImGui.BeginChild(ctx, 'content', 0, -console_height, ImGui.ChildFlags_Border) then
      ImGui.Text(ctx, active_tool_name)
      ImGui.Separator(ctx)
      
      local panel = script_manager.get_tool(active_tool_name)
      
      if panel and panel.draw then
        local ok, err = pcall(panel.draw, ctx)
        if not ok then
          console_logger.log("Error running panel: " .. tostring(err))
          ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xFF2222FF)
          ImGui.Text(ctx, "Error running panel: " .. tostring(err))
          ImGui.PopStyleColor(ctx)
        end
      else
        ImGui.Text(ctx, "Could not load panel: " .. tostring(active_tool_name))
      end
      ImGui.EndChild(ctx)
    end
    -- Collapsible Console Log Panel
    console_expanded = ImGui.CollapsingHeader(ctx, "Console Log", console_expanded)
    if console_expanded then
        -- When expanded, show a reasonable console window (120px height)
        if ImGui.BeginChild(ctx, 'console_area', 0, 120, ImGui.ChildFlags_Border) then
            -- Control buttons at the top
            if ImGui.Button(ctx, "Clear") then console_logger.clear() end
            ImGui.SameLine(ctx)
            if ImGui.Button(ctx, "Copy All") then
                local log = table.concat(console_logger.get_messages(), "\n")
                ImGui.SetClipboardText(ctx, log)
            end
            ImGui.Separator(ctx)
            -- Console log content with scrolling
            local log = table.concat(console_logger.get_messages(), "\n")
            ImGui.InputTextMultiline(ctx, "##console_log", log, -1, -1, 0x800) -- ReadOnly, use remaining space
            ImGui.EndChild(ctx)
        end
    end
    
    -- Pop the 5 style colors that were pushed at the beginning of the window
    ImGui.PopStyleColor(ctx, 5)
    
    ImGui.End(ctx)
  end
  
  -- Mark that frame rendering is complete
  _G.frame_in_progress = false

  -- Handle pending font changes AFTER frame is complete
  if _G.font_change_pending then
    console_logger.log("[INFO] Processing pending font change...")
    
    local theming_panel = script_manager.get_tool('enhanced_theming_panel')
    if theming_panel and theming_panel.get_current_font then
      -- Get the current font selection from theming panel
      local font_info = theming_panel.get_current_font()
      if font_info and font_info.font then
        console_logger.log("[INFO] Font change detected: " .. font_info.font.name .. " @ " .. font_info.size .. "pt")
        console_logger.log("[INFO] Restart the script to apply the new font")
        _G.font_change_pending = nil
      end
    else
      console_logger.log("[WARNING] Could not process font change - theming panel not available")
      _G.font_change_pending = nil
    end
  end

  -- Keep the script running unless explicitly closed or in test environment
  if not should_close_devtoolbox and not _TEST_ENV then
    reaper.defer(loop)
  else
    -- Cleanup when intentionally closed or in test environment
    script_manager.shutdown_all()
  end
end

-- Initial load and setup
script_manager.reload_scripts()
script_manager.init_all()

-- Additional global variables for theming panel
_G.console_logger = console_logger
_G.font_change_pending = nil
_G.pending_font = nil
_G.script_path = script_path

-- Initialize custom font as nil - will be set up in deferred font loading
_G.custom_font = nil

if not _TEST_ENV then
  reaper.defer(loop)
end

--
-- [API NOTE]:
-- All ImGui.BeginChild/ImGui.EndChild calls are now properly paired and wrapped in if statements.
-- Only valid ImGuiChildFlags (or none) are used for BeginChild.
-- No ImGuiWindowFlags are passed to BeginChild.
-- This ensures no mismatched Begin/End errors and no assertion failures in the UI stack.
--
-- If you add new ImGui.BeginChild calls, always:
--   1. Wrap them in an if-statement.
--   2. Call ImGui.EndChild() only if the corresponding BeginChild returned true.
--   3. Use only valid ImGuiChildFlags (or none) for the flags argument.
--
-- This pattern is now enforced throughout the DevToolbox main UI.
return { console_logger = console_logger, script_manager = script_manager }
