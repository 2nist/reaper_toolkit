-- REAPER DevToolbox - Final Fixed Version
-- Main entry point with proper ImGui context management

-- Set up package paths to find our modules and scripts
local info = debug.getinfo(1, 'S')
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
local reaimgui_path_segment = ''
if reaper and reaper.ImGui_GetBuiltinPath then
    reaimgui_path_segment = reaper.ImGui_GetBuiltinPath() .. '/?.lua;'
end
package.path = reaimgui_path_segment .. script_path .. '?.lua;' .. script_path .. 'modules/?.lua;' .. script_path .. 'panels/?.lua;' .. script_path .. 'utils/?.lua;' .. package.path

-- Check for REAPER and ImGui availability
if not reaper or not reaper.ImGui_CreateContext then
  if reaper then
    reaper.MB("ReaImGui not found. Please install ReaImGui from ReaPack.", "Error", 0)
  end
  return
end

-- Load core modules
local script_manager = require 'script_manager'
local console_logger = require 'console_logger'

-- Initialize script manager
script_manager.init(script_path)

-- Context and state variables
local ctx = nil
local should_close_devtoolbox = false
local active_tool_name = 'enhanced_theming_panel'
local show_reload_confirm = false

-- Dock layout path
local dock_path = reaper.GetResourcePath() .. "/DevToolbox_dock.ini"

-- Context creation (once only)
local function ensure_context()
  if not ctx then
    ctx = reaper.ImGui_CreateContext('REAPER DevToolbox')
    if ctx then
      console_logger.log("ImGui context created: " .. tostring(ctx))
      _G.devtoolbox_ctx = ctx
      
      -- Load dock layout
      if reaper.ImGui_LoadIniSettingsFromDisk then
        reaper.ImGui_LoadIniSettingsFromDisk(ctx, dock_path)
      end
      
      return true
    else
      console_logger.log("Failed to create ImGui context")
      return false
    end
  end
  return true
end

-- Main GUI loop with proper frame structure
local function loop()
  if not ensure_context() then
    console_logger.log("Cannot proceed without context")
    return
  end
  
  -- Complete frame in one protected call
  local frame_ok, frame_err = pcall(function()
    -- Window setup
    reaper.ImGui_SetNextWindowSize(ctx, 800, 600, 4) -- Cond_FirstUseEver = 4
    reaper.ImGui_SetNextWindowPos(ctx, 0, 0, 4) -- Cond_FirstUseEver = 4
    
    -- Begin main window
    local visible, window_open = reaper.ImGui_Begin(ctx, 'DevToolbox', true, 16) -- WindowFlags_MenuBar = 16
    
    if visible then
      -- Menu bar
      if reaper.ImGui_BeginMenuBar(ctx) then
        -- Layout menu
        if reaper.ImGui_BeginMenu(ctx, "Layout") then
          if reaper.ImGui_MenuItem(ctx, "🔃 Reload Dock Layout") then
            if reaper.ImGui_LoadIniSettingsFromDisk then
              reaper.ImGui_LoadIniSettingsFromDisk(ctx, dock_path)
              console_logger.log("Dock layout reloaded")
            end
          end
          if reaper.ImGui_MenuItem(ctx, "💾 Save Dock Layout") then
            if reaper.ImGui_SaveIniSettingsToDisk then
              reaper.ImGui_SaveIniSettingsToDisk(ctx, dock_path)
              console_logger.log("Dock layout saved")
            end
          end
          reaper.ImGui_EndMenu(ctx)
        end
        
        -- Tools menu
        if reaper.ImGui_BeginMenu(ctx, "Tools") then
          if reaper.ImGui_MenuItem(ctx, "🔄 Reload All Tools") then
            show_reload_confirm = true
          end
          reaper.ImGui_Separator(ctx)
          if reaper.ImGui_MenuItem(ctx, "⚙️ Open Config Panel") then
            active_tool_name = "config_panel"
          end
          reaper.ImGui_EndMenu(ctx)
        end
        
        -- Help menu
        if reaper.ImGui_BeginMenu(ctx, "Help") then
          if reaper.ImGui_MenuItem(ctx, "📖 About DevToolbox") then
            console_logger.log("About DevToolbox")
          end
          if reaper.ImGui_MenuItem(ctx, "🐛 Debug Info") then
            console_logger.log("=== DEBUG INFO ===")
            console_logger.log("REAPER version: " .. reaper.GetAppVersion())
            console_logger.log("Context: " .. tostring(ctx))
            console_logger.log("================")
          end
          reaper.ImGui_EndMenu(ctx)
        end
        
        reaper.ImGui_EndMenuBar(ctx)
      end
      
      -- Main content
      reaper.ImGui_Text(ctx, "REAPER DevToolbox")
      reaper.ImGui_Text(ctx, "Context: " .. tostring(ctx))
      
      -- Reload confirmation
      if show_reload_confirm then
        reaper.ImGui_Separator(ctx)
        reaper.ImGui_Text(ctx, "⚠️ Reload all tools?")
        
        if reaper.ImGui_Button(ctx, "✓ YES - RELOAD") then
          script_manager.reload_scripts_live()
          script_manager.init_all()
          console_logger.log("Tools reloaded")
          show_reload_confirm = false
        end
        
        reaper.ImGui_SameLine(ctx)
        
        if reaper.ImGui_Button(ctx, "✗ CANCEL") then
          show_reload_confirm = false
        end
        
        reaper.ImGui_Separator(ctx)
      end
      
      -- Tool selection panel
      if reaper.ImGui_BeginChild(ctx, 'panel_selector', 250, -120) then
        reaper.ImGui_Text(ctx, "UI Panels")
        reaper.ImGui_Separator(ctx)
        
        local registry = script_manager.get_registry()
        for name, info in pairs(registry) do
          if info.active then
            local is_selected = (name == active_tool_name)
            if reaper.ImGui_Selectable(ctx, info.label or name, is_selected) then
              active_tool_name = name
              console_logger.log("Selected panel: " .. name)
            end
          end
        end
        
        reaper.ImGui_EndChild(ctx)
      end
      
      reaper.ImGui_SameLine(ctx)
      
      -- Main content area
      if reaper.ImGui_BeginChild(ctx, 'content', 0, -120) then
        local tool_info = script_manager.get_tool_info(active_tool_name)
        local display_title = active_tool_name
        
        if tool_info then
          display_title = (tool_info.icon or "📄") .. " " .. (tool_info.label or active_tool_name)
        end
        
        reaper.ImGui_Text(ctx, display_title)
        reaper.ImGui_Separator(ctx)
        
        local panel = script_manager.get_tool(active_tool_name)
        if panel and panel.draw and tool_info and tool_info.active then
          local panel_ok, panel_err = pcall(panel.draw, ctx)
          if not panel_ok then
            reaper.ImGui_Text(ctx, "Panel error: " .. tostring(panel_err))
          end
        else
          reaper.ImGui_Text(ctx, "No active tool selected")
        end
        
        reaper.ImGui_EndChild(ctx)
      end
      
      -- Console log area
      if reaper.ImGui_BeginChild(ctx, 'console_area', 0, 120) then
        reaper.ImGui_Text(ctx, "Console Log")
        reaper.ImGui_SameLine(ctx)
        
        if reaper.ImGui_Button(ctx, "Clear") then
          console_logger.clear()
        end
        
        reaper.ImGui_Separator(ctx)
        
        local log = table.concat(console_logger.get_messages(), "\n")
        reaper.ImGui_InputTextMultiline(ctx, "##console_log", log, -1, -1)
        
        reaper.ImGui_EndChild(ctx)
      end
      
      -- Close button
      reaper.ImGui_Separator(ctx)
      if reaper.ImGui_Button(ctx, "Close DevToolbox") then
        should_close_devtoolbox = true
      end
      
      reaper.ImGui_End(ctx)
    end
  end)
  
  if not frame_ok then
    console_logger.log("Frame error: " .. tostring(frame_err))
  end
  
  -- Continue loop
  if not should_close_devtoolbox and not _TEST_ENV then
    reaper.defer(loop)
  else
    console_logger.log("DevToolbox closing")
    if ctx and reaper.ImGui_DestroyContext then
      reaper.ImGui_DestroyContext(ctx)
    end
  end
end

-- Initialize and start
script_manager.reload_scripts()
script_manager.init_all()

console_logger.log("Starting DevToolbox with proper context management")

-- Clean exit handler
reaper.atexit(function()
  if ctx and reaper.ImGui_DestroyContext then
    reaper.ImGui_DestroyContext(ctx)
  end
  if reaper.ImGui_SaveIniSettingsToDisk then
    reaper.ImGui_SaveIniSettingsToDisk(ctx, dock_path)
  end
end)

if not _TEST_ENV then
  reaper.defer(loop)
end

return { console_logger = console_logger, script_manager = script_manager }
