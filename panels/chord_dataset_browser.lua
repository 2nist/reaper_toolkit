--[[
  chord_dataset_browser.lua
  ReaImGui panel to browse chord progression index in REAPER
]]
local M = {}
local M = {}

-- Load and cache the chord index from generated Lua file
function M.init()
  -- define global fallback
  CHORD_INDEX = CHORD_INDEX or {}
  local script_path = debug.getinfo(1, "S").source:sub(2):match("(.+[/\\])") or ""
  local index_file = script_path .. "chord_dataset_index.lua"
  local ok, err = pcall(dofile, index_file)
  if not ok then
    reaper.ShowMessageBox("Failed to load chord index: " .. tostring(err), "Error", 0)
  end
  -- cache locally
  M.chord_index = CHORD_INDEX
  -- pagination defaults
  M.page = 1
  M.items_per_page = 10
  -- filter string for chord names
  M.filter_query = M.filter_query or ""
end

-- Draw function called by DevToolbox
function M.draw(ctx)
  -- show message if no data loaded
  if not M.chord_index or #M.chord_index == 0 then
    reaper.ImGui_Text(ctx, "⚠️ No chord index found. Run export-lua-index to generate.")
    return
  end
  -- filter input for chord names
  reaper.ImGui_Text(ctx, "Filter chords:")
  reaper.ImGui_SameLine(ctx)
  local changed, new_filter = reaper.ImGui_InputText(ctx, "##filter", M.filter_query, 256)
  if changed then
    M.filter_query = new_filter
    M.page = 1
  end

  -- toggle for showing note details
  M.show_notes = M.show_notes or false
  local notes_changed, notes_val = reaper.ImGui_Checkbox(ctx, "Show note details", M.show_notes)
  if notes_changed then
    M.show_notes = notes_val
  end

  -- apply filter to build display list
  local entries = {}
  for _, entry in ipairs(M.chord_index) do
    local chord_line = table.concat(entry.chords, " ")
    if M.filter_query == "" or string.find(chord_line, M.filter_query, 1, true) then
      table.insert(entries, entry)
    end
  end
  -- calculate pagination on filtered list
  local total = #entries
  local total_pages = math.ceil(total / M.items_per_page)
  reaper.ImGui_Text(ctx, string.format("Page %d / %d", M.page, total_pages))

  if reaper.ImGui_Button(ctx, "Prev") then
    if M.page > 1 then M.page = M.page - 1 end
  end
  reaper.ImGui_SameLine(ctx)
  if reaper.ImGui_Button(ctx, "Next") then
    if M.page < total_pages then M.page = M.page + 1 end
  end

  reaper.ImGui_SameLine(ctx)
  reaper.ImGui_Text(ctx, "Items per page:")
  reaper.ImGui_SameLine(ctx)
  local changed, val = reaper.ImGui_InputInt(ctx, "##items", M.items_per_page, 0)
  if changed and val > 0 then
    M.items_per_page = val
    M.page = 1
  end

  -- display filtered entries
  local start_idx = (M.page - 1) * M.items_per_page + 1
  local end_idx = math.min(total, M.page * M.items_per_page)
  for i = start_idx, end_idx do
    local entry = entries[i]
    if entry then
      reaper.ImGui_Text(ctx, string.format("%3d: %s", entry.id, table.concat(entry.chords, " ")))
      
      -- Show note details if enabled and available
      if M.show_notes and entry.details then
        reaper.ImGui_Indent(ctx)
        for j, detail in ipairs(entry.details) do
          if detail.notes and #detail.notes > 0 then
            local notes_str = table.concat(detail.notes, ", ")
            reaper.ImGui_Text(ctx, string.format("    %s: %s", detail.name or entry.chords[j], notes_str))
          end
        end
        reaper.ImGui_Unindent(ctx)
      end
    end
  end
end

return M
