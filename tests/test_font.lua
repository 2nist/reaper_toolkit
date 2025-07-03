-- Test font loading
local info = debug.getinfo(1, 'S')
local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
print("Script path: " .. (script_path or "nil"))

local dymo_path = script_path .. "fonts/Dymo.ttf"
print("Dymo font path: " .. dymo_path)

-- Check if file exists
local f = io.open(dymo_path, "r")
if f then
    f:close()
    print("✓ Dymo font file found")
else
    print("✗ Dymo font file NOT found")
end

-- Test alternative path resolution
local alt_path = script_path:gsub("panels[/\\]?$", "") .. "fonts/Dymo.ttf"
print("Alternative path: " .. alt_path)

local f2 = io.open(alt_path, "r")
if f2 then
    f2:close()
    print("✓ Alternative path works")
else
    print("✗ Alternative path doesn't work")
end
