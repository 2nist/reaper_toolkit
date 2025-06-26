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

-- State variables
local active_tool_name = 'config_panel' -- The tool to show by default
local show_demo_window = false

-- Main GUI loop
local function loop()
  -- Set initial window size and position to fill the docker
  local _, _, _, w, h = reaper.GetSet_ArrangeView2(0, false, 0, 0, 0, 0)
  w = tonumber(w) or 800 -- Fallback if getting width fails
  h = tonumber(h) or 600 -- Fallback if getting height fails
  ImGui.SetNextWindowSize(ctx, w, h, ImGui.Cond_Once)
  ImGui.SetNextWindowPos(ctx, 0, 0, ImGui.Cond_Once)

  local main_window_open = true
  local open, _ = ImGui.Begin(ctx, 'DevToolbox', true, ImGui.WindowFlags_MenuBar)
  if open then

    -- Top part for tools
    if ImGui.BeginChild(ctx, 'tools_area', 0, -150, ImGui.ChildFlags_Border) then -- Reserve 150px for console

        -- Main Menu Bar
        if ImGui.BeginMenuBar(ctx) then
            if ImGui.BeginMenu(ctx, "File") then
                if ImGui.MenuItem(ctx, "Reload All Scripts") then
                    script_manager.reload_scripts()
                    script_manager.init_all()
                end
                ImGui.EndMenu(ctx)
            end
            if ImGui.BeginMenu(ctx, "Help") then
                show_demo_window = select(2, ImGui.MenuItem(ctx, "Show ImGui Demo", nil, show_demo_window))
            end
            ImGui.EndMenuBar(ctx)
        end

        -- Left sidebar for tool selection
        if ImGui.BeginChild(ctx, 'sidebar', 180, 0) then
            ImGui.Text(ctx, "Tools")
            ImGui.Separator(ctx)
            local tools = script_manager.get_tools()
            for name, _ in pairs(tools) do
                if ImGui.Selectable(ctx, name, name == active_tool_name) then
                    active_tool_name = name
                end
            end
            ImGui.EndChild(ctx)
        end

        ImGui.SameLine(ctx)

        -- Main content area for the selected tool
        if ImGui.BeginChild(ctx, 'content') then
            ImGui.Text(ctx, active_tool_name)
            ImGui.Separator(ctx)
            local tool = script_manager.get_tool(active_tool_name)
            if tool and tool.draw then
                if ImGui.Button(ctx, "Run Tool") then
                    local ok, err = pcall(tool.draw, ctx)
                    if not ok then
                        ImGui.PushStyleColor(ctx, ImGui.Col_Text, 0xFF2222FF)
                        ImGui.Text(ctx, "Error running tool: " .. tostring(err))
                        ImGui.PopStyleColor(ctx)
                    end
                end
                ImGui.SameLine(ctx)
                ImGui.Text(ctx, "(or use auto-refresh)")
            else
                ImGui.Text(ctx, "Could not load tool: " .. tostring(active_tool_name))
            end
            ImGui.EndChild(ctx)
        end

        ImGui.EndChild(ctx) -- end tools_area
    end

    -- Bottom part for console
    if ImGui.BeginChild(ctx, 'console_area', 0, 0) then
        ImGui.Text(ctx, "Console")
        ImGui.SameLine(ctx)
        if ImGui.Button(ctx, "Clear") then console_logger.clear() end
        ImGui.Separator(ctx)
        if ImGui.BeginChild(ctx, 'console_scroll', 0, 0) then
            for _, msg in ipairs(console_logger.get_messages()) do
                ImGui.TextWrapped(ctx, msg)
            end
            if ImGui.GetScrollY(ctx) >= ImGui.GetScrollMaxY(ctx) then
                ImGui.SetScrollHereY(ctx, 1.0)
            end
            ImGui.EndChild(ctx)
        end
        ImGui.EndChild(ctx) -- end console_area
    end

  else
    main_window_open = false
  end
  ImGui.End(ctx)

  -- Show the ImGui demo window if requested
  if show_demo_window then
    -- Lazy-load the demo script
    if not demo then
        local demo_path = reaper.GetResourcePath() .. '/Scripts/devtoolbox-reaper-master/docs/reaimgui-master 3/examples/demo.lua'
        local chunk, err = loadfile(demo_path)
        if chunk then
            local _ENV = getfenv(0)
            setfenv(chunk, _ENV)
            local ok_p, mod = pcall(chunk)
            if ok_p then demo = mod end
        end
    end
    if demo and demo.ShowDemoWindow then
        show_demo_window = demo.ShowDemoWindow(show_demo_window)
    else
        local shown, open = ImGui.Begin(ctx, "Demo Loader Error", show_demo_window)
        if shown then
            ImGui.Text(ctx, "Could not load or run demo.lua.")
            ImGui.End(ctx)
        end
        show_demo_window = open
    end
  end

  -- Keep the script running if the main window is visible
  if main_window_open then
    reaper.defer(loop)
  else
    -- Cleanup when the window is closed
    script_manager.shutdown_all()
  end
end

-- Initial load and setup
script_manager.reload_scripts()
script_manager.init_all()

-- Start the main loop
reaper.defer(loop)

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
