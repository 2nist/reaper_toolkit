--[[
  Automated ReaImGui API Signature Discovery Script
  This script will attempt to call every reaper.ImGui_* function with various argument patterns
  and log which signatures succeed or fail. Results are printed to the REAPER console.
  Place this in your Scripts folder and run from the Action List.
--]]

local ctx = reaper.ImGui_CreateContext('SignatureTest')
local tried_args = {
  {ctx},
  {ctx, 'Test'},
  {ctx, 'Test', 0},
  {ctx, 'Test', 0, 0},
  {ctx, 0},
  {ctx, 0, 0},
  {ctx, 0, 0, 0},
  {'Test'},
  {'Test', 0},
  {0},
  {0, 0},
  {},
}

local function try_call(fn, args)
  local ok, err = pcall(function() fn(table.unpack(args)) end)
  return ok, err
end

for k, v in pairs(reaper) do
  if tostring(k):match('^ImGui_') and type(v) == 'function' then
    local found = false
    for _, args in ipairs(tried_args) do
      local ok, err = try_call(v, args)
      if ok then
        reaper.ShowConsoleMsg(k .. ' | args: (' .. table.concat(args, ', ') .. ') | OK\n')
        found = true
        break
      end
    end
    if not found then
      reaper.ShowConsoleMsg(k .. ' | No tested signature worked\n')
    end
  end
end

reaper.ShowConsoleMsg('--- Signature scan complete ---\n')
