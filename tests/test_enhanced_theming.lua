#!/usr/bin/env lua

-- Test script to verify enhanced theming panel loads correctly
-- Run with: lua test_enhanced_theming.lua

-- Setup test environment
_TEST_ENV = true

-- Mock reaper environment
local function create_reaper_mock()
    local reaper = {}
    
    -- Mock basic REAPER functions
    reaper.ShowConsoleMsg = function(msg) print("[REAPER] " .. msg) end
    reaper.EnumerateFiles = function(path, i) return nil end -- No files in test
    reaper.GetResourcePath = function() return "/mock/path" end
    
    -- Mock ImGui functions that are required
    reaper.ImGui_CreateContext = function() return "test_ctx" end
    reaper.ImGui_GetBuiltinPath = function() return "/mock/imgui" end
    
    -- Mock ImGui constants as functions (this is how they work in REAPER)
    reaper.ImGui_Col_Text = function() return 0 end
    reaper.ImGui_Col_WindowBg = function() return 1 end
    reaper.ImGui_Cond_FirstUseEver = function() return 4 end
    reaper.ImGui_ChildFlags_Border = function() return 1 end
    
    return reaper
end

-- Create global reaper mock
reaper = create_reaper_mock()

print("=== Testing Enhanced Theming Panel Loading ===")

-- Test loading the enhanced theming panel
local ok, enhanced_theming_panel = pcall(require, 'scripts.enhanced_theming_panel')
if ok then
    print("✅ Enhanced theming panel loaded successfully")
    
    -- Check if it has required functions
    if enhanced_theming_panel.draw then
        print("✅ Enhanced theming panel has draw() function")
    else
        print("❌ Enhanced theming panel missing draw() function")
    end
    
    if enhanced_theming_panel.init then
        print("✅ Enhanced theming panel has init() function")
    else
        print("❌ Enhanced theming panel missing init() function")
    end
    
    -- Test initialization
    local init_ok, init_err = pcall(enhanced_theming_panel.init)
    if init_ok then
        print("✅ Enhanced theming panel initialized successfully")
    else
        print("❌ Enhanced theming panel initialization failed: " .. tostring(init_err))
    end
    
else
    print("❌ Failed to load enhanced theming panel: " .. tostring(enhanced_theming_panel))
end

-- Test loading the script manager to see if it finds the enhanced theming panel
print("\n=== Testing Script Manager ===")
local script_manager_ok, script_manager = pcall(require, 'modules.script_manager')
if script_manager_ok then
    print("✅ Script manager loaded successfully")
    
    -- Initialize with mock path
    script_manager.init("/Users/Matthew/devtoolbox-reaper-master/")
    
    -- Try to reload scripts
    script_manager.reload_scripts()
    
    -- Check what tools were found
    local tools = script_manager.get_tools()
    print("Found tools:")
    for name, tool in pairs(tools) do
        print("  - " .. name)
    end
    
    -- Check if enhanced_theming_panel is available
    local enhanced_tool = script_manager.get_tool('enhanced_theming_panel')
    if enhanced_tool then
        print("✅ Enhanced theming panel found in script manager")
    else
        print("❌ Enhanced theming panel not found in script manager")
    end
    
else
    print("❌ Failed to load script manager: " .. tostring(script_manager))
end

print("\n=== Test Complete ===")
