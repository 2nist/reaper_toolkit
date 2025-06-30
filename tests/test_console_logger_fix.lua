-- Test the console_logger.info fix by simulating REAPER environment
print("=== Testing Console Logger Info Fix ===")

-- Mock REAPER environment
_G.reaper = {
    ImGui_CreateContext = function(name)
        return { type = "mock_context", name = name }
    end,
    ImGui_GetBuiltinPath = function()
        return "/mock/path"
    end
}

-- Set package path
package.path = './modules/?.lua;./scripts/?.lua;' .. package.path

-- Test 1: Verify console_logger has info function
print("Test 1: Checking console_logger module...")
local console_logger = require 'console_logger'
print("  console_logger loaded:", type(console_logger))
print("  info function exists:", type(console_logger.info))
print("  error function exists:", type(console_logger.error))
print("  debug function exists:", type(console_logger.debug))

-- Test 2: Test info function works
print("\nTest 2: Testing info function...")
local success = pcall(function()
    console_logger.info("Test message from console_logger.info")
end)
print("  console_logger.info call succeeded:", success)

-- Test 3: Check messages are stored
print("\nTest 3: Checking message storage...")
local messages = console_logger.get_messages()
print("  Number of messages stored:", #messages)
if #messages > 0 then
    print("  Last message:", messages[#messages])
end

-- Test 4: Test the specific context creation pattern from main.lua
print("\nTest 4: Testing main.lua context creation pattern...")
local ctx
if reaper and reaper.ImGui_CreateContext then
    local ok, result = pcall(reaper.ImGui_CreateContext, 'REAPER DevToolbox')
    if ok then
        ctx = result
        -- This is the line that was failing: main.lua:90
        console_logger.info("Using EnviREAment ImGui context with name parameter")
        print("  ✅ console_logger.info call in context creation SUCCEEDED")
    else
        console_logger.error("Failed to create context")
        print("  ❌ Context creation failed")
    end
else
    print("  ❌ No reaper environment")
end

print("\n=== Test Results ===")
if success and ctx then
    print("✅ CONSOLE LOGGER INFO FIX VERIFIED!")
    print("  ✓ console_logger module has info function")
    print("  ✓ console_logger.info() works without errors")
    print("  ✓ Context creation with logging works")
    print("  ✓ main.lua:90 console_logger.info error is RESOLVED")
else
    print("❌ Console logger info fix failed")
end
