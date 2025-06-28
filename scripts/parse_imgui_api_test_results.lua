-- parse_imgui_api_test_results.lua
-- Usage: lua parse_imgui_api_test_results.lua <logfile>
-- Reads a log file from run_all.lua batch run and summarizes pass/fail per test script.

local log_path = arg[1] or "imgui_api_test_output.log"
local summary = {}
local failed = {}
local passed = {}
local total = 0
local failed_count = 0
local passed_count = 0

local function parse_line(line)
  -- Look for lines like: [PASS] script.lua or [FAIL] script.lua: error message
  local pass, script = line:match("%[PASS%]%s+([%w_%-%.]+)")
  if pass then
    passed[pass] = true
    total = total + 1
    passed_count = passed_count + 1
    return
  end
  local fail, script, msg = line:match("%[FAIL%]%s+([%w_%-%.]+):%s*(.*)")
  if fail then
    failed[fail] = msg or "(no error message)"
    total = total + 1
    failed_count = failed_count + 1
    return
  end
end

local f = io.open(log_path, "r")
if not f then
  print("[ERROR] Could not open log file: " .. log_path)
  os.exit(1)
end
for line in f:lines() do
  parse_line(line)
end
f:close()

print("\n==== ImGui API Batch Test Summary ====")
print("Total tests:", total)
print("Passed:", passed_count)
print("Failed:", failed_count)
if failed_count > 0 then
  print("\nFailed scripts:")
  for script, msg in pairs(failed) do
    print("  ", script, "-", msg)
  end
end
if passed_count > 0 then
  print("\nPassed scripts:")
  for script in pairs(passed) do
    print("  ", script)
  end
end
print("\n======================================\n")

-- Optionally, write a summary file
do
  local outf = io.open("imgui_api_test_summary.txt", "w")
  if outf then
    outf:write("Total tests: ", total, "\n")
    outf:write("Passed: ", passed_count, "\n")
    outf:write("Failed: ", failed_count, "\n\n")
    if failed_count > 0 then
      outf:write("Failed scripts:\n")
      for script, msg in pairs(failed) do
        outf:write("  ", script, " - ", msg, "\n")
      end
      outf:write("\n")
    end
    if passed_count > 0 then
      outf:write("Passed scripts:\n")
      for script in pairs(passed) do
        outf:write("  ", script, "\n")
      end
    end
    outf:close()
  end
end
