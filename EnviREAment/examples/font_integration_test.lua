-- Font Integration Test for DevToolbox
-- Tests font_selector_panel.lua using EnviREAment virtual REAPER environment
-- Following SOP guidelines for EnviREAment testing

local VERSION = "1.0.0"
local TEST_NAME = "Font Integration Test"

-- Setup package path for DevToolbox modules
local script_path = debug.getinfo(1, 'S').source:match("@(.*)"):gsub("\\[^\\]*$", "")
local devtoolbox_path = script_path .. "\\..\\..\\DevToolbox"
package.path = devtoolbox_path .. "\\?.lua;" .. package.path
package.path = devtoolbox_path .. "\\modules\\?.lua;" .. package.path

-- Try to load ImGui (EnviREAment provides this)
package.path = reaper.ImGui_GetBuiltinPath() .. '/?.lua;' .. package.path
local ImGui = require 'imgui' '0.9.2'

-- Test state
local test_state = {
  ctx = nil,
  is_running = false,
  test_results = {},
  current_test = 1,
  font_manager = nil,
  font_selector = nil,
  tests = {
    "Font Manager Initialization",
    "Font Configuration Loading", 
    "Font Selector Panel Creation",
    "Font Application Test",
    "Font Cleanup Test"
  }
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
  reaper.ShowConsoleMsg(string.format("[%s] %s: %s\n", status_icon, test_name, message))
end

-- Test 1: Font Manager Initialization
local function test_font_manager_init()
  log_test("Font Manager Init", "INFO", "Starting font manager initialization test")
  
  local success, font_manager = pcall(function()
    return require("font_manager")
  end)
  
  if success and font_manager then
    test_state.font_manager = font_manager
    log_test("Font Manager Load", "PASS", "Font manager module loaded successfully")
    
    -- Test initialization
    if type(font_manager.init) == "function" then
      local init_success, err = pcall(function()
        font_manager.init()
      end)
      
      if init_success then
        log_test("Font Manager Init", "PASS", "Font manager initialized successfully")
        return true
      else
        log_test("Font Manager Init", "FAIL", "Init failed: " .. tostring(err))
        return false
      end
    else
      log_test("Font Manager Init", "FAIL", "No init function found")
      return false
    end
  else
    log_test("Font Manager Load", "FAIL", "Failed to load: " .. tostring(font_manager))
    return false
  end
end

-- Test 2: Font Configuration Loading
local function test_font_config_loading()
  log_test("Font Config Test", "INFO", "Testing font configuration loading")
  
  local success, font_config = pcall(function()
    return require("font_config")
  end)
  
  if success and font_config then
    log_test("Font Config Load", "PASS", "Font config module loaded")
    
    if font_config.fonts and type(font_config.fonts) == "table" then
      local font_count = 0
      for _ in pairs(font_config.fonts) do
        font_count = font_count + 1
      end
      
      log_test("Font Config Parse", "PASS", string.format("Found %d fonts in configuration", font_count))
      return font_count > 0
    else
      log_test("Font Config Parse", "FAIL", "No fonts table found in config")
      return false
    end
  else
    log_test("Font Config Load", "FAIL", "Failed to load: " .. tostring(font_config))
    return false
  end
end

-- Test 3: Font Selector Panel Creation
local function test_font_selector_creation()
  log_test("Font Selector Test", "INFO", "Testing font selector panel creation")
  
  local success, font_selector = pcall(function()
    return require("font_selector_panel")
  end)
  
  if success and font_selector then
    test_state.font_selector = font_selector
    log_test("Font Selector Load", "PASS", "Font selector panel loaded")
    
    -- Test required functions
    local required_functions = {"render", "init"}
    for _, func_name in ipairs(required_functions) do
      if type(font_selector[func_name]) == "function" then
        log_test("Function Check", "PASS", func_name .. " function exists")
      else
        log_test("Function Check", "FAIL", func_name .. " function missing")
        return false
      end
    end
    
    -- Test initialization
    if type(font_selector.init) == "function" then
      local init_success, err = pcall(function()
        font_selector.init()
      end)
      
      if init_success then
        log_test("Font Selector Init", "PASS", "Font selector initialized")
        return true
      else
        log_test("Font Selector Init", "FAIL", "Init failed: " .. tostring(err))
        return false
      end
    end
  else
    log_test("Font Selector Load", "FAIL", "Failed to load: " .. tostring(font_selector))
    return false
  end
end

-- Test 4: Font Application Test
local function test_font_application()
  log_test("Font Application", "INFO", "Testing font application functionality")
  
  if not test_state.font_manager then
    log_test("Font Application", "FAIL", "Font manager not available")
    return false
  end
  
  -- Test font push/pop cycle
  if type(test_state.font_manager.push_font) == "function" and 
     type(test_state.font_manager.pop_font) == "function" then
    
    local success, err = pcall(function()
      -- Test with a default font
      test_state.font_manager.push_font(test_state.ctx, "Consolas", 14)
      test_state.font_manager.pop_font(test_state.ctx)
    end)
    
    if success then
      log_test("Font Push/Pop", "PASS", "Font push/pop cycle completed")
      return true
    else
      log_test("Font Push/Pop", "FAIL", "Error: " .. tostring(err))
      return false
    end
  else
    log_test("Font Application", "FAIL", "Push/Pop functions not available")
    return false
  end
end

-- Test 5: Font Cleanup Test
local function test_font_cleanup()
  log_test("Font Cleanup", "INFO", "Testing font cleanup")
  
  if test_state.font_manager and type(test_state.font_manager.cleanup) == "function" then
    local success, err = pcall(function()
      test_state.font_manager.cleanup()
    end)
    
    if success then
      log_test("Font Cleanup", "PASS", "Font cleanup completed")
      return true
    else
      log_test("Font Cleanup", "FAIL", "Error: " .. tostring(err))
      return false
    end
  else
    log_test("Font Cleanup", "PASS", "No cleanup function (optional)")
    return true
  end
end

-- Test runner
local function run_tests()
  log_test("Test Suite", "INFO", "Starting DevToolbox Font Integration Tests")
  
  local test_functions = {
    test_font_manager_init,
    test_font_config_loading,
    test_font_selector_creation,
    test_font_application,
    test_font_cleanup
  }
  
  local passed = 0
  local failed = 0
  
  for i, test_func in ipairs(test_functions) do
    test_state.current_test = i
    local result = test_func()
    if result then
      passed = passed + 1
    else
      failed = failed + 1
    end
  end
  
  log_test("Test Suite", "INFO", string.format("Tests completed: %d passed, %d failed", passed, failed))
  return failed == 0
end

-- UI Loop for test display
local function test_ui_loop()
  if not test_state.ctx or not test_state.is_running then
    return
  end
  
  -- Begin main window
  local window_flags = ImGui.WindowFlags_None
  ImGui.SetNextWindowSize(test_state.ctx, 800, 600, ImGui.Cond_FirstUseEver)
  local open = ImGui.Begin(test_state.ctx, TEST_NAME .. " v" .. VERSION, true, window_flags)
  
  if open then
    -- Test status
    ImGui.Text(test_state.ctx, "Font Integration Test Suite")
    ImGui.Separator(test_state.ctx)
    
    -- Run tests button
    if ImGui.Button(test_state.ctx, "Run Font Tests") then
      test_state.test_results = {}
      run_tests()
    end
    
    ImGui.SameLine(test_state.ctx)
    if ImGui.Button(test_state.ctx, "Clear Results") then
      test_state.test_results = {}
    end
    
    -- Test results display
    if #test_state.test_results > 0 then
      ImGui.Separator(test_state.ctx)
      ImGui.Text(test_state.ctx, "Test Results:")
      
      if ImGui.BeginChild(test_state.ctx, "TestResults", 0, -30) then
        for _, result in ipairs(test_state.test_results) do
          local color = result.status == "PASS" and 0xFF00FF00 or 
                       result.status == "FAIL" and 0xFF0000FF or 
                       0xFFFFFFFF
          
          ImGui.TextColored(test_state.ctx, color, 
            string.format("[%s] %s: %s", result.status, result.name, result.message))
        end
        ImGui.EndChild(test_state.ctx)
      end
    end
    
    -- Font selector panel test (if available)
    if test_state.font_selector and type(test_state.font_selector.render) == "function" then
      ImGui.Separator(test_state.ctx)
      ImGui.Text(test_state.ctx, "Font Selector Panel Test:")
      
      local render_success, err = pcall(function()
        test_state.font_selector.render(test_state.ctx)
      end)
      
      if not render_success then
        ImGui.TextColored(test_state.ctx, 0xFF0000FF, "Render Error: " .. tostring(err))
      end
    end
    
    ImGui.End(test_state.ctx)
  end
  
  if open then
    reaper.defer(test_ui_loop)
  else
    -- Cleanup
    if test_state.ctx then
      ImGui.DestroyContext(test_state.ctx)
    end
    log_test("Test Suite", "INFO", "Test environment shutdown")
  end
end

-- Initialize test environment
local function initialize_test()
  log_test("Test Environment", "INFO", "Initializing EnviREAment test environment")
  
  -- Create ImGui context
  test_state.ctx = ImGui.CreateContext(TEST_NAME .. " v" .. VERSION)
  if not test_state.ctx then
    log_test("Test Environment", "FAIL", "Failed to create ImGui context")
    return false
  end
  
  log_test("Test Environment", "PASS", "ImGui context created")
  return true
end

-- Main entry point
local function main()
  reaper.ShowConsoleMsg("\n==== " .. TEST_NAME .. " v" .. VERSION .. " ====\n")
  reaper.ShowConsoleMsg("Testing DevToolbox Font Integration using EnviREAment\n")
  reaper.ShowConsoleMsg("Following SOP guidelines for development testing\n\n")
  
  if initialize_test() then
    test_state.is_running = true
    log_test("Test Environment", "PASS", "Test environment initialized")
    
    -- Run initial tests
    run_tests()
    
    -- Start UI loop for interactive testing
    test_ui_loop()
  else
    log_test("Test Environment", "FAIL", "Failed to initialize test environment")
  end
end

-- Start the test
main()

-- Return test interface for external use
return {
  run_tests = run_tests,
  get_results = function() return test_state.test_results end,
  main = main
}
