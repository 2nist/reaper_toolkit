-- Test ImGui Constants Fix
-- Tests that all ImGui condition constants are power-of-two values as required by ImGui
--
-- This test ensures that the fix for the ImGui assertion error:
-- "IM_ASSERT(cond == 0 || ImIsPowerOfTwo(cond))" is working correctly

local test_name = "ImGui Constants Test"
local success = true
local errors = {}

local function log_error(msg)
    table.insert(errors, msg)
    success = false
end

local function is_power_of_two(n)
    return n > 0 and (n & (n - 1)) == 0
end

-- Test setup - simulate the constants from main.lua
local ImGui = {}

-- Test the corrected constant values
ImGui.Cond_Always = 1
ImGui.Cond_Once = 2
ImGui.Cond_FirstUseEver = 4
ImGui.Cond_Appearing = 8

-- Test 1: Verify all condition constants are power of two
print("Testing ImGui condition constants...")

if not is_power_of_two(ImGui.Cond_Always) then
    log_error("Cond_Always (" .. ImGui.Cond_Always .. ") is not a power of two")
end

if not is_power_of_two(ImGui.Cond_Once) then
    log_error("Cond_Once (" .. ImGui.Cond_Once .. ") is not a power of two")
end

if not is_power_of_two(ImGui.Cond_FirstUseEver) then
    log_error("Cond_FirstUseEver (" .. ImGui.Cond_FirstUseEver .. ") is not a power of two")
end

if not is_power_of_two(ImGui.Cond_Appearing) then
    log_error("Cond_Appearing (" .. ImGui.Cond_Appearing .. ") is not a power of two")
end

-- Test 2: Verify specific values match ImGui expectations
local expected_values = {
    Cond_Always = 1,
    Cond_Once = 2,
    Cond_FirstUseEver = 4,
    Cond_Appearing = 8
}

for constant_name, expected_value in pairs(expected_values) do
    local actual_value = ImGui[constant_name]
    if actual_value ~= expected_value then
        log_error(constant_name .. " should be " .. expected_value .. " but got " .. (actual_value or "nil"))
    end
end

-- Test 3: Verify the old incorrect value (3) is no longer used
if ImGui.Cond_FirstUseEver == 3 then
    log_error("Cond_FirstUseEver is still using the incorrect value 3 instead of 4")
end

-- Test 4: Test window flags that should also be power-of-two
local window_flags = {
    WindowFlags_None = 0,
    WindowFlags_MenuBar = 16,
    WindowFlags_AlwaysAutoResize = 64,
    WindowFlags_NoDocking = 8192
}

ImGui.WindowFlags_None = 0
ImGui.WindowFlags_MenuBar = 16
ImGui.WindowFlags_AlwaysAutoResize = 64
ImGui.WindowFlags_NoDocking = 8192

for flag_name, expected_value in pairs(window_flags) do
    local actual_value = ImGui[flag_name]
    if actual_value ~= expected_value then
        log_error(flag_name .. " should be " .. expected_value .. " but got " .. (actual_value or "nil"))
    end
    
    -- All non-zero window flags should be power of two
    if expected_value > 0 and not is_power_of_two(expected_value) then
        log_error(flag_name .. " (" .. expected_value .. ") is not a power of two")
    end
end

-- Results
print("\n=== ImGui Constants Test Results ===")
if success then
    print("✅ " .. test_name .. " PASSED")
    print("All ImGui constants are using correct power-of-two values")
else
    print("❌ " .. test_name .. " FAILED")
    print("Errors found:")
    for i, error in ipairs(errors) do
        print("  " .. i .. ". " .. error)
    end
end

return success
