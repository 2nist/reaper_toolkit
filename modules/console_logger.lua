-- /modules/console_logger.lua
-- A simple logger for the DevToolbox console.

local M = {}

local messages = {}

function M.log(message)
    table.insert(messages, os.date("[%Y-%m-%d %H:%M:%S] ") .. tostring(message))
    -- Keep the log from growing indefinitely
    if #messages > 200 then
        table.remove(messages, 1)
    end
end

function M.get_messages()
    return messages
end

function M.clear()
    messages = {}
end


-- Only hijack if not already hijacked and not in the virtual test environment
if reaper and type(reaper.ShowConsoleMsg) == "function" and not reaper._devtoolbox_console_hijacked and not (reaper._virtual or reaper._ENVIREAMENT or os.getenv("ENVIREAMENT")) then
    local old_ShowConsoleMsg = reaper.ShowConsoleMsg
    reaper.ShowConsoleMsg = function(...)
        local args = {...}
        local msg = table.concat(args, " ")
        M.log(msg)
        -- old_ShowConsoleMsg(msg) -- Uncomment to also print to the real REAPER console
    end
    reaper._devtoolbox_console_hijacked = true
end

return M
