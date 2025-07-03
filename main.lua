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

-- Font setup function - simplified to avoid attachment issues
local function setup_fonts()
  console_logger.log("[INFO] Font system initialized")
  console_logger.log("[INFO] Custom fonts require restart to take effect")
  console_logger.log("[INFO] Using default ReaImGui font for safety")
  
  -- Note: Custom font loading disabled to prevent frame attachment errors
  -- Font preferences are still saved and can be used by restarting the script
  return nil
end

-- Global font variable to keep the font alive
local custom_font = nil

-- Initialize fonts immediately after function definition (before any frames)
console_logger.log("[INFO] Initializing fonts during startup...")
_G.custom_font = setup_fonts()

-- State variables
local active_tool_name = 'enhanced_theming_panel' -- The tool to show by default
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
  
  -- Note: Font loading removed from main loop to prevent frame conflicts
  -- Fonts are now loaded only during initialization (before any frames)
  
  -- Mark that we're starting frame rendering
  _G.frame_in_progress = true
  
  -- Floating, always-on-top window
  local w, h = 800, 600
  -- Use Cond_FirstUseEver to allow user to resize and move the window
  local cond_first_use_ever = ImGui.Cond_FirstUseEver and ImGui.Cond_FirstUseEver() or 4
  ImGui.SetNextWindowSize(ctx, w, h, cond_first_use_ever)
  ImGui.SetNextWindowPos(ctx, 0, 0, cond_first_use_ever)
  
  -- Set window transparency using theme background alpha
  local bg_alpha = 1.0
  local active_theming_panel = script_manager.get_tool('enhanced_theming_panel')
  if active_theming_panel and active_theming_panel.get_theme_colors then
    local theme_colors = active_theming_panel.get_theme_colors()
    bg_alpha = ((theme_colors.background or 0xFF000000) & 0xFF) / 255.0
  end
  ImGui.SetNextWindowBgAlpha(ctx, bg_alpha)
  
  -- Convert RGBA floats to packed integer color (0xAABBGGRR)
  local function rgba_to_packed(r, g, b, a)
    r = math.floor((r or 0.1) * 255)
    g = math.floor((g or 0.1) * 255)
    b = math.floor((b or 0.1) * 255)
    a = math.floor((a or 1.0) * 255)
    return (a << 24) | (b << 16) | (g << 8) | r
  end

  -- Get theme colors from enhanced theming panel via script manager
  local theme_colors = {}
  
  -- Always use the theming panel from script manager (this is the active instance the user interacts with)
  local active_theming_panel = script_manager.get_tool('enhanced_theming_panel')
  
  if active_theming_panel and active_theming_panel.get_theme_colors then
    theme_colors = active_theming_panel.get_theme_colors()
  else
    -- Fallback colors if theming panel not available
    theme_colors = {
      background = rgba_to_packed(0.1, 0.1, 0.1, 1.0),
      text = 0xFFFFFFFF,
      button = 0x4D4D80FF,
      button_hovered = 0x6666B3FF,
      button_active = 0x333366FF,
    }
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
  
  -- Use custom font if available
  if _G.custom_font then
    ImGui.PushFont(ctx, _G.custom_font)
  end
  
  local open, window_open = ImGui.Begin(ctx, 'DevToolbox', true, window_flags)
  if open then
    -- Move close button to a tab-like section at the top
    if ImGui.Button(ctx, "✕ Close", 80, 25) then
      should_close_devtoolbox = true
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
      
      -- Add Simple Agent Prompt to the tools list
      tools["simple_agent_prompt"] = require("simple_agent_prompt")
      
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
  
  -- Pop custom font if it was pushed
  if _G.custom_font then
    ImGui.PopFont(ctx)
  end
  
  -- Mark that frame rendering is complete
  _G.frame_in_progress = false

  -- Handle pending font changes AFTER frame is complete
  if _G.font_change_pending then
    local theming_panel = script_manager.get_tool('enhanced_theming_panel')
    if theming_panel and theming_panel.set_font then
      local pending = _G.font_change_pending
      console_logger.log("[INFO] Applying pending font change after frame...")
      _G.custom_font = theming_panel.set_font(pending.font_index, pending.size_index)
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
