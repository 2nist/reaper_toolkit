-- REAPER DevToolbox
-- Main entry point. Run this script from the REAPER Action List.
--
-- This script sets up a development environment for creating and testing
-- other ReaImGui scripts (tools/modules) for REAPER.

-- Set up package paths to find our modules and scripts
local info = debug.getinfo(1, 'S')
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
local reaimgui_path_segment = ''
if reaper.ImGui_GetBuiltinPath then
    reaimgui_path_segment = reaper.ImGui_GetBuiltinPath() .. '/?.lua;'
end
package.path = reaimgui_path_segment .. script_path .. 'modules/?.lua;' .. script_path .. 'scripts/?.lua;' .. package.path

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
end

-- Load core modules
local script_manager = require 'script_manager'
local console_logger = require 'console_logger'
local theming_panel = require 'theming_panel'
local demo -- for the demo window, loaded on demand

-- Initialize script manager with the correct path
-- Initialize the script manager with the base path so it can locate and manage tools/scripts
script_manager.init(script_path)


-- Create a unique context for our toolbox
local ctx = ImGui.CreateContext('REAPER DevToolbox')

-- State variables
local active_tool_name = 'config_panel' -- The tool to show by default
local show_demo_window = false

-- Enhanced logging to a file

local log_file_path = os.getenv("HOME") .. '/Desktop/devtoolbox_log.txt'
local log_file = io.open(log_file_path, 'a')
if reaper and reaper.ShowConsoleMsg then
  reaper.ShowConsoleMsg("[DevToolbox] main.lua started\n")
end

local function log_message(message)
  if log_file then
    log_file:write(os.date('%Y-%m-%d %H:%M:%S') .. ' - ' .. message .. '\n')
    log_file:flush()
  end
end

-- EARLY DEBUG LOGGING
log_message('[DEBUG] DevToolbox main.lua script started')
log_message('[DEBUG] _TEST_ENV=' .. tostring(_TEST_ENV))

-- Watchdog timer to prevent infinite loops
local watchdog_start_time = os.time()
local watchdog_timeout = 10 -- seconds

-- Main GUI loop
local function loop()
  -- Floating, always-on-top window
  local w, h = 800, 600
  ImGui.SetNextWindowSize(ctx, w, h, 1)
  ImGui.SetNextWindowPos(ctx, 0, 0, 1)
  -- Use the theme color from theming_panel if available
  local bg = theming_panel.get_theme_color and theming_panel.get_theme_color() or {0.1, 0.1, 0.1, 1.0}
  ImGui.SetNextWindowBgAlpha(ctx, bg[4] or 1.0)
  -- Convert RGBA floats to packed integer color (0xAABBGGRR)
  local function rgba_to_packed(r, g, b, a)
    r = math.floor((r or 0.1) * 255)
    g = math.floor((g or 0.1) * 255)
    b = math.floor((b or 0.1) * 255)
    a = math.floor((a or 1.0) * 255)
    return (a << 24) | (b << 16) | (g << 8) | r
  end
  ImGui.PushStyleColor(ctx, ImGui.Col_WindowBg, rgba_to_packed(bg[1], bg[2], bg[3], bg[4]))
 local window_flags = ImGui.WindowFlags_NoDocking | (1 << 8) -- Only AlwaysOnTop, no AutoResize/NoMove
  local open, window_open = ImGui.Begin(ctx, 'DevToolbox', true, window_flags)
  log_message("[DEBUG] loop: open=" .. tostring(open) .. ", window_open=" .. tostring(window_open) .. ", _TEST_ENV=" .. tostring(_TEST_ENV))
  if open then
    -- Large, obvious message for visibility test
    ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xFF00FFFF) -- Cyan
    ImGui.Text(ctx, "REAPER DEVTOOLBOX WINDOW VISIBLE")
    ImGui.PopStyleColor(ctx)
    ImGui.Separator(ctx)
    -- If theming_panel is the active tool, draw it and apply color
    if active_tool_name == 'theming_panel' then
      theming_panel.draw(ctx)
      ImGui.Separator(ctx)
    end
    -- ...existing code for panels...
    ImGui.PopStyleColor(ctx, 1) -- Pop Col_WindowBg
    if ImGui.BeginChild(ctx, 'script_runner', 250, -180, ImGui.ChildFlags_Border) then
      ImGui.Text(ctx, "Script Runner")
      ImGui.Separator(ctx)
      local tools = script_manager.get_tools()
      for name, tool in pairs(tools) do
        ImGui.PushID(ctx, name)
        if ImGui.Button(ctx, "Run##"..name, 80) then
          local ok, err = pcall(function()
            if tool and tool.draw then tool.draw(ctx) end
          end)
          if not ok then
            console_logger.log("[ERROR] Failed to run script '"..name.."': "..tostring(err))
          else
            console_logger.log("[INFO] Ran script '"..name.."'")
          end
        end
        ImGui.SameLine(ctx)
        if ImGui.Selectable(ctx, name, name == active_tool_name) then
          active_tool_name = name
        end
        ImGui.PopID(ctx)
      end
      ImGui.EndChild(ctx)
    end
    ImGui.SameLine(ctx)
    -- Main content area for the selected tool
    if ImGui.BeginChild(ctx, 'content', 0, -180, ImGui.ChildFlags_Border) then
      ImGui.Text(ctx, active_tool_name)
      ImGui.Separator(ctx)
      local tool = script_manager.get_tool(active_tool_name)
      if tool and tool.draw then
        local ok, err = pcall(tool.draw, ctx)
        if not ok then
          ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xFF2222FF)
          ImGui.Text(ctx, "Error running tool: " .. tostring(err))
          ImGui.PopStyleColor(ctx)
        end
      else
        ImGui.Text(ctx, "Could not load tool: " .. tostring(active_tool_name))
      end
      ImGui.EndChild(ctx)
    end
    -- Copyable Console Log Panel
    if ImGui.BeginChild(ctx, 'console_area', 0, 180, ImGui.ChildFlags_Border) then
      ImGui.Text(ctx, "Console Log")
      ImGui.SameLine(ctx)
      if ImGui.Button(ctx, "Clear") then console_logger.clear() end
      ImGui.SameLine(ctx)
      if ImGui.Button(ctx, "Copy All") then
        local log = table.concat(console_logger.get_messages(), "\n")
        ImGui.SetClipboardText(ctx, log)
      end
      ImGui.Separator(ctx)
      local log = table.concat(console_logger.get_messages(), "\n")
      ImGui.InputTextMultiline(ctx, "##console_log", log, -1, -1, 0x800) -- ReadOnly
      ImGui.EndChild(ctx)
    end
    ImGui.End(ctx)
  end


  -- Enhanced logging for debugging
  log_message("[DEBUG] show_demo_window: " .. tostring(show_demo_window))
  log_message("[DEBUG] active_tool_name: " .. tostring(active_tool_name))
  log_message("[DEBUG] watchdog: now=" .. tostring(os.time()) .. ", start=" .. tostring(watchdog_start_time) .. ", timeout=" .. tostring(watchdog_timeout))

  -- Check watchdog timer
  if os.time() - watchdog_start_time > watchdog_timeout then
    log_message("[ERROR] Watchdog timer triggered. Exiting loop to prevent freeze.")
    window_open = false
  end

  -- Keep the script running if the window is visible
  if window_open and not _TEST_ENV then
    reaper.defer(loop)
  else
    -- Cleanup when the window is closed
    log_message("[DEBUG] Shutting down all scripts.")
    script_manager.shutdown_all()
    if log_file then log_file:close() end
  end
end

-- Initial load and setup
script_manager.reload_scripts()
script_manager.init_all()


log_message('[DEBUG] About to enter main loop, _TEST_ENV=' .. tostring(_TEST_ENV))
if not _TEST_ENV then
  log_message('[DEBUG] Calling reaper.defer(loop)')
  reaper.defer(loop)
else
  log_message('[DEBUG] Not entering main loop due to _TEST_ENV')
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
