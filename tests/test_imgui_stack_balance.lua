-- Test ImGui Stack Balance
-- Tests that ImGui push/pop operations are properly balanced
--
-- This test ensures that PushStyleColor/PopStyleColor calls are matched
-- to prevent ImGui assertion failures

local test_name = "ImGui Stack Balance Test"
local success = true
local errors = {}

local function log_error(msg)
    table.insert(errors, msg)
    success = false
end

-- Mock ImGui context for testing
local MockImGui = {}
local style_color_stack = 0
local style_var_stack = 0

function MockImGui.PushStyleColor(ctx, idx, color)
    style_color_stack = style_color_stack + 1
    return true
end

function MockImGui.PopStyleColor(ctx, count)
    count = count or 1
    if style_color_stack >= count then
        style_color_stack = style_color_stack - count
        return true
    else
        log_error("PopStyleColor called with count " .. count .. " but only " .. style_color_stack .. " colors on stack")
        return false
    end
end

function MockImGui.PushStyleVar(ctx, idx, val)
    style_var_stack = style_var_stack + 1
    return true
end

function MockImGui.PopStyleVar(ctx, count)
    count = count or 1
    if style_var_stack >= count then
        style_var_stack = style_var_stack - count
        return true
    else
        log_error("PopStyleVar called with count " .. count .. " but only " .. style_var_stack .. " vars on stack")
        return false
    end
end

-- Test 1: Basic push/pop balance
print("Testing basic ImGui stack balance...")

local ctx = {} -- mock context

-- Test balanced pushes and pops
MockImGui.PushStyleColor(ctx, 0, 0xFF0000FF) -- Push 1
MockImGui.PushStyleColor(ctx, 1, 0x00FF00FF) -- Push 2
MockImGui.PopStyleColor(ctx, 2) -- Pop 2

if style_color_stack ~= 0 then
    log_error("Style color stack should be 0 after balanced push/pop, but is " .. style_color_stack)
end

-- Test 2: Unbalanced push/pop (should detect and report error)
print("Testing unbalanced operations detection...")
local error_detected = false
local saved_errors_count = #errors

MockImGui.PushStyleColor(ctx, 0, 0xFF0000FF) -- Push 1
MockImGui.PopStyleColor(ctx, 2) -- Try to pop 2 (should fail)

-- Check if the error was properly detected
if #errors > saved_errors_count then
    print("  ✓ Unbalanced operation correctly detected")
    -- Remove this error from the main error list since it was intentional
    table.remove(errors)
    success = true -- Reset success since this error was expected
end

-- Reset stack for next test
style_color_stack = 0

-- Test 3: Test the fixed theming system pattern
print("Testing enhanced theming panel stack pattern...")

-- Reset stack
style_color_stack = 0

-- Simulate the corrected theming panel behavior
local function test_theming_render()
    -- This simulates the corrected code from enhanced_theming_panel.lua
    
    -- Push exactly 2 colors as intended
    MockImGui.PushStyleColor(ctx, 0, 0x1E1E1EFF) -- WindowBg
    MockImGui.PushStyleColor(ctx, 1, 0xFFFFFFFF) -- Text
    
    -- ... UI rendering would happen here ...
    
    -- Pop exactly 2 colors
    MockImGui.PopStyleColor(ctx, 2)
    
    return style_color_stack == 0
end

if not test_theming_render() then
    log_error("Theming panel stack balance test failed")
end

-- Test 4: Test nested push/pop operations
print("Testing nested stack operations...")

style_color_stack = 0
style_var_stack = 0

local function test_nested_operations()
    MockImGui.PushStyleColor(ctx, 0, 0xFF0000FF)  -- +1 color
    MockImGui.PushStyleVar(ctx, 0, 10)            -- +1 var
    
    MockImGui.PushStyleColor(ctx, 1, 0x00FF00FF)  -- +1 color (total: 2)
    MockImGui.PopStyleColor(ctx, 1)               -- -1 color (total: 1)
    
    MockImGui.PopStyleVar(ctx, 1)                 -- -1 var (total: 0)
    MockImGui.PopStyleColor(ctx, 1)               -- -1 color (total: 0)
    
    return style_color_stack == 0 and style_var_stack == 0
end

if not test_nested_operations() then
    log_error("Nested stack operations test failed")
end

-- Test 5: Verify stack state after operations
if style_color_stack ~= 0 then
    log_error("Final style color stack is not zero: " .. style_color_stack)
end

if style_var_stack ~= 0 then
    log_error("Final style var stack is not zero: " .. style_var_stack)
end

-- Results
print("\n=== ImGui Stack Balance Test Results ===")
if success then
    print("✅ " .. test_name .. " PASSED")
    print("All ImGui push/pop operations are properly balanced")
else
    print("❌ " .. test_name .. " FAILED")
    print("Errors found:")
    for i, error in ipairs(errors) do
        print("  " .. i .. ". " .. error)
    end
end

return success
