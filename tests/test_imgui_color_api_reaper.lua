--[[
  Automated ImGui Color API Signature Test for REAPER
  Place this in REAPER's Scripts folder and run from the Action List.
  It will log results to the REAPER console.
  You can adapt this for EnviREAment automation as well.
--]]

local function log(msg)
  reaper.ShowConsoleMsg(tostring(msg) .. "\n")
end

local function test(desc, fn)
  local ok, err = pcall(fn)
  if ok then
    log("[PASS] " .. desc)
  else
    log("[FAIL] " .. desc .. " | Error: " .. tostring(err))
  end
end

-- Setup: create a context if needed
local ctx = nil
if reaper.ImGui_CreateContext then
  ctx = reaper.ImGui_CreateContext('Test')
end

log("\n-- ColorEdit4 --")
test("ColorEdit4 correct", function()
  reaper.ImGui_ColorEdit4(ctx, "Label", 0xFF0000FF, 0)
end)
test("ColorEdit4 wrong label type", function()
  reaper.ImGui_ColorEdit4(ctx, 123, 0xFF0000FF, 0)
end)
test("ColorEdit4 wrong color type", function()
  reaper.ImGui_ColorEdit4(ctx, "Label", "notacolor", 0)
end)

log("\n-- ColorEdit3 --")
test("ColorEdit3 correct", function()
  reaper.ImGui_ColorEdit3(ctx, "Label", 0xFF0000, 0)
end)
test("ColorEdit3 wrong color type", function()
  reaper.ImGui_ColorEdit3(ctx, "Label", {}, 0)
end)

log("\n-- ColorPicker4 --")
test("ColorPicker4 correct", function()
  reaper.ImGui_ColorPicker4(ctx, "Label", 0xFF0000FF, 0, 0x00FF00FF)
end)
test("ColorPicker4 wrong ref_col type", function()
  reaper.ImGui_ColorPicker4(ctx, "Label", 0xFF0000FF, 0, "bad")
end)

log("\n-- ColorPicker3 --")
test("ColorPicker3 correct", function()
  reaper.ImGui_ColorPicker3(ctx, "Label", 0xFF0000, 0)
end)
test("ColorPicker3 wrong color type", function()
  reaper.ImGui_ColorPicker3(ctx, "Label", nil, 0)
end)

log("\n-- ColorButton --")
test("ColorButton correct", function()
  reaper.ImGui_ColorButton(ctx, "Btn", 0xFF0000FF, 0, 20, 20)
end)
test("ColorButton wrong size type", function()
  reaper.ImGui_ColorButton(ctx, "Btn", 0xFF0000FF, 0, "big", "big")
end)

log("\n-- SetColorEditOptions --")
test("SetColorEditOptions correct", function()
  reaper.ImGui_SetColorEditOptions(ctx, 0)
end)
test("SetColorEditOptions wrong flags type", function()
  reaper.ImGui_SetColorEditOptions(ctx, "bad")
end)

log("\n---- Test Complete ----\n")
