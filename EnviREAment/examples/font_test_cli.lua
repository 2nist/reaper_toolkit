-- Font Integration Test Runner
-- Simple command-line test for font integration
-- Following EnviREAment testing SOP without full REAPER launch

local VERSION = "1.0.0"
local TEST_NAME = "Font Integration CLI Test"

-- Setup paths
local devtoolbox_path = "c:\\Users\\CraftAuto-Sales\\AppData\\Roaming\\REAPER\\Scripts\\reaper_toolkit-1"

-- Test state
local test_state = {
  test_results = {},
  modules_tested = {}
}

-- Test utilities
local function log_test(test_name, status, message)
  local result = {
    name = test_name,
    status = status, -- "PASS", "FAIL", "INFO"
    message = message or "",
    timestamp = os.time()
  }
  table.insert(test_state.test_results, result)
  
  local status_icon = status == "PASS" and "✓" or status == "FAIL" and "✗" or "ℹ"
  print(string.format("[%s] %s: %s", status_icon, test_name, message))
end

-- Test file existence
local function test_file_exists(filepath, description)
  local file = io.open(filepath, "r")
  if file then
    file:close()
    log_test("File Check", "PASS", description .. " exists")
    return true
  else
    log_test("File Check", "FAIL", description .. " missing: " .. filepath)
    return false
  end
end

-- Test 1: DevToolbox File Structure
local function test_devtoolbox_structure()
  log_test("Structure Test", "INFO", "Testing DevToolbox file structure")
  
  local files_to_check = {
    {devtoolbox_path .. "\\modules\\font_manager.lua", "Font Manager"},
    {devtoolbox_path .. "\\font_config.lua", "Font Config"},
    {devtoolbox_path .. "\\modules\\font_selector_panel.lua", "Font Selector Panel"},
    {devtoolbox_path .. "\\tools_registry.lua", "Tools Registry"},
    {devtoolbox_path .. "\\main.lua", "Main DevToolbox"}
  }
  
  local all_exist = true
  for _, file_info in ipairs(files_to_check) do
    if not test_file_exists(file_info[1], file_info[2]) then
      all_exist = false
    end
  end
  
  return all_exist
end

-- Test 2: Lua Syntax Validation
local function test_lua_syntax()
  log_test("Syntax Test", "INFO", "Testing Lua syntax for font modules")
  
  local files_to_test = {
    "font_manager.lua",
    "font_selector_panel.lua"
  }
  
  local config_files = {
    "font_config.lua",
    "tools_registry.lua"
  }
  
  local syntax_ok = true
  
  for _, filename in ipairs(files_to_test) do
    local filepath = devtoolbox_path .. "\\modules\\" .. filename
    local file = io.open(filepath, "r")
    
    if file then
      local content = file:read("*all")
      file:close()
      
      -- Basic syntax check using loadstring (Lua 5.1) or load (Lua 5.2+)
      local func, err
      if loadstring then
        func, err = loadstring(content, filename)
      else
        func, err = load(content, filename)
      end
      
      if func then
        log_test("Syntax Check", "PASS", filename .. " syntax valid")
      else
        log_test("Syntax Check", "FAIL", filename .. " syntax error: " .. tostring(err))
        syntax_ok = false
      end
    else
      log_test("Syntax Check", "FAIL", filename .. " file not found")
      syntax_ok = false
    end
  end
  
  -- Test config files in root
  for _, filename in ipairs(config_files) do
    local filepath = devtoolbox_path .. "\\" .. filename
    local file = io.open(filepath, "r")
    
    if file then
      local content = file:read("*all")
      file:close()
      
      -- Basic syntax check using loadstring (Lua 5.1) or load (Lua 5.2+)
      local func, err
      if loadstring then
        func, err = loadstring(content, filename)
      else
        func, err = load(content, filename)
      end
      
      if func then
        log_test("Syntax Check", "PASS", filename .. " syntax valid")
      else
        log_test("Syntax Check", "FAIL", filename .. " syntax error: " .. tostring(err))
        syntax_ok = false
      end
    else
      log_test("Syntax Check", "FAIL", filename .. " file not found")
      syntax_ok = false
    end
  end
  
  return syntax_ok
end

-- Test 3: Font Configuration Validation
local function test_font_configuration()
  log_test("Config Test", "INFO", "Testing font configuration structure")
  
  local config_path = devtoolbox_path .. "\\font_config.lua"
  local file = io.open(config_path, "r")
  
  if not file then
    log_test("Config Test", "FAIL", "font_config.lua not found")
    return false
  end
  
  local content = file:read("*all")
  file:close()
  
  -- Check for required configuration elements
  local checks = {
    {"fonts%s*=%s*{", "fonts table definition"},
    {"name%s*=%s*[\"']", "font name definitions"},
    {"family%s*=%s*[\"']", "font family definitions"},
    {"path%s*=%s*[\"']", "font path definitions"}
  }
  
  local all_checks_pass = true
  for _, check in ipairs(checks) do
    if content:match(check[1]) then
      log_test("Config Structure", "PASS", check[2] .. " found")
    else
      log_test("Config Structure", "FAIL", check[2] .. " missing")
      all_checks_pass = false
    end
  end
  
  return all_checks_pass
end

-- Test 4: Font Manager API Check
local function test_font_manager_api()
  log_test("API Test", "INFO", "Testing font manager API structure")
  
  local manager_path = devtoolbox_path .. "\\modules\\font_manager.lua"
  local file = io.open(manager_path, "r")
  
  if not file then
    log_test("API Test", "FAIL", "font_manager.lua not found")
    return false
  end
  
  local content = file:read("*all")
  file:close()
  
  -- Check for required API functions
  local api_functions = {
    {"function%s+[%w_.]*init", "init function"},
    {"function%s+[%w_.]*push_font", "push_font function"},
    {"function%s+[%w_.]*pop_font", "pop_font function"},
    {"function%s+[%w_.]*test_font_creation", "test_font_creation function"}
  }
  
  local api_complete = true
  for _, func_check in ipairs(api_functions) do
    if content:match(func_check[1]) then
      log_test("API Check", "PASS", func_check[2] .. " found")
    else
      log_test("API Check", "FAIL", func_check[2] .. " missing")
      api_complete = false
    end
  end
  
  return api_complete
end

-- Test 5: SOP Compliance Check
local function test_sop_compliance()
  log_test("SOP Test", "INFO", "Testing SOP compliance for font integration")
  
  local panel_path = devtoolbox_path .. "\\modules\\font_selector_panel.lua"
  local file = io.open(panel_path, "r")
  
  if not file then
    log_test("SOP Test", "FAIL", "font_selector_panel.lua not found")
    return false
  end
  
  local content = file:read("*all")
  file:close()
  
  -- Check for SOP-required patterns
  local sop_checks = {
    {"PushFont", "PushFont usage (SOP required)"},
    {"PopFont", "PopFont usage (SOP required)"},
    {"test_font_creation", "test_font_creation calls (SOP required)"},
    {"ImGui%.Combo", "Combo boxes for font selection"},
    {"ImGui%.Text", "Text preview elements"}
  }
  
  local sop_compliant = true
  for _, check in ipairs(sop_checks) do
    if content:match(check[1]) then
      log_test("SOP Compliance", "PASS", check[2] .. " found")
    else
      log_test("SOP Compliance", "FAIL", check[2] .. " missing")
      sop_compliant = false
    end
  end
  
  return sop_compliant
end

-- Test runner
local function run_all_tests()
  log_test("Test Suite", "INFO", "Starting DevToolbox Font Integration CLI Tests")
  print("=" .. string.rep("=", 60))
  print("DevToolbox Font Integration Test Suite")
  print("Following EnviREAment SOP for testing")
  print("=" .. string.rep("=", 60))
  
  local test_functions = {
    {"DevToolbox Structure", test_devtoolbox_structure},
    {"Lua Syntax", test_lua_syntax},
    {"Font Configuration", test_font_configuration},
    {"Font Manager API", test_font_manager_api},
    {"SOP Compliance", test_sop_compliance}
  }
  
  local passed = 0
  local failed = 0
  
  for _, test_info in ipairs(test_functions) do
    print("\n--- Testing: " .. test_info[1] .. " ---")
    local result = test_info[2]()
    if result then
      passed = passed + 1
    else
      failed = failed + 1
    end
  end
  
  print("\n" .. string.rep("=", 60))
  print(string.format("Test Results: %d PASSED, %d FAILED", passed, failed))
  
  if failed == 0 then
    print("✓ All tests passed! Font integration ready for deployment.")
    print("✓ SOP compliance verified.")
    print("✓ Ready for EnviREAment testing.")
  else
    print("✗ Some tests failed. Please review and fix issues before deployment.")
  end
  
  print("=" .. string.rep("=", 60))
  return failed == 0
end

-- Generate test report
local function generate_report()
  local report_path = "font_integration_test_report.txt"
  local file = io.open(report_path, "w")
  
  if file then
    file:write("DevToolbox Font Integration Test Report\n")
    file:write("Generated: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n")
    file:write("Test Version: " .. VERSION .. "\n")
    file:write(string.rep("=", 50) .. "\n\n")
    
    for _, result in ipairs(test_state.test_results) do
      file:write(string.format("[%s] %s: %s\n", result.status, result.name, result.message))
    end
    
    file:write("\nTest Summary:\n")
    local passed = 0
    local failed = 0
    for _, result in ipairs(test_state.test_results) do
      if result.status == "PASS" then
        passed = passed + 1
      elseif result.status == "FAIL" then
        failed = failed + 1
      end
    end
    
    file:write(string.format("Total: %d, Passed: %d, Failed: %d\n", #test_state.test_results, passed, failed))
    file:close()
    
    print("\n✓ Test report saved to: " .. report_path)
  else
    print("\n✗ Failed to generate test report")
  end
end

-- Main execution
print("DevToolbox Font Integration CLI Test v" .. VERSION)
print("Testing from: " .. devtoolbox_path)
print("")

local success = run_all_tests()
generate_report()

if success then
  print("\n🎉 Font integration testing completed successfully!")
  print("   Ready for EnviREAment virtual testing and deployment.")
else
  print("\n⚠️  Font integration testing found issues.")
  print("   Please address failures before proceeding to EnviREAment testing.")
end

return {
  run_tests = run_all_tests,
  get_results = function() return test_state.test_results end
}
