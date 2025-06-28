--[[
  ReaImGui API Acceptance Test Auto-Generator
  1. Discovers all reaper.ImGui_* functions.
  2. Tries a set of argument patterns for each.
  3. Writes a test script for each function/signature that succeeds.
  4. Writes a batch runner to run all generated tests.
  Place this in your Scripts folder and run from the Action List.
--]]

local ctx = reaper.ImGui_CreateContext('AutoGenTest')
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

local test_dir = reaper.GetResourcePath() .. '/ReaImGui_AutoTests/'
os.execute('mkdir -p "' .. test_dir .. '"')
local batch_list = {}

local function args_to_str(args)
  local t = {}
  for i, v in ipairs(args) do
    if type(v) == 'string' then t[#t+1] = string.format('%q', v)
    elseif type(v) == 'number' then t[#t+1] = tostring(v)
    elseif type(v) == 'userdata' then t[#t+1] = 'ctx' else t[#t+1] = 'nil' end
  end
  return table.concat(t, ', ')
end

for k, v in pairs(reaper) do
  if tostring(k):match('^ImGui_') and type(v) == 'function' then
    for _, args in ipairs(tried_args) do
      local ok = pcall(function() v(table.unpack(args)) end)
      if ok then
        -- Write a test script for this function/signature
        local fname = test_dir .. k .. '_' .. #args .. 'args.lua'
        local f = io.open(fname, 'w')
        if not f then
          reaper.ShowConsoleMsg('[ERROR] Could not open file for writing: ' .. fname .. '\n')
        else
          f:write('-- Auto-generated test for ', k, '\n')
          f:write('local ctx = reaper.ImGui_CreateContext("Test")\n')
          f:write('local ok, err = pcall(function()\n')
          f:write('  reaper.', k, '(', args_to_str(args), ')\n')
          f:write('end)\n')
          f:write('local script_name = debug.getinfo(1, "S").source:match("@?(.*)")\n')
          f:write('local script_basename = script_name:match("([^/]+)$") or script_name\n')
          f:write('if ok then\n')
          f:write('  reaper.ShowConsoleMsg("[PASS] " .. script_basename .. "\\n")\n')
          f:write('else\n')
          f:write('  local sanitized_err = tostring(err):gsub("\\n", " ")\n')
          f:write('  reaper.ShowConsoleMsg("[FAIL] " .. script_basename .. ": " .. sanitized_err .. "\\n")\n')
          f:write('end\n')
          f:close()
          batch_list[#batch_list+1] = fname
        end
        break -- Only write the first passing signature
      end
    end
  end
end


local batch_path = test_dir .. 'run_all.lua'
local batch = io.open(batch_path, 'w')
if not batch then
  reaper.ShowConsoleMsg('[ERROR] Could not open batch runner for writing: ' .. batch_path .. '\n')
else
  batch:write('-- Auto-generated batch runner for all ImGui API tests\n')
  batch:write('local script_path = debug.getinfo(1, "S").source:match("@?(.*)")\n')
  batch:write('local script_dir = script_path:match("(.*/)") or ""\n\n')
  for _, fname in ipairs(batch_list) do
    local rel = fname:match('([^/]+%.lua)$')
    batch:write('dofile(script_dir .. "', rel, '")\n')
  end
  batch:close()
end

reaper.ShowConsoleMsg('Auto-generation complete. Test scripts written to: ' .. test_dir .. '\n')
