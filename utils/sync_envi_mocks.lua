-- sync_envi_mocks.lua
-- Usage: lua scripts/sync_envi_mocks.lua <diff_file> <mock_file>
-- Reads a diff of test summaries and appends missing mock function stubs to the mock file.

local diff_file = (arg and arg[1]) or 'tests/summary_diff.txt'
local mock_file = (arg and arg[2]) or 'EnviREAment/enviREAment_core_lib/enhanced_virtual_reaper.lua'

local function get_existing_mocks(file)
  local mocks = {}
  local f = io.open(file, "r")
  if not f then return mocks end
  for line in f:lines() do
    local name = line:match("^function reaper%.(ImGui_[%w_]+)")
    if name then
      mocks[name] = true
    end
  end
  f:close()
  return mocks
end

local existing_mocks = get_existing_mocks(mock_file)
local stubs_to_add = {}
local functions_to_add = {}

local diff_fh = io.open(diff_file, "r")
if not diff_fh then
  print("[ERROR] Could not open diff file: " .. diff_file)
  os.exit(1)
end

for line in diff_fh:lines() do
  -- Look for lines added from the real log, indicating a passed test that failed in the env
  if line:sub(1, 1) == '>' or (line:sub(1,1) == '+' and not line:find('^%+%+%+')) then
    local script_name = line:match('%s(ImGui_[%w_]+_%d+args)%.lua')
    if script_name then
      local func_name = script_name:match("(ImGui_[%w_]+)_%d+args")
      if func_name and not functions_to_add[func_name] and not existing_mocks[func_name] then
        local stub = string.format([[
function reaper.%s(...)
  -- Mock implementation for %s
  -- TODO: Add correct return values and argument handling.
  reaper.ShowConsoleMsg('[MOCK] Called %s with args: ' .. table.concat({...}, ", ") .. '\n')
  return 0 -- Default return value
end
]], func_name, func_name, func_name)
        stubs_to_add[#stubs_to_add + 1] = stub
        functions_to_add[func_name] = true
      end
    end
  end
end
diff_fh:close()

if #stubs_to_add > 0 then
  local mock_fh = io.open(mock_file, "a")
  if not mock_fh then
    print("[ERROR] Could not open mock file for appending: " .. mock_file)
    os.exit(1)
  end
  print("--- Appending " .. #stubs_to_add .. " new mock stubs to " .. mock_file .. " ---")
  mock_fh:write('\n\n-- Auto-generated mock stubs from sync_envi_mocks.lua --\n')
  for _, stub in ipairs(stubs_to_add) do
    mock_fh:write(stub)
    print("  Added mock for", stub:match("reaper%.(ImGui_[%w_]+)"))
  end
  mock_fh:close()
  print("--- Sync complete. Please review the new stubs in the mock file. ---")
else
  print("--- No new mocks to add. EnviREAment appears to be in sync. ---")
end
