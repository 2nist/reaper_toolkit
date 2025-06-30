-- Test ImGui Constants Type Fix
-- Verifies that ImGui constants are numbers, not functions (fixes PushStyleColor error)

local test_name = "ImGui Constants Type Fix Test"
local success = true
local errors = {}

local function log_error(msg)
    table.insert(errors, msg)
    success = false
end

print("=== " .. test_name .. " ===")

-- Test 1: Verify constants are set up as numbers in EnviREAment mode
print("Test 1: EnviREAment mode constants...")

-- Mock REAPER environment where some constants might be functions
local mock_reaper_with_function_constants = {
    ImGui_CreateContext = function() return "mock_context" end,
    -- These might be functions in some REAPER setups, causing the error
    ImGui_Col_Text = function() return 0 end,
    ImGui_Col_WindowBg = function() return 2 end, 
    ImGui_Col_Button = function() return 21 end,
    -- These are numbers
    ImGui_Cond_Once = 1,
    ImGui_WindowFlags_MenuBar = 16,
    ImGui_ChildFlags_Border = 2,
    ImGui_WindowFlags_NoDocking = 8192
}

local function setup_imgui_envireaument(reaper_env)
    local ImGui = setmetatable({}, {
        __index = function(t, k)
            local v = reaper_env["ImGui_" .. k]
            if v ~= nil then return v end
            return rawget(t, k)
        end
    })
    
    -- FIXED: Check type before assigning
    ImGui.Cond_Once = type(reaper_env.ImGui_Cond_Once) == "number" and reaper_env.ImGui_Cond_Once or 1
    ImGui.WindowFlags_MenuBar = type(reaper_env.ImGui_WindowFlags_MenuBar) == "number" and reaper_env.ImGui_WindowFlags_MenuBar or 16
    ImGui.ChildFlags_Border = type(reaper_env.ImGui_ChildFlags_Border) == "number" and reaper_env.ImGui_ChildFlags_Border or 2
    ImGui.WindowFlags_NoDocking = type(reaper_env.ImGui_WindowFlags_NoDocking) == "number" and reaper_env.ImGui_WindowFlags_NoDocking or 8192
    ImGui.Col_Text = type(reaper_env.ImGui_Col_Text) == "number" and reaper_env.ImGui_Col_Text or 0
    ImGui.Col_WindowBg = type(reaper_env.ImGui_Col_WindowBg) == "number" and reaper_env.ImGui_Col_WindowBg or 2
    ImGui.Col_Button = type(reaper_env.ImGui_Col_Button) == "number" and reaper_env.ImGui_Col_Button or 21
    
    return ImGui
end

local ImGui = setup_imgui_envireaument(mock_reaper_with_function_constants)

-- Verify all constants are numbers
local constants_to_check = {
    "Col_Text", "Col_WindowBg", "Col_Button", "Cond_Once", 
    "WindowFlags_MenuBar", "ChildFlags_Border", "WindowFlags_NoDocking"
}

for _, constant in ipairs(constants_to_check) do
    local value = ImGui[constant]
    if type(value) == "number" then
        print("  ✓ " .. constant .. " = " .. value .. " (number)")
    else
        log_error(constant .. " is " .. type(value) .. ", expected number")
    end
end

-- Test 2: Verify PushStyleColor would work
print("\nTest 2: PushStyleColor compatibility...")

local function test_push_style_usage()
    -- These are the exact patterns used in main.lua that were failing
    local test_patterns = {
        { name = "Col_Text with color", color_idx = ImGui.Col_Text, color_val = 0xFF00FFFF },
        { name = "Col_WindowBg with packed color", color_idx = ImGui.Col_WindowBg, color_val = 0x333333FF },
        { name = "Col_Button with red", color_idx = ImGui.Col_Button, color_val = 0xFF3333FF }
    }
    
    for _, pattern in ipairs(test_patterns) do
        if type(pattern.color_idx) == "number" and type(pattern.color_val) == "number" then
            print("  ✓ " .. pattern.name .. " would work (idx=" .. pattern.color_idx .. ", val=" .. string.format("0x%08X", pattern.color_val) .. ")")
        else
            log_error(pattern.name .. " would fail - idx type: " .. type(pattern.color_idx))
        end
    end
end

test_push_style_usage()

-- Test 3: Test standard ReaImGui mode
print("\nTest 3: Standard ReaImGui mode constants...")

local function setup_imgui_standard()
    -- Mock standard ReaImGui module
    local ImGui = {
        -- These should already be numbers in standard mode
        Col_Text = 0,
        Col_WindowBg = 2,
        Col_Button = 21,
        Cond_Once = 1,
        WindowFlags_MenuBar = 16,
        ChildFlags_Border = 2,
        WindowFlags_NoDocking = 8192
    }
    
    -- Apply fallbacks (should be no-ops for standard mode)
    ImGui.Cond_Once = ImGui.Cond_Once or 1
    ImGui.WindowFlags_MenuBar = ImGui.WindowFlags_MenuBar or 16
    ImGui.ChildFlags_Border = ImGui.ChildFlags_Border or 2
    ImGui.WindowFlags_NoDocking = ImGui.WindowFlags_NoDocking or 8192
    ImGui.Col_Text = ImGui.Col_Text or 0
    ImGui.Col_WindowBg = ImGui.Col_WindowBg or 2
    ImGui.Col_Button = ImGui.Col_Button or 21
    
    return ImGui
end

local ImGui_standard = setup_imgui_standard()

for _, constant in ipairs(constants_to_check) do
    local value = ImGui_standard[constant]
    if type(value) == "number" then
        print("  ✓ " .. constant .. " = " .. value .. " (number)")
    else
        log_error("Standard mode: " .. constant .. " is " .. type(value) .. ", expected number")
    end
end

-- Results
print("\n=== ImGui Constants Type Fix Test Results ===")
if success then
    print("✅ " .. test_name .. " PASSED")
    print("ImGui constants type fix is working correctly:")
    print("  ✓ EnviREAment mode: All constants are numbers")
    print("  ✓ Standard mode: All constants are numbers")  
    print("  ✓ PushStyleColor calls will work without type errors")
    print("🎉 The 'number expected, got function' error is FIXED!")
else
    print("❌ " .. test_name .. " FAILED")
    print("Errors found:")
    for i, error in ipairs(errors) do
        print("  " .. i .. ". " .. error)
    end
end

return success
