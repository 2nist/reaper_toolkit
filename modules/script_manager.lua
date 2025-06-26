-- /modules/script_manager.lua
-- Handles loading, reloading, and managing all tools/scripts.

local M = {}

local console_logger = require 'console_logger'

local tools = {}
local base_path = ''
local scripts_dir_name = 'scripts'
local scripts_path = ''

function M.init(path)
    base_path = path
    if base_path then
        scripts_path = base_path .. scripts_dir_name
        console_logger.log("Script manager initialized with path: " .. scripts_path)
    else
        console_logger.log("Script manager initialized with a nil path.")
    end
end

-- Scans the /scripts directory and returns a table of script names (without .lua)
local function get_script_names()
    if not scripts_path or scripts_path == '' then return {} end
    local names = {}
    local i = 0
    while true do
        local file = reaper.EnumerateFiles(scripts_path, i)
        if not file then break end
        if file:match('%.lua$') and file ~= 'init.lua' then
            local name = file:gsub('%.lua$', '')
            table.insert(names, name)
        end
        i = i + 1
    end
    return names
end

-- Reloads all scripts.
function M.reload_scripts()
    if not base_path or base_path == '' then
        console_logger.log("Script manager not initialized with path. Cannot load scripts.")
        return
    end

    console_logger.log("Reloading all scripts...")
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

    -- Get the list of script names to require
    local script_names = get_script_names()
    console_logger.log("Found scripts: " .. table.concat(script_names, ", "))

    -- Force a reload by clearing the entry in package.loaded
    for _, name in ipairs(script_names) do
        package.loaded[name] = nil
    end

    -- Require all scripts again
    for _, name in ipairs(script_names) do
        local ok, tool_module = pcall(require, name)
        if ok and type(tool_module) == 'table' then
            tools[name] = tool_module
            console_logger.log("Successfully loaded tool: " .. name)
        else
            local err_msg = tostring(tool_module)
            tools[name] = nil
            package.loaded[name] = nil
            console_logger.log("Error loading tool '" .. name .. "':\n" .. err_msg)
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
