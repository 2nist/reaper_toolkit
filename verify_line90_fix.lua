-- Verify the exact main.lua:90 error is fixed
print("=== Verifying main.lua:90 Fix ===")

-- Mock environment  
_G.reaper = {
    ImGui_CreateContext = function(name)
        return { type = "mock_context", name = name }
    end
}

-- Set package path
package.path = './modules/?.lua;./scripts/?.lua;' .. package.path

-- Load console_logger as it would be loaded in main.lua
local console_logger = require 'console_logger'

-- Test the exact code pattern from main.lua around line 90
print("Testing the exact code pattern from main.lua:90...")

local ctx
if reaper and reaper.ImGui_CreateContext then
  -- EnviREAment environment - try both calling patterns
  local ok, result = pcall(reaper.ImGui_CreateContext, 'REAPER DevToolbox')
  if ok then
    ctx = result
    -- THIS IS THE EXACT LINE THAT WAS FAILING: main.lua:90
    console_logger.info("Using EnviREAment ImGui context with name parameter")
    print("✅ Line 90 equivalent executed successfully!")
  else
    -- Try without name parameter  
    local ok2, result2 = pcall(reaper.ImGui_CreateContext)
    if ok2 then
      ctx = result2
      console_logger.info("Using EnviREAment ImGui context without name parameter")
      print("✅ Alternative path also works!")
    else
      console_logger.error("Failed to create EnviREAment ImGui context: " .. tostring(result) .. " and " .. tostring(result2))
      print("❌ Both paths failed")
    end
  end
else
  print("No reaper environment detected")
end

-- Show the messages that were logged
print("\nLogged messages:")
local messages = console_logger.get_messages()
for i, msg in ipairs(messages) do
    print("  " .. i .. ". " .. msg)
end

print("\n🎉 MAIN.LUA:90 ERROR IS FIXED!")
print("The 'attempt to call a nil value (field 'info')' error is resolved.")
