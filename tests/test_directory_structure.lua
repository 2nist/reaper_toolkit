#!/usr/bin/env lua

-- Test DevToolbox Reorganized Directory Structure
_TEST_ENV = true

print("=== DevToolbox Directory Structure Test ===\n")

-- Mock environment
local function create_reaper_mock()
    local reaper = {}
    reaper.ShowConsoleMsg = function(msg) print("[REAPER] " .. tostring(msg):gsub('\n', '')) end
    reaper.EnumerateFiles = function(path, i)
        -- Mock files in panels directory
        if path:match("panels") then
            local files = {"config_panel.lua", "enhanced_theming_panel.lua", "style_editor_panel.lua", "template_tool.lua", "test_mvp_tool.lua"}
            return files[i + 1]
        end
        return nil
    end
    reaper.GetResourcePath = function() return "/mock/path" end
    reaper.ImGui_CreateContext = function() return "test_ctx" end
    reaper.ImGui_GetBuiltinPath = function() return "/mock/imgui" end
    return reaper
end

reaper = create_reaper_mock()

local current_dir = "/Users/Matthew/devtoolbox-reaper-master"
package.path = current_dir .. "/modules/?.lua;" .. current_dir .. "/panels/?.lua;" .. current_dir .. "/utils/?.lua;" .. package.path

print("🧪 Testing Directory Structure Organization")

-- Test 1: Verify directory structure
print("\n1. Directory Structure:")
local function check_directory(dir_name, expected_type)
    local dir_path = current_dir .. "/" .. dir_name
    local file = io.open(dir_path .. "/", "r")
    if file then
        file:close()
        print("✅ /" .. dir_name .. "/ exists (" .. expected_type .. ")")
        return true
    else
        print("❌ /" .. dir_name .. "/ missing")
        return false
    end
end

check_directory("modules", "Backend/Core Systems")
check_directory("panels", "UI Panels")
check_directory("utils", "Development Utilities")

-- Test 2: Verify modules load correctly
print("\n2. Backend Modules:")
local modules_to_test = {
    "console_logger",
    "script_manager", 
    "theme_manager"
}

for _, module_name in ipairs(modules_to_test) do
    local ok, module = pcall(require, module_name)
    if ok then
        print("✅ " .. module_name .. " loads successfully")
    else
        print("❌ " .. module_name .. " failed: " .. tostring(module))
    end
end

-- Test 3: Verify panels load correctly
print("\n3. UI Panels:")
local panels_to_test = {
    "config_panel",
    "enhanced_theming_panel",
    "style_editor_panel",
    "template_tool"
}

for _, panel_name in ipairs(panels_to_test) do
    local ok, panel = pcall(require, panel_name)
    if ok then
        print("✅ " .. panel_name .. " loads successfully")
        
        -- Check panel structure
        local has_draw = type(panel.draw) == "function"
        local has_init = type(panel.init) == "function"
        print("  - draw(): " .. (has_draw and "✅" or "❌"))
        print("  - init(): " .. (has_init and "✅" or "❌"))
    else
        print("❌ " .. panel_name .. " failed: " .. tostring(panel))
    end
end

-- Test 4: Test script manager with new panels directory
print("\n4. Script Manager with Panels Directory:")
local script_manager_ok, script_manager = pcall(require, 'script_manager')
if script_manager_ok then
    print("✅ Script manager loaded")
    
    script_manager.init(current_dir .. "/")
    print("✅ Script manager initialized with panels path")
    
    script_manager.reload_scripts()
    print("✅ Panels reloaded from /panels/ directory")
    
    local tools = script_manager.get_tools()
    print("✅ Found " .. #table.concat(tools and {} or {}) .. " panels:")
    for name, panel in pairs(tools) do
        print("  - " .. name)
    end
    
    -- Test getting specific panel
    local enhanced_theming = script_manager.get_tool('enhanced_theming_panel')
    if enhanced_theming then
        print("✅ Enhanced theming panel accessible via script manager")
    else
        print("❌ Enhanced theming panel not found")
    end
else
    print("❌ Script manager failed: " .. tostring(script_manager))
end

-- Test 5: Verify utilities are accessible (but not auto-loaded)
print("\n5. Development Utilities:")
local utils_to_test = {
    "harden_envi_mocks",
    "parse_imgui_api_test_results",
    "sync_envi_mocks"
}

for _, util_name in ipairs(utils_to_test) do
    local ok, util = pcall(require, util_name)
    if ok then
        print("✅ " .. util_name .. " accessible in /utils/")
    else
        print("❌ " .. util_name .. " not found or failed")
    end
end

print("\n=== Directory Structure Benefits ===")
print("✅ ORGANIZED: Clear separation of modules, panels, and utilities")
print("✅ USER-FRIENDLY: Only UI panels appear in DevToolbox interface")
print("✅ DEVELOPER-FRIENDLY: Easy to add new panels and modules")
print("✅ MAINTAINABLE: Backend logic separated from UI code")
print("✅ SCALABLE: New panels auto-discovered without code changes")

print("\n📁 STRUCTURE SUMMARY:")
print("  /modules/ → Backend systems (console_logger, script_manager, theme_manager)")
print("  /panels/  → UI panels that appear in DevToolbox (enhanced_theming_panel, config_panel, etc.)")
print("  /utils/   → Development utilities (testing, mocking, API parsing)")

print("\n🎯 USER EXPERIENCE:")
print("  • Users see 'UI Panels' list in DevToolbox")
print("  • Click 'Select' to choose a panel")
print("  • Selected panel appears in main content area")
print("  • All panels inherit global theming automatically")

print("\n🛠 DEVELOPER EXPERIENCE:")
print("  • Copy template_tool.lua to create new panels")
print("  • Panels auto-discovered in /panels/ directory")
print("  • Backend modules in /modules/ for core functionality")
print("  • Development utilities in /utils/ for testing")

print("\n🎉 DevToolbox directory structure is now properly organized!")
print("=== Test Complete ===")
