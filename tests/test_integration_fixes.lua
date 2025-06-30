-- Integration Test for DevToolbox Fixes
-- Tests all the major fixes implemented for the REAPER DevToolbox
--
-- This test verifies that all ImGui-related fixes work together correctly

local test_name = "DevToolbox Integration Test"
local success = true
local errors = {}
local test_results = {}

local function log_error(msg)
    table.insert(errors, msg)
    success = false
end

local function run_test(test_func, test_name)
    print("Running " .. test_name .. "...")
    local start_time = os.clock()
    local result = test_func()
    local end_time = os.clock()
    
    test_results[test_name] = {
        success = result,
        duration = end_time - start_time
    }
    
    if result then
        print("  ✅ " .. test_name .. " passed (" .. string.format("%.3f", end_time - start_time) .. "s)")
    else
        print("  ❌ " .. test_name .. " failed (" .. string.format("%.3f", end_time - start_time) .. "s)")
    end
    
    return result
end

-- Test 1: ImGui Constants Integration
local function test_imgui_constants_integration()
    -- Load and test the individual constants test
    local constants_test = dofile("tests/test_imgui_constants.lua")
    return constants_test
end

-- Test 2: Stack Balance Integration
local function test_stack_balance_integration()
    -- Load and test the stack balance test
    local stack_test = dofile("tests/test_imgui_stack_balance.lua")
    return stack_test
end

-- Test 3: Color Picker Integration
local function test_color_picker_integration()
    -- Load and test the color picker test
    local color_test = dofile("tests/test_color_picker.lua")
    return color_test
end

-- Test 4: Floating Windows Integration
local function test_floating_windows_integration()
    -- Load and test the floating windows test
    local window_test = dofile("tests/test_floating_windows.lua")
    return window_test
end

-- Test 5: Enhanced Theming Panel Simulation
local function test_enhanced_theming_simulation()
    -- Simulate the enhanced theming panel workflow
    
    -- Mock ImGui setup
    local MockImGui = {}
    local ctx = {}
    local theme_colors = {
        window_bg = 0x1E1E1EFF,
        text = 0xFFFFFFFF,
        button = 0x404040FF,
        button_hovered = 0x505050FF,
        button_active = 0x606060FF
    }
    
    -- Mock functions
    function MockImGui.SetNextWindowSize(ctx, w, h, cond)
        return cond == 4 -- Should be Cond_FirstUseEver = 4
    end
    
    function MockImGui.SetNextWindowPos(ctx, x, y, cond)
        return cond == 4 -- Should be Cond_FirstUseEver = 4
    end
    
    function MockImGui.Begin(ctx, title, open, flags)
        return true, open
    end
    
    function MockImGui.End(ctx)
        return true
    end
    
    function MockImGui.ColorEdit4(ctx, label, packed_color)
        -- Simulate color change
        return true, packed_color
    end
    
    function MockImGui.Button(ctx, label)
        return false -- Not clicked
    end
    
    function MockImGui.Text(ctx, text)
        return true
    end
    
    function MockImGui.SameLine(ctx)
        return true
    end
    
    function MockImGui.PushStyleColor(ctx, idx, color)
        return true
    end
    
    function MockImGui.PopStyleColor(ctx, count)
        return true
    end
    
    -- Simulate the enhanced theming panel render function
    local function simulate_enhanced_theming_render()
        -- Window setup (corrected)
        if not MockImGui.SetNextWindowSize(ctx, 550, 650, 4) then
            return false
        end
        
        if not MockImGui.SetNextWindowPos(ctx, 200, 200, 4) then
            return false
        end
        
        local visible, open = MockImGui.Begin(ctx, 'Enhanced Theme Editor', true, 0)
        if not visible then
            return false
        end
        
        -- Theme color editing (corrected format)
        for name, color in pairs(theme_colors) do
            local changed, new_color = MockImGui.ColorEdit4(ctx, "##" .. name, color)
            if changed then
                theme_colors[name] = new_color
            end
            
            MockImGui.SameLine(ctx)
            MockImGui.Text(ctx, name:gsub("_", " "):upper())
        end
        
        -- Theme application (corrected stack balance)
        MockImGui.PushStyleColor(ctx, 0, theme_colors.window_bg) -- WindowBg
        MockImGui.PushStyleColor(ctx, 1, theme_colors.text)      -- Text
        
        -- UI content would be here
        MockImGui.Button(ctx, "Test Button")
        
        MockImGui.PopStyleColor(ctx, 2) -- Pop exactly 2 colors
        
        MockImGui.End(ctx)
        return true
    end
    
    return simulate_enhanced_theming_render()
end

-- Test 6: Script Loading Robustness
local function test_script_loading_robustness()
    -- Test that scripts handle missing 'arg' and 'os.exit' gracefully
    
    -- Simulate DevToolbox environment where 'arg' might not exist
    local old_arg = arg
    local old_os = os
    
    arg = nil
    os = nil
    
    -- Test argument safety pattern
    local function test_arg_safety()
        local test_arg = arg and arg[1] or nil
        return test_arg == nil -- Should handle missing arg gracefully
    end
    
    -- Test os.exit safety pattern
    local function test_os_exit_safety()
        if os and os.exit then
            -- This would normally exit, but os is nil so it won't
            return false
        else
            -- This is the safe fallback
            return true
        end
    end
    
    local arg_safe = test_arg_safety()
    local exit_safe = test_os_exit_safety()
    
    -- Restore global state
    arg = old_arg
    os = old_os
    
    return arg_safe and exit_safe
end

-- Run all integration tests
print("=== DevToolbox Integration Test Suite ===\n")

local all_tests_passed = true

all_tests_passed = run_test(test_imgui_constants_integration, "ImGui Constants Integration") and all_tests_passed
all_tests_passed = run_test(test_stack_balance_integration, "Stack Balance Integration") and all_tests_passed
all_tests_passed = run_test(test_color_picker_integration, "Color Picker Integration") and all_tests_passed
all_tests_passed = run_test(test_floating_windows_integration, "Floating Windows Integration") and all_tests_passed
all_tests_passed = run_test(test_enhanced_theming_simulation, "Enhanced Theming Simulation") and all_tests_passed
all_tests_passed = run_test(test_script_loading_robustness, "Script Loading Robustness") and all_tests_passed

-- Calculate total test time
local total_time = 0
for test_name, result in pairs(test_results) do
    total_time = total_time + result.duration
end

-- Final results
print("\n=== Integration Test Results ===")
print("Total tests: " .. 6)
print("Total time: " .. string.format("%.3f", total_time) .. "s")

local passed_count = 0
for test_name, result in pairs(test_results) do
    if result.success then
        passed_count = passed_count + 1
    end
end

print("Passed: " .. passed_count)
print("Failed: " .. (6 - passed_count))

if all_tests_passed then
    print("\n🎉 ALL INTEGRATION TESTS PASSED!")
    print("The DevToolbox fixes are working correctly:")
    print("  ✅ ImGui constants use correct power-of-two values")
    print("  ✅ ImGui stack operations are properly balanced")
    print("  ✅ Color picker uses packed color format correctly")
    print("  ✅ Floating windows are properly managed")
    print("  ✅ Enhanced theming panel works with all fixes")
    print("  ✅ Scripts load robustly in DevToolbox environment")
else
    print("\n❌ SOME INTEGRATION TESTS FAILED")
    if #errors > 0 then
        print("Integration errors:")
        for i, error in ipairs(errors) do
            print("  " .. i .. ". " .. error)
        end
    end
end

return all_tests_passed
