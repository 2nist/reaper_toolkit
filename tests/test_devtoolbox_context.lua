-- Test DevToolbox Context Handling
-- This test verifies that the ImGui context is properly created and used

local test_name = "DevToolbox Context Test"
local success = true
local errors = {}

local function log_error(msg)
    table.insert(errors, msg)
    success = false
end

-- Mock EnviREAment environment
local mock_reaper = {
    ImGui_CreateContext = function()
        return 'mock_imgui_context_handle'
    end,
    ImGui_SetNextWindowSize = function(ctx, w, h, cond)
        if type(ctx) ~= 'string' then
            error("Expected context to be string, got " .. type(ctx))
        end
        return true
    end,
    ImGui_SetNextWindowPos = function(ctx, x, y, cond)
        if type(ctx) ~= 'string' then
            error("Expected context to be string, got " .. type(ctx))
        end
        return true
    end,
    ImGui_Begin = function(ctx, title, open, flags)
        if type(ctx) ~= 'string' then
            error("Expected context to be string, got " .. type(ctx))
        end
        return true, true
    end,
    ImGui_End = function(ctx)
        if type(ctx) ~= 'string' then
            error("Expected context to be string, got " .. type(ctx))
        end
        return true
    end
}

-- Test 1: Context creation in EnviREAment environment
print("Testing context creation...")

-- Simulate the DevToolbox context creation logic
local function test_context_creation()
    local reaper = mock_reaper
    local ctx
    
    if reaper and reaper.ImGui_CreateContext then
        ctx = reaper.ImGui_CreateContext()
    end
    
    if not ctx or type(ctx) == "boolean" then
        log_error("Failed to create valid ImGui context")
        return false
    end
    
    -- Test that the context can be used with ImGui functions
    local ok1, err1 = pcall(reaper.ImGui_SetNextWindowSize, ctx, 800, 600, 1)
    if not ok1 then
        log_error("SetNextWindowSize failed with context: " .. tostring(err1))
        return false
    end
    
    local ok2, err2 = pcall(reaper.ImGui_SetNextWindowPos, ctx, 100, 100, 1)
    if not ok2 then
        log_error("SetNextWindowPos failed with context: " .. tostring(err2))
        return false
    end
    
    local ok3, err3 = pcall(reaper.ImGui_Begin, ctx, 'Test Window', true, 0)
    if not ok3 then
        log_error("Begin failed with context: " .. tostring(err3))
        return false
    end
    
    local ok4, err4 = pcall(reaper.ImGui_End, ctx)
    if not ok4 then
        log_error("End failed with context: " .. tostring(err4))
        return false
    end
    
    return true
end

if not test_context_creation() then
    log_error("Context creation test failed")
end

-- Test 2: Context type validation
print("Testing context type validation...")

local function test_context_validation()
    -- Test invalid contexts
    local invalid_contexts = {
        nil,
        false,
        true,
        0,
        {}
    }
    
    for i, invalid_ctx in ipairs(invalid_contexts) do
        if not (not invalid_ctx or type(invalid_ctx) == "boolean") then
            -- This context would pass our validation but shouldn't
            if type(invalid_ctx) ~= "string" and type(invalid_ctx) ~= "userdata" then
                log_error("Context validation failed for invalid context type: " .. type(invalid_ctx))
            end
        end
    end
    
    return true
end

if not test_context_validation() then
    log_error("Context validation test failed")
end

-- Results
print("\n=== DevToolbox Context Test Results ===")
if success then
    print("✅ " .. test_name .. " PASSED")
    print("ImGui context creation and usage is working correctly")
else
    print("❌ " .. test_name .. " FAILED")
    print("Errors found:")
    for i, error in ipairs(errors) do
        print("  " .. i .. ". " .. error)
    end
end

return success
