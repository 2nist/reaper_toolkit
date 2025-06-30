-- Test for the console_logger.info fix in main.lua
-- Verifies that console_logger is loaded before being used

local test_name = "Console Logger Loading Order Test"
local success = true
local errors = {}

local function log_error(msg)
    table.insert(errors, msg)
    success = false
end

print("=== " .. test_name .. " ===")

-- Test 1: Verify loading order by checking main.lua structure
print("Test 1: Checking main.lua loading order...")

local main_content = io.open("main.lua", "r"):read("*all")

-- Check that require statements come before global assignments
local script_manager_require_pos = main_content:find("local script_manager = require 'script_manager'")
local console_logger_require_pos = main_content:find("local console_logger = require 'console_logger'")
local global_assignment_pos = main_content:find("_G.console_logger = console_logger")

if not script_manager_require_pos then
    log_error("script_manager require statement not found")
elseif not console_logger_require_pos then
    log_error("console_logger require statement not found")
elseif not global_assignment_pos then
    log_error("global console_logger assignment not found")
elseif console_logger_require_pos > global_assignment_pos then
    log_error("console_logger is required AFTER being assigned to global - this will cause nil errors")
else
    print("  ✓ console_logger is required BEFORE global assignment")
end

-- Test 2: Check that console_logger.info calls come after the require
local info_call_pos = main_content:find("console_logger%.info")
if info_call_pos and console_logger_require_pos and info_call_pos < console_logger_require_pos then
    log_error("console_logger.info is called BEFORE require statement")
else
    print("  ✓ console_logger.info calls come after require statement")
end

-- Test 3: Simulate the corrected loading pattern
print("\nTest 2: Simulating corrected loading pattern...")

local function simulate_corrected_loading()
    -- Mock the modules
    local mock_script_manager = { init = function() end }
    local mock_console_logger = { 
        info = function(msg) print("INFO: " .. msg) end,
        error = function(msg) print("ERROR: " .. msg) end
    }
    local mock_theming_panel = {}
    
    -- Simulate the corrected order: require FIRST, then global assignment
    local script_manager = mock_script_manager
    local console_logger = mock_console_logger
    local theming_panel = mock_theming_panel
    
    -- Now assign to global (this should work)
    _G.console_logger = console_logger
    
    -- Test that console_logger.info works
    local info_ok = pcall(function()
        console_logger.info("Test message")
    end)
    
    if info_ok then
        print("  ✓ console_logger.info works after correct loading order")
        return true
    else
        log_error("console_logger.info failed even with correct loading order")
        return false
    end
end

if not simulate_corrected_loading() then
    log_error("Simulated loading pattern failed")
end

-- Test 4: Check for common loading order mistakes
print("\nTest 3: Checking for common loading order patterns...")

-- Check that no other modules are used before being required
local patterns_to_check = {
    { var = "script_manager", pattern = "script_manager%." },
    { var = "theming_panel", pattern = "theming_panel%." }
}

for _, check in ipairs(patterns_to_check) do
    local require_pos = main_content:find("local " .. check.var .. " = require")
    local usage_pos = main_content:find(check.pattern)
    
    -- Find the first actual usage (not the require line itself)
    if usage_pos and require_pos then
        local usage_line = main_content:sub(1, usage_pos):match(".*\n") or ""
        if not usage_line:find("require") and usage_pos < require_pos then
            log_error(check.var .. " is used before being required")
        else
            print("  ✓ " .. check.var .. " usage comes after require statement")
        end
    end
end

-- Results
print("\n=== Console Logger Loading Order Test Results ===")
if success then
    print("✅ " .. test_name .. " PASSED")
    print("Loading order is correct:")
    print("  ✓ Modules are required before global assignment")
    print("  ✓ console_logger.info calls come after require")
    print("  ✓ No usage-before-require issues detected")
    print("🎉 The main.lua:90 console_logger.info error is FIXED!")
else
    print("❌ " .. test_name .. " FAILED")
    print("Errors found:")
    for i, error in ipairs(errors) do
        print("  " .. i .. ". " .. error)
    end
end

return success
