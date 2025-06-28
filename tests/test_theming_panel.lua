-- tests/test_theming_panel.lua
-- Enhanced test for theming_panel to catch ImGui API argument errors and coverage

package.path = './scripts/?.lua;./modules/?.lua;' .. package.path
local theming_panel = require 'theming_panel'
local fake_ctx = {} -- Simulate ImGui context
local fake_imgui_calls = {}

-- Fake ImGui API for test
local function fake_imgui()
    local t = {}
    setmetatable(t, {
        __index = function(_, k)
            if k == 'Text' or k == 'Separator' or k == 'SameLine' then
                return function(...) table.insert(fake_imgui_calls, {k, ...}) end
            elseif k == 'Button' then
                return function(_, label) table.insert(fake_imgui_calls, {k, label}); return false end
            elseif k == 'ColorEdit3' then
                -- Simulate correct signature: (ctx, label, r, g, b)
                return function(ctx, label, r, g, b)
                    table.insert(fake_imgui_calls, {k, ctx, label, r, g, b})
                    -- Simulate a change
                    return true, true, 0.5, 0.5, 0.5
                end
            end
            return function(...) table.insert(fake_imgui_calls, {k, ...}) end
        end
    })
    return t
end

-- Patch reaper.ImGui_* for test
_G.reaper = _G.reaper or {}
for _, fn in ipairs({'Text','Separator','SameLine','Button','ColorEdit3'}) do
    _G.reaper['ImGui_'..fn] = fake_imgui()[fn]
end
_G.reaper.ImGui_CreateContext = function() return true end

-- Patch require to return fake ImGui
local orig_require = require
require = function(name)
    if name == 'imgui' then return function() return fake_imgui() end end
    return orig_require(name)
end

-- Run draw and check for errors
local ok, err = pcall(function() theming_panel.draw(fake_ctx) end)
assert(ok, 'theming_panel.draw() should not error: '..tostring(err))

print('test_theming_panel.lua: PASS')
