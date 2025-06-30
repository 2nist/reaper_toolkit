-- /modules/script_manager.lua
-- Handles loading, reloading, and managing all tools/scripts.

local M = {}

local console_logger = require 'console_logger'

local tools = {}
local base_path = ''
local panels_dir_name = 'panels'  -- Changed from 'scripts' to 'panels'
local panels_path = ''

function M.init(path)
    base_path = path
    if base_path then
        if not base_path:match('[\\/]$') then
            base_path = base_path .. '/'
        end
        panels_path = base_path .. panels_dir_name
        console_logger.log("Script manager initialized with path: " .. panels_path)
    else
        console_logger.log("Script manager initialized with a nil path.")
    end
end

-- Scans the /panels directory and returns a table of panel names (without .lua)
local function get_panel_names()
    if not panels_path or panels_path == '' then return {} end
    local names = {}
    local i = 0
    while true do
        local file = reaper.EnumerateFiles(panels_path, i)
        if not file then break end
        if file:match('%.lua$') and file ~= 'init.lua' then
            local name = file:gsub('%.lua$', '')
            table.insert(names, name)
        end
        i = i + 1
    end
    return names
end

-- Reloads all panels.
function M.reload_scripts()
    if not base_path or base_path == '' then
        console_logger.log("Script manager not initialized with path. Cannot load panels.")
        return
    end

    console_logger.log("Reloading all panels...")
    -- Call shutdown on all currently loaded tools
    for name, tool in pairs(tools) do
        if tool and tool.shutdown then
            local ok, err = pcall(tool.shutdown)
            if not ok then
                console_logger.log("Error shutting down tool '" .. name .. "': " .. tostring(err))
            end
        end
    end
    tools = {}

    -- Get the list of panel names to require
    local panel_names = get_panel_names()
    console_logger.log("Found panels: " .. table.concat(panel_names, ", "))

    -- Force a reload by clearing the entry in package.loaded
    for _, name in ipairs(panel_names) do
        package.loaded[name] = nil
    end

    -- Require all panels again
    for _, name in ipairs(panel_names) do
        local ok, tool_module = pcall(require, name)
        if ok and type(tool_module) == 'table' then
            tools[name] = tool_module
            console_logger.log("Successfully loaded panel: " .. name)
        else
            local err_msg = tostring(tool_module)
            tools[name] = nil
            package.loaded[name] = nil
            console_logger.log("Error loading panel '" .. name .. "':\n" .. err_msg)
        end
    end
end

-- Calls the init() function on all loaded tools
function M.init_all()
    for name, tool in pairs(tools) do
        if tool and tool.init then
            local ok, err = pcall(tool.init)
            if not ok then
                console_logger.log("Error initializing tool '" .. name .. "': " .. tostring(err))
            end
        end
    end
end

-- Calls the shutdown() function on all loaded tools
function M.shutdown_all()
    for name, tool in pairs(tools) do
        if tool and tool.shutdown then
            pcall(tool.shutdown)
        end
    end
end

-- Returns the table of loaded tools
function M.get_tools()
    return tools
end

-- Returns a specific tool by name
function M.get_tool(name)
    return tools[name]
end

return M
