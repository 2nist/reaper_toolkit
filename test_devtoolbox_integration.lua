-- DevToolbox Integration Test
-- Tests the complete DevToolbox with font integration
-- Run this in REAPER to verify full integration

-- Setup paths
local script_path = debug.getinfo(1, 'S').source:match("@(.*)"):gsub("\\[^\\]*$", "")
package.path = script_path .. "\\modules\\?.lua;" .. package.path
package.path = script_path .. "\\?.lua;" .. package.path

-- Load main DevToolbox
local success, main_devtoolbox = pcall(function()
    return require("main")
end)

if success and main_devtoolbox then
    reaper.ShowConsoleMsg("✓ DevToolbox Integration Test: DevToolbox loaded successfully\n")
    reaper.ShowConsoleMsg("✓ Font selector panel should be available in DevToolbox\n")
    
    -- Run the main DevToolbox
    if type(main_devtoolbox.run) == "function" then
        main_devtoolbox.run()
    elseif type(main_devtoolbox.main) == "function" then
        main_devtoolbox.main()
    else
        reaper.ShowConsoleMsg("⚠️ DevToolbox main function not found\n")
    end
else
    reaper.ShowConsoleMsg("✗ DevToolbox Integration Test: Failed to load DevToolbox\n")
    reaper.ShowConsoleMsg("Error: " .. tostring(main_devtoolbox) .. "\n")
    reaper.ShowMessageBox("Failed to load DevToolbox.\n\nError: " .. tostring(main_devtoolbox), "DevToolbox Integration Test", 0)
end
