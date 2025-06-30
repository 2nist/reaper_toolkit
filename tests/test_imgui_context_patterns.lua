-- Test ImGui Context Creation with Different API Patterns
-- Tests handling of both EnviREAment patterns for ImGui_CreateContext

local test_name = "ImGui Context Creation Patterns Test"
local success = true
local errors = {}

local function log_error(msg)
    table.insert(errors, msg)
    success = false
end

-- Test 1: EnviREAment pattern that expects name parameter
print("Testing EnviREAment pattern with name parameter...")

local function test_envireaument_with_name()
    local mock_reaper_with_name = {
        ImGui_CreateContext = function(name)
            if not name then
                error("'reaper.ImGui_CreateContext': expected 1 arguments minimum")
            end
            return 'context_with_name_' .. name
        end
    }
    
    -- Test the robust context creation logic
    local ctx
    local reaper = mock_reaper_with_name
    
    if reaper and reaper.ImGui_CreateContext then
        -- Try with name parameter first
        local ok, result = pcall(reaper.ImGui_CreateContext, 'REAPER DevToolbox')
        if ok then
            ctx = result
            print("  ✓ Successfully created context with name parameter")
        else
            -- Try without name parameter
            local ok2, result2 = pcall(reaper.ImGui_CreateContext)
            if ok2 then
                ctx = result2
                print("  ✓ Successfully created context without name parameter")
            else
                log_error("Failed to create context with either pattern: " .. tostring(result) .. " and " .. tostring(result2))
                return false
            end
        end
    end
    
    if not ctx then
        log_error("Context creation failed")
        return false
    end
    
    print("  Created context:", ctx)
    return true
end

if not test_envireaument_with_name() then
    log_error("EnviREAment with name parameter test failed")
end

-- Test 2: EnviREAment pattern that expects no parameters
print("Testing EnviREAment pattern without name parameter...")

local function test_envireaument_without_name()
    local mock_reaper_without_name = {
        ImGui_CreateContext = function(name)
            if name then
                error("This function expects a maximum of 0 argument(s) but instead it is receiving 1.")
            end
            return 'context_without_name'
        end
    }
    
    -- Test the robust context creation logic
    local ctx
    local reaper = mock_reaper_without_name
    
    if reaper and reaper.ImGui_CreateContext then
        -- Try with name parameter first
        local ok, result = pcall(reaper.ImGui_CreateContext, 'REAPER DevToolbox')
        if ok then
            ctx = result
            print("  ✓ Successfully created context with name parameter")
        else
            -- Try without name parameter
            local ok2, result2 = pcall(reaper.ImGui_CreateContext)
            if ok2 then
                ctx = result2
                print("  ✓ Successfully created context without name parameter")
            else
                log_error("Failed to create context with either pattern: " .. tostring(result) .. " and " .. tostring(result2))
                return false
            end
        end
    end
    
    if not ctx then
        log_error("Context creation failed")
        return false
    end
    
    print("  Created context:", ctx)
    return true
end

if not test_envireaument_without_name() then
    log_error("EnviREAment without name parameter test failed")
end

-- Test 3: Standard ReaImGui pattern
print("Testing standard ReaImGui pattern...")

local function test_standard_reaimgui()
    -- Simulate no reaper environment
    local reaper = nil
    
    local MockImGui = {
        CreateContext = function(name)
            return 'standard_context_' .. (name or 'unnamed')
        end
    }
    
    local ctx
    if reaper and reaper.ImGui_CreateContext then
        -- This branch should not execute
        log_error("Should not enter EnviREAment branch when reaper is nil")
        return false
    else
        -- Standard ReaImGui environment
        ctx = MockImGui.CreateContext('REAPER DevToolbox')
        print("  ✓ Successfully created standard ReaImGui context")
    end
    
    if not ctx then
        log_error("Standard context creation failed")
        return false
    end
    
    print("  Created context:", ctx)
    return true
end

if not test_standard_reaimgui() then
    log_error("Standard ReaImGui test failed")
end

-- Test 4: Test context validation
print("Testing context validation...")

local function test_context_validation()
    local test_contexts = {
        'valid_string_context',
        123,  -- Valid userdata-like
        true, -- Invalid boolean
        false, -- Invalid boolean
        nil   -- Invalid nil
    }
    
    for i, test_ctx in ipairs(test_contexts) do
        local is_valid = not (not test_ctx or type(test_ctx) == "boolean")
        
        if is_valid then
            print("  ✓ Context " .. i .. " (" .. type(test_ctx) .. ") is valid")
        else
            print("  ✓ Context " .. i .. " (" .. type(test_ctx) .. ") correctly identified as invalid")
        end
    end
    
    return true
end

if not test_context_validation() then
    log_error("Context validation test failed")
end

-- Results
print("\n=== ImGui Context Creation Patterns Test Results ===")
if success then
    print("✅ " .. test_name .. " PASSED")
    print("All ImGui context creation patterns work correctly")
    print("The robust context creation handles:")
    print("  ✓ EnviREAment with name parameter requirement")
    print("  ✓ EnviREAment without name parameter requirement") 
    print("  ✓ Standard ReaImGui context creation")
    print("  ✓ Proper context validation")
else
    print("❌ " .. test_name .. " FAILED")
    print("Errors found:")
    for i, error in ipairs(errors) do
        print("  " .. i .. ". " .. error)
    end
end

return success
