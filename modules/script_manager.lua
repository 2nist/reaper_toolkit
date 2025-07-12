-- /modules/script_manager.lua
-- Handles loading, reloading, and managing all tools/scripts.

local M = {}

-- Safe console logger loading
local console_logger
local ok, cl = pcall(require, 'console_logger')
if ok then
    console_logger = cl
else
    -- Fallback console logger for standalone operation
    console_logger = {
        log = function(msg) print("[SCRIPT_MANAGER] " .. tostring(msg)) end,
        clear = function() end,
        get_messages = function() return {} end
    }
end

local tools = {}
local registry = {}
local sort_order = {}
local loaded_tools = {}
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
        
        -- Load the tools registry
        M.load_registry()
    else
        console_logger.log("Script manager initialized with a nil path.")
    end
end

-- Load the tools registry from tools_registry.lua
function M.load_registry()
    local registry_path = 'tools_registry'
    -- Clear any cached version
    package.loaded[registry_path] = nil
    
    -- Try to add the base path to package.path if needed
    if base_path and not package.path:find(base_path, 1, true) then
        package.path = base_path .. '?.lua;' .. package.path
    end
    
    local ok, reg = pcall(require, registry_path)
    if not ok and base_path then
        -- Try loading directly from the base path
        local full_path = base_path .. 'tools_registry.lua'
        console_logger.log("Trying direct load from: " .. full_path)
        ok, reg = pcall(dofile, full_path)
    end
    
    if ok and type(reg) == 'table' then
        registry = reg
        console_logger.log("Tools registry loaded successfully with " .. M.count_table(registry) .. " tools")
        for name, tool_info in pairs(registry) do
            console_logger.log("  - " .. name .. ": " .. (tool_info.active and "ACTIVE" or "INACTIVE"))
        end
        
        -- Initialize sort order after loading registry
        M.initialize_sort_order()
    else
        console_logger.log("Error loading tools registry: " .. tostring(reg))
        registry = {}
    end
end

-- Initialize the sort order for tools
function M.initialize_sort_order()
    sort_order = {}
    for name, _ in pairs(registry) do
        table.insert(sort_order, name)
    end
    -- Sort alphabetically by default
    table.sort(sort_order)
    console_logger.log("Initialized sort order with " .. #sort_order .. " tools")
end

-- Helper function to count table entries
function M.count_table(t)
    local count = 0
    for _ in pairs(t) do count = count + 1 end
    return count
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

-- Reloads all panels based on registry.
function M.reload_scripts()
    if not base_path or base_path == '' then
        console_logger.log("Script manager not initialized with path. Cannot load panels.")
        return
    end

    console_logger.log("Reloading panels based on registry...")
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

    -- Load only registered and active tools
    for name, tool_info in pairs(registry) do
        if tool_info.active then
            -- Use the file field from registry, or fallback to name
            local module_name = tool_info.file and tool_info.file:gsub('%.lua$', '') or name
            
            -- Clear from package cache to force reload
            package.loaded[module_name] = nil
            
            local ok, tool_module = pcall(require, module_name)
            if ok and type(tool_module) == 'table' then
                tools[name] = tool_module
                console_logger.log("Successfully loaded panel: " .. name .. " (" .. tool_info.label .. ")")
            else
                local err_msg = tostring(tool_module)
                tools[name] = nil
                package.loaded[module_name] = nil
                console_logger.log("Error loading panel '" .. name .. "':\n" .. err_msg)
            end
        else
            console_logger.log("Skipping inactive panel: " .. name .. " (" .. tool_info.label .. ")")
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

-- Returns the registry
function M.get_registry()
    return registry
end

-- Returns only active tools from registry
function M.get_active_tools()
    local active_tools = {}
    for name, tool_info in pairs(registry) do
        if tool_info.active then
            active_tools[name] = {
                tool = tools[name],
                info = tool_info
            }
        end
    end
    return active_tools
end

-- Toggle a tool's active status in memory (not persistent)
function M.toggle_tool(name)
    if registry[name] then
        registry[name].active = not registry[name].active
        console_logger.log("Toggled " .. name .. " to " .. (registry[name].active and "ACTIVE" or "INACTIVE"))
        
        -- If we're activating a tool, load it
        if registry[name].active then
            -- Use the file field from registry, or fallback to name
            local module_name = registry[name].file and registry[name].file:gsub('%.lua$', '') or name
            
            package.loaded[module_name] = nil
            local ok, tool_module = pcall(require, module_name)
            if ok and type(tool_module) == 'table' then
                tools[name] = tool_module
                if tool_module.init then
                    pcall(tool_module.init)
                end
                console_logger.log("Loaded and initialized: " .. name)
            else
                console_logger.log("Error loading " .. name .. ": " .. tostring(tool_module))
                registry[name].active = false
            end
        else
            -- If we're deactivating a tool, shut it down
            local tool = tools[name]
            if tool and tool.shutdown then
                pcall(tool.shutdown)
            end
            tools[name] = nil
            console_logger.log("Unloaded: " .. name)
        end
        
        return registry[name].active
    end
    return false
end

-- Get tool metadata by name
function M.get_tool_info(name)
    return registry[name]
end

-- Check if a tool is active
function M.is_tool_active(name)
    local tool = registry[name]
    return tool and tool.active or false
end

-- Get the current tool order
function M.get_tool_order()
    return sort_order
end

-- Reorder tools by moving from one index to another
function M.reorder_tools(from_idx, to_idx)
    if from_idx == to_idx or from_idx < 1 or to_idx < 1 or from_idx > #sort_order or to_idx > #sort_order then 
        return 
    end
    
    local item = table.remove(sort_order, from_idx)
    table.insert(sort_order, to_idx, item)
    console_logger.log("Reordered tools: moved " .. item .. " from position " .. from_idx .. " to " .. to_idx)
end

-- Find the index of a tool in the sort order
function M.index_of_tool(name)
    for i, n in ipairs(sort_order) do
        if n == name then return i end
    end
    return nil
end

-- Get the loaded tools for external access
function M.get_loaded_tools()
    return loaded_tools
end

-- Live reload all tool scripts at runtime
function M.reload_scripts_live()
    console_logger.log("Live reloading all tool scripts...")
    loaded_tools = {}
    
    -- First, shutdown existing tools
    for name, tool in pairs(tools) do
        if tool and tool.shutdown then
            local ok, err = pcall(tool.shutdown)
            if not ok then
                console_logger.log("Error shutting down tool '" .. name .. "': " .. tostring(err))
            end
        end
    end
    
    -- Clear tools table
    tools = {}
    
    -- Reload active tools from registry
    for name, entry in pairs(registry or {}) do
        if entry.active and entry.file then
            local file_path = base_path .. panels_dir_name .. "/" .. entry.file
            console_logger.log("Reloading: " .. file_path)
            
            -- Clear from package cache first
            package.loaded[name] = nil
            
            local success, tool_or_err = pcall(dofile, file_path)
            if success and type(tool_or_err) == "table" then
                loaded_tools[name] = tool_or_err
                tools[name] = tool_or_err
                console_logger.log("✓ Reloaded: " .. name)
                if reaper and reaper.ShowConsoleMsg then
                    reaper.ShowConsoleMsg("[DevToolbox] Reloaded: " .. name .. "\n")
                end
            else
                console_logger.log("✗ Error loading tool '" .. name .. "': " .. tostring(tool_or_err))
                if reaper and reaper.ShowConsoleMsg then
                    reaper.ShowConsoleMsg("[DevToolbox] Error loading tool '" .. name .. "': " .. tostring(tool_or_err) .. "\n")
                end
            end
        end
    end
    
    console_logger.log("Live reload completed. " .. M.count_table(loaded_tools) .. " tools loaded.")
end

return M
