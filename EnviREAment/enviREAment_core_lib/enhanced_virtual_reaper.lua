---@diagnostic disable: redundant-parameter
#!/usr/bin/env lua
-- enhanced_virtual_reaper.lua
-- Comprehensive Virtual REAPER Environment for Advanced Script Testing
-- Based on REAPER v7.0+ and ReaImGui v0.9.3+ API Documentation
-- Provides realistic mock implementations for testing REAPER scripts

local EnhancedVirtualReaper = {}

-- ==================== ENHANCED STATE MANAGEMENT ====================

local VirtualState = {
  -- Global state
  time = 0,
  frame_count = 0,
  delta_time = 1/60, -- 60 FPS simulation
  
  -- ImGui state
  contexts = {},
  current_ctx = nil,
  window_stack = {},
  menu_stack = {},
  tab_stack = {},
  popup_stack = {},
  
  -- UI interaction state
  hovered_item = nil,
  active_item = nil,
  focused_item = nil,
  last_clicked = nil,
  keyboard_focus = nil,
  
  -- Testing features
  verbose_logging = true,
  performance_tracking = true,
  ui_validation = true,
  
  -- Statistics
  stats = {
    windows_created = 0,
    widgets_drawn = 0,
    api_calls = 0,
    errors = 0,
    warnings = 0,
    start_time = os.time()
  },

  -- Tempo and Time Signature State
  tempo_markers = {
    { time = 0.0, measure_offset = 0, beat_offset = 0.0, bpm = 120.0, timesig_num = 4, timesig_denom = 4, linear = true }
  }
}

-- ==================== LOGGING SYSTEM ====================

local function log_api_call(func_name, ...)
  VirtualState.stats.api_calls = VirtualState.stats.api_calls + 1
  if VirtualState.verbose_logging then
    local args = {...}
    local arg_str = ""
    if #args > 1 then -- Skip context parameter
      for i = 2, math.min(#args, 5) do -- Limit args shown
        if type(args[i]) == "string" then
          arg_str = arg_str .. '"' .. tostring(args[i]) .. '"'
        else
          arg_str = arg_str .. tostring(args[i])
        end
        if i < math.min(#args, 5) then arg_str = arg_str .. ", " end
      end
      if #args > 5 then arg_str = arg_str .. "..." end
    end
    print(string.format("[ImGui] %s(%s)", func_name, arg_str))
  end
end

local function log_warning(message)
  VirtualState.stats.warnings = VirtualState.stats.warnings + 1
  print("[WARNING] " .. message)
end

local function log_error(message)
  VirtualState.stats.errors = VirtualState.stats.errors + 1
  print("[ERROR] " .. message)
end

-- ==================== COMPREHENSIVE MOCK REAPER API ====================

local mock_reaper = {
  -- ==================== REAPER CORE FUNCTIONS ====================
  
  -- Console and messaging (must be first as it's used by other functions)
  ShowConsoleMsg = function(msg)
    if msg then
      io.write(msg)
      io.flush()
    end
  end,
  
  ShowMessageBox = function(msg, title, type)
    print("📋 [Virtual] Message Box: " .. (title or "Message"))
    print("   " .. (msg or "No message"))
    print("   Type: " .. (type or 0))
    return 1 -- Simulate user clicking OK
  end,

  -- MISSING API MOCKS FOR TESTS
  GetSet_ArrangeView2 = function(...)
    -- Simulate getting/setting arrange view; return dummy values
    -- (In real REAPER, returns start, end positions)
    if select('#', ...) == 6 then
      -- set mode
      return true
    else
      -- get mode
      return 0.0, 60.0
    end
  end,
  
  -- Version and system info
  GetAppVersion = function() return "7.0" end,
  GetOS = function() return "OSX64" end,
  GetNumAudioInputs = function() return 2 end,
  GetNumAudioOutputs = function() return 2 end,
  
  -- File system operations
  GetResourcePath = function()
    return "/Users/test/Library/Application Support/REAPER"
  end,
  
  GetPathSeparator = function()
    return package.config:sub(1,1) -- Returns OS-appropriate path separator
  end,
  
  -- File system operations
  file_exists = function(filepath)
    log_api_call("file_exists", filepath)
    if not filepath or filepath == "" then return false end
    local f = io.open(filepath, "r")
    if f then
      f:close()
      return true
    end
    return false
  end,
  
  EnumerateFiles = function(path, index)
    log_api_call("EnumerateFiles", path, index)
    if not path or path == "" then return nil end
    
    -- Mock file enumeration - returns some common file types for testing
    local mock_files = {
      "song1.jcrd", "song2.jcrd", "example.mid", "config.json",
      "chord_progression.txt", "metadata.json", "sample.lab"
    }
    
    if index < #mock_files then
      return mock_files[index + 1] -- Lua is 1-indexed, REAPER function is 0-indexed
    end
    return nil
  end,
  
  EnumerateSubdirectories = function(path, index)
    log_api_call("EnumerateSubdirectories", path, index)
    if not path or path == "" then return nil end
    
    -- Mock subdirectory enumeration
    local mock_dirs = {
      "datasets", "examples", "processed", "backup", "exports"
    }
    
    if index < #mock_dirs then
      return mock_dirs[index + 1] -- Lua is 1-indexed, REAPER function is 0-indexed
    end
    return nil
  end,
  
  -- Media operations
  InsertMedia = function(filename, pos)
    log_api_call("InsertMedia", filename, pos)
    print("📥 [Virtual] Inserted media: " .. (filename or "unknown") .. " at position " .. (pos or 0))
    VirtualState.stats.api_calls = VirtualState.stats.api_calls + 1
    return true
  end,
  
  -- Track management functions
  GetNumTracks = function()
    log_api_call("GetNumTracks")
    return 8 -- Mock project with 8 tracks
  end,
  
  GetTrack = function(proj, track_index)
    log_api_call("GetTrack", proj, track_index)
    if track_index >= 0 and track_index < 8 then
      return {
        id = track_index,
        name = "Track " .. (track_index + 1),
        volume = 1.0,
        pan = 0.0
      }
    end
    return nil
  end,
  
  CountSelectedTracks = function(proj)
    log_api_call("CountSelectedTracks", proj)
    return 1 -- Mock one selected track
  end,
  
  GetSelectedTrack = function(proj, track_index)
    log_api_call("GetSelectedTrack", proj, track_index)
    if track_index == 0 then
      return {id = 0, name = "Selected Track", volume = 1.0, pan = 0.0}
    end
    return nil
  end,
  
  InsertTrackAtIndex = function(track_index, want_defaults)
    log_api_call("InsertTrackAtIndex", track_index, want_defaults)
    print("🎼 [Virtual] Track inserted at index " .. (track_index or 0))
  end,
  
  DeleteTrack = function(track)
    log_api_call("DeleteTrack", track)
    print("🗑️ [Virtual] Track deleted")
  end,
  
  -- Track property functions
  GetTrackName = function(track)
    log_api_call("GetTrackName", track)
    if not track then return "" end
    return track.name or ("Track " .. (track.id + 1))
  end,
  
  SetTrackName = function(track, name)
    log_api_call("SetTrackName", track, name)
    if track then
      track.name = name or ""
      return true
    end
    return false
  end,
  
  GetTrackColor = function(track)
    log_api_call("GetTrackColor", track)
    if not track then return 0 end
    return track.color or 0x808080 -- Default gray color
  end,
  
  SetTrackColor = function(track, color)
    log_api_call("SetTrackColor", track, color)
    if track then
      track.color = color or 0x808080
      return true
    end
    return false
  end,
  
  GetTrackVolume = function(track)
    log_api_call("GetTrackVolume", track)
    if not track then return 1.0 end
    return track.volume or 1.0
  end,
  
  SetTrackVolume = function(track, volume)
    log_api_call("SetTrackVolume", track, volume)
    if track then
      track.volume = math.max(0.0, math.min(4.0, volume or 1.0))
      return true
    end
    return false
  end,
  
  GetTrackPan = function(track)
    log_api_call("GetTrackPan", track)
    if not track then return 0.0 end
    return track.pan or 0.0
  end,
  
  SetTrackPan = function(track, pan)
    log_api_call("SetTrackPan", track, pan)
    if track then
      track.pan = math.max(-1.0, math.min(1.0, pan or 0.0))
      return true
    end
    return false
  end,
  
  -- Track routing functions
  GetTrackNumSends = function(track, category)
    log_api_call("GetTrackNumSends", track, category)
    if not track then return 0 end
    track.sends = track.sends or {}
    return #track.sends
  end,
  
  CreateTrackSend = function(src_track, dest_track)
    log_api_call("CreateTrackSend", src_track, dest_track)
    if not src_track or not dest_track then return -1 end
    src_track.sends = src_track.sends or {}
    local send_idx = #src_track.sends
    table.insert(src_track.sends, {
      dest_track = dest_track,
      volume = 1.0,
      pan = 0.0,
      mute = false
    })
    print("🔗 [Virtual] Track send created from Track " .. src_track.id .. " to Track " .. dest_track.id)
    return send_idx
  end,
  
  GetTrackSendInfo_Value = function(track, category, send_idx, param_name)
    log_api_call("GetTrackSendInfo_Value", track, category, send_idx, param_name)
    if not track or not track.sends or not track.sends[send_idx + 1] then return 0.0 end
    local send = track.sends[send_idx + 1]
    if param_name == "D_VOL" then return send.volume or 1.0
    elseif param_name == "D_PAN" then return send.pan or 0.0
    elseif param_name == "B_MUTE" then return send.mute and 1.0 or 0.0
    end
    return 0.0
  end,
  
  SetTrackSendInfo_Value = function(track, category, send_idx, param_name, value)
    log_api_call("SetTrackSendInfo_Value", track, category, send_idx, param_name, value)
    if not track or not track.sends or not track.sends[send_idx + 1] then return false end
    local send = track.sends[send_idx + 1]
    if param_name == "D_VOL" then send.volume = value
    elseif param_name == "D_PAN" then send.pan = value
    elseif param_name == "B_MUTE" then send.mute = (value ~= 0)
    end
    return true
  end,
  
  -- TrackFX functions
  TrackFX_GetCount = function(track)
    log_api_call("TrackFX_GetCount", track)
    if not track then return 0 end
    track.fx = track.fx or {}
    return #track.fx
  end,
  
  TrackFX_AddByName = function(track, fx_name, recFX, instantiate)
    log_api_call("TrackFX_AddByName", track, fx_name, recFX, instantiate)
    if not track then return -1 end
    track.fx = track.fx or {}
    local fx_idx = #track.fx
    table.insert(track.fx, {
      name = fx_name or "Unknown FX",
      enabled = true,
      preset = "Default",
      params = {}
    })
    print("🎛️ [Virtual] FX added: " .. (fx_name or "Unknown FX") .. " to Track " .. track.id)
    return fx_idx
  end,
  
  TrackFX_GetFXName = function(track, fx_idx)
    log_api_call("TrackFX_GetFXName", track, fx_idx)
    if not track or not track.fx or not track.fx[fx_idx + 1] then return false, "" end
    return true, track.fx[fx_idx + 1].name or "Unknown FX"
  end,
  
  TrackFX_SetEnabled = function(track, fx_idx, enabled)
    log_api_call("TrackFX_SetEnabled", track, fx_idx, enabled)
    if not track or not track.fx or not track.fx[fx_idx + 1] then return false end
    track.fx[fx_idx + 1].enabled = enabled
    return true
  end,
  
  TrackFX_GetEnabled = function(track, fx_idx)
    log_api_call("TrackFX_GetEnabled", track, fx_idx)
    if not track or not track.fx or not track.fx[fx_idx + 1] then return false end
    return track.fx[fx_idx + 1].enabled or false
  end,
  
  TrackFX_GetParam = function(track, fx_idx, param_idx)
    log_api_call("TrackFX_GetParam", track, fx_idx, param_idx)
    if not track or not track.fx or not track.fx[fx_idx + 1] then return 0.0 end
    local fx = track.fx[fx_idx + 1]
    fx.params = fx.params or {}
    return fx.params[param_idx] or 0.5 -- Default parameter value
  end,
  
  TrackFX_SetParam = function(track, fx_idx, param_idx, value)
    log_api_call("TrackFX_SetParam", track, fx_idx, param_idx, value)
    if not track or not track.fx or not track.fx[fx_idx + 1] then return false end
    local fx = track.fx[fx_idx + 1]
    fx.params = fx.params or {}
    fx.params[param_idx] = value
    return true
  end,
  
  -- Media item functions
  CountMediaItems = function(proj)
    log_api_call("CountMediaItems", proj)
    return 4 -- Mock project with 4 media items
  end,
  
  GetMediaItem = function(proj, item_index)
    log_api_call("GetMediaItem", proj, item_index)
    if item_index >= 0 and item_index < 4 then
      return {
        id = item_index,
        position = item_index * 30.0,
        length = 25.0,
        track = item_index % 3
      }
    end
    return nil
  end,
  
  GetSelectedMediaItem = function(proj, item_index)
    log_api_call("GetSelectedMediaItem", proj, item_index)
    if item_index == 0 then
      return {id = 0, position = 0.0, length = 25.0, track = 0}
    end
    return nil
  end,
  
  CreateNewMIDIItemInProj = function(track, starttime, endtime, qnout)
    log_api_call("CreateNewMIDIItemInProj", track, starttime, endtime, qnout)
    print("🎹 [Virtual] MIDI item created from " .. (starttime or 0) .. " to " .. (endtime or 1))
    return {id = 999, position = starttime, length = (endtime or 1) - (starttime or 0)}
  end,
  
  -- MIDI functions
  MIDI_GetNote = function(take, noteidx)
    log_api_call("MIDI_GetNote", take, noteidx)
    -- Mock MIDI note data
    if noteidx >= 0 and noteidx < 10 then
      return true, false, false, 1000 + noteidx * 480, 1000 + (noteidx + 1) * 480, 0, 60 + noteidx, 100
    end
    return false
  end,
  
  MIDI_InsertNote = function(take, selected, muted, startppqpos, endppqpos, chan, pitch, vel, noSortIn)
    log_api_call("MIDI_InsertNote", take, selected, muted, startppqpos, endppqpos, chan, pitch, vel, noSortIn)
    print("🎵 [Virtual] MIDI note inserted: pitch " .. (pitch or 60) .. " vel " .. (vel or 100))
    return true
  end,
  
  MIDI_CountEvts = function(take)
    log_api_call("MIDI_CountEvts", take)
    return 10, 0, 0 -- notes, ccs, sysex
  end,
  
  -- Undo functions
  Undo_BeginBlock = function()
    log_api_call("Undo_BeginBlock")
    print("↶ [Virtual] Undo block started")
  end,
  
  Undo_EndBlock = function(description, flags)
    log_api_call("Undo_EndBlock", description, flags)
    print("↶ [Virtual] Undo block ended: " .. (description or "Action"))
  end,
  
  Undo_CanUndo2 = function(proj)
    log_api_call("Undo_CanUndo2", proj)
    return "Mock Undo Action"
  end,
  
  Undo_CanRedo2 = function(proj)
    log_api_call("Undo_CanRedo2", proj)
    return "Mock Redo Action"
  end,
  
  -- Dialog functions
  JS_Dialog_BrowseForFolder = function(caption, initial_folder)
    log_api_call("JS_Dialog_BrowseForFolder", caption, initial_folder)
    print("📁 [Virtual] Folder browser: " .. (caption or "Select Folder"))
    -- Simulate user selecting a folder
    local mock_path = "/Users/test/Documents/Datasets/MockDataset"
    return 1, mock_path -- retval=1 (success), selected path
  end,
  
  GetUserInputs = function(title, num_inputs, captions_csv, initial_csv, separator)
    log_api_call("GetUserInputs", title, num_inputs, captions_csv, initial_csv, separator)
    print("💬 [Virtual] User input dialog: " .. (title or "Input"))
    print("   Inputs requested: " .. (num_inputs or 1))
    print("   Captions: " .. (captions_csv or "Input"))
    
    -- Simulate user input - return the initial values or mock values
    local sep = separator or ","
    local mock_responses = {}
    
    if initial_csv and initial_csv ~= "" then
      VirtualState.last_user_input = initial_csv
    else
      -- Generate mock responses based on number of inputs
      for i = 1, (num_inputs or 1) do
        table.insert(mock_responses, "mock_input" .. i)
      end
      VirtualState.last_user_input = table.concat(mock_responses, sep)
    end
    
    return true, VirtualState.last_user_input
  end,
  
  GetUserFileNameForRead = function(filename, title, defext)
    log_api_call("GetUserFileNameForRead", filename, title, defext)
    print("📄 [Virtual] File selector (Read): " .. (title or "Select File"))
    print("   Default extension: " .. (defext or "any"))
    -- Simulate user selecting a file
    VirtualState.last_selected_file = "/Users/test/Documents/selected_file." .. (defext or "txt")
    return true, VirtualState.last_selected_file
  end,
  
  GetUserFileNameForWrite = function(filename, title, defext)
    log_api_call("GetUserFileNameForWrite", filename, title, defext)
    print("💾 [Virtual] File selector (Write): " .. (title or "Save File"))
    print("   Default extension: " .. (defext or "any"))
    -- Simulate user choosing a save location
    VirtualState.last_save_file = "/Users/test/Documents/save_file." .. (defext or "txt")
    return true, VirtualState.last_save_file
  end,
  
  -- Extension functions (commonly used with SWS/JS extensions)
  GetExtState = function(section, key)
    log_api_call("GetExtState", section, key)
    -- Mock extension state storage for testing
    VirtualState.ext_state = VirtualState.ext_state or {}
    local section_data = VirtualState.ext_state[section] or {}
    return section_data[key] or ""
  end,
  
  SetExtState = function(section, key, value, persist)
    log_api_call("SetExtState", section, key, value, persist)
    -- Mock extension state storage for testing
    VirtualState.ext_state = VirtualState.ext_state or {}
    VirtualState.ext_state[section] = VirtualState.ext_state[section] or {}
    VirtualState.ext_state[section][key] = value
  end,
  
  GetProjExtState = function(proj, section, key)
    log_api_call("GetProjExtState", proj, section, key)
    -- Mock project extension state
    return ""
  end,
  
  SetProjExtState = function(proj, section, key, value)
    log_api_call("SetProjExtState", proj, section, key, value)
    -- Mock project extension state storage
  end,
  
  DeleteExtState = function(section, key, persist)
    log_api_call("DeleteExtState", section, key, persist)
    if VirtualState.ext_state and VirtualState.ext_state[section] then
      VirtualState.ext_state[section][key] = nil
    end
  end,
  
  -- Command and action functions
  Main_OnCommand = function(command_id, flag)
    log_api_call("Main_OnCommand", command_id, flag)
    print("🎛️ [Virtual] Command executed: " .. tostring(command_id))
  end,
  
  NamedCommandLookup = function(command_name)
    log_api_call("NamedCommandLookup", command_name)
    -- Return a mock command ID for any named command
    return 1000 + (#command_name or 0) % 100
  end,
  
  ViewPrefs = function(page, id)
    log_api_call("ViewPrefs", page, id)
    print("⚙️ [Virtual] Preferences opened: " .. tostring(id))
  end,
  
  CF_ShellExecute = function(url_or_command)
    log_api_call("CF_ShellExecute", url_or_command)
    print("🌐 [Virtual] Shell execute: " .. (url_or_command or "unknown command"))
    return true
  end,
  
  CF_UrlEscape = function(url)
    log_api_call("CF_UrlEscape", url)
    if not url then return "" end
    -- Basic URL encoding simulation
    local escaped = url:gsub(" ", "%%20"):gsub("#", "%%23"):gsub("&", "%%26")
    return escaped
  end,
  
  -- JSON functions for data handling
  JSON_Parse = function(json_str)
    log_api_call("JSON_Parse", json_str)
    -- Simple JSON parser simulation
    if not json_str then return nil end
    print("📄 [Virtual] JSON parsed: " .. string.sub(json_str, 1, 50) .. "...")
    return {parsed = true, data = "mock_json_data", source = json_str}
  end,
  
  JSON_Stringify = function(obj)
    log_api_call("JSON_Stringify", obj)
    -- Simple JSON stringifier simulation
    if type(obj) == "table" then
      return '{"mock": "json_output", "type": "table"}'
    else
      return '{"mock": "json_output", "value": "' .. tostring(obj) .. '"}'
    end
  end,
  
  -- Directory operations (missing from basic implementation)
  FileIsDirectory = function(path)
    log_api_call("FileIsDirectory", path)
    -- Mock implementation - some paths are directories
    local dir_patterns = {"datasets", "examples", "Scripts", "Documents", "Music"}
    for _, pattern in ipairs(dir_patterns) do
      if path and path:find(pattern) then
        return true
      end
    end
    return false
  end,

  -- Defer system for UI loops
  defer = function(func) 
    if type(func) == "function" then
      -- In testing mode, we can choose to call immediately or simulate delay
      func()
    end
  end,
  
  -- Project and timeline functions
  GetProjectLength = function(proj)
    log_api_call("GetProjectLength", proj)
    return 240.0 -- Mock 4-minute project length
  end,
  
  GetCursorPosition = function()
    log_api_call("GetCursorPosition")
    return VirtualState.time or 0.0
  end,
  
  SetEditCurPos = function(time, moveview, seekplay)
    log_api_call("SetEditCurPos", time, moveview, seekplay)
    VirtualState.time = time or 0.0
  end,
  
  GetPlayPosition = function()
    log_api_call("GetPlayPosition")
    return VirtualState.time or 0.0
  end,
  
  GetPlayState = function()
    log_api_call("GetPlayState")
    return 0 -- 0=stopped, 1=playing, 2=paused, 5=recording, 6=record paused
  end,
  
  OnPlayButton = function()
    log_api_call("OnPlayButton")
    print("▶️ [Virtual] Play button pressed")
  end,
  
  StopPlayback = function()
    log_api_call("StopPlayback")
    print("⏹️ [Virtual] Playback stopped")
  end,
  
  -- Marker and region functions
  AddProjectMarker = function(proj, isregion, pos, rgnend, name, wantidx)
    log_api_call("AddProjectMarker", proj, isregion, pos, rgnend, name, wantidx)
    print("📍 [Virtual] Marker added: " .. (name or "Marker") .. " at " .. (pos or 0))
    return wantidx or 1
  end,
  
  EnumProjectMarkers = function(idx)
    log_api_call("EnumProjectMarkers", idx)
    -- Mock some project markers
    if idx == 0 then
      return true, false, 10.0, 0.0, "Intro", 1
    elseif idx == 1 then
      return true, false, 60.0, 0.0, "Verse", 2
    elseif idx == 2 then
      return true, false, 120.0, 0.0, "Chorus", 3
    end
    return false
  end,
  
  DeleteProjectMarker = function(proj, markrgnindexnumber, isrgn)
    log_api_call("DeleteProjectMarker", proj, markrgnindexnumber, isrgn)
    print("🗑️ [Virtual] Marker deleted: " .. (markrgnindexnumber or 0))
  end,
  
  SetProjectMarker = function(markrgnidx, isrgn, pos, rgnend, name)
    log_api_call("SetProjectMarker", markrgnidx, isrgn, pos, rgnend, name)
    print("📝 [Virtual] Marker updated: " .. (name or "Marker"))
  end,

  -- ==================== TEMPO AND TIME SIGNATURE FUNCTIONS ====================

  GetTempoTimeSigMarker = function(proj, ptidx)
    log_api_call("GetTempoTimeSigMarker", proj, ptidx)
    if VirtualState.tempo_markers[ptidx + 1] then
      local marker = VirtualState.tempo_markers[ptidx + 1]
      return true, marker.time, marker.measure_offset, marker.beat_offset, marker.bpm, marker.timesig_num, marker.timesig_denom, marker.linear
    end
    return false, 0, 0, 0, 0, 0, 0, false
  end,

  GetProjectTimeSignature2 = function(proj, time) -- time argument is often ignored by scripts, using first marker
    log_api_call("GetProjectTimeSignature2", proj, time)
    if VirtualState.tempo_markers[1] then
      local marker = VirtualState.tempo_markers[1] -- Typically reflects the start of the project or current effective
      return marker.timesig_num, marker.timesig_denom
    end
    return 4, 4 -- Default
  end,

  SetProjectTimeSignature2 = function(proj, time, num, den) -- time argument often for future use, applies to first marker
    log_api_call("SetProjectTimeSignature2", proj, time, num, den)
    if VirtualState.tempo_markers[1] then
      VirtualState.tempo_markers[1].timesig_num = num
      VirtualState.tempo_markers[1].timesig_denom = den
      print("🎼 [Virtual] Project time signature set to: " .. num .. "/" .. den)
      return true
    end
    return false
  end,

  GetTempo = function() -- Gets tempo at current edit cursor position (simplified)
    log_api_call("GetTempo")
    local currentTime = VirtualState.time or 0
    local effectiveBpm = 120.0
    for i = #VirtualState.tempo_markers, 1, -1 do
      if VirtualState.tempo_markers[i].time <= currentTime then
        effectiveBpm = VirtualState.tempo_markers[i].bpm
        break
      end
    end
    return effectiveBpm
  end,

  GetTempoAtTime = function(time)
    log_api_call("GetTempoAtTime", time)
    local effectiveBpm = 120.0
    if not VirtualState.tempo_markers or #VirtualState.tempo_markers == 0 then return effectiveBpm end
    local current_marker = VirtualState.tempo_markers[1]
    for _, marker in ipairs(VirtualState.tempo_markers) do
      if marker.time <= time then
        current_marker = marker
      else
        break
      end
    end
    return current_marker.bpm
  end,

  SetTempoTimeSigMarker = function(proj, ptidx, time, measurepos, beatpos, bpm, timesig_num, timesig_denom, lineartempo)
    log_api_call("SetTempoTimeSigMarker", proj, ptidx, time, measurepos, beatpos, bpm, timesig_num, timesig_denom, lineartempo)
    if VirtualState.tempo_markers[ptidx + 1] then
      VirtualState.tempo_markers[ptidx + 1] = {
        time = time, measure_offset = measurepos, beat_offset = beatpos,
        bpm = bpm, timesig_num = timesig_num, timesig_denom = timesig_denom, linear = lineartempo
      }
      table.sort(VirtualState.tempo_markers, function(a,b) return a.time < b.time end)
      print("⏱️ [Virtual] Tempo marker " .. ptidx .. " updated.")
      return true
    end
    return false
  end,

  AddTempoTimeSigMarker = function(proj, time, measurepos, beatpos, bpm, timesig_num, timesig_denom, lineartempo)
    log_api_call("AddTempoTimeSigMarker", proj, time, measurepos, beatpos, bpm, timesig_num, timesig_denom, lineartempo)
    local new_marker = {
      time = time, measure_offset = measurepos, beat_offset = beatpos,
      bpm = bpm, timesig_num = timesig_num, timesig_denom = timesig_denom, linear = lineartempo
    }
    table.insert(VirtualState.tempo_markers, new_marker)
    table.sort(VirtualState.tempo_markers, function(a,b) return a.time < b.time end)
    -- Find new index
    for i, marker in ipairs(VirtualState.tempo_markers) do
      if marker == new_marker then return i - 1 end
    end
    return #VirtualState.tempo_markers - 1
  end,

  DeleteTempoTimeSigMarker = function(proj, ptidx)
    log_api_call("DeleteTempoTimeSigMarker", proj, ptidx)
    if VirtualState.tempo_markers[ptidx + 1] then
      table.remove(VirtualState.tempo_markers, ptidx + 1)
      print("🗑️ [Virtual] Tempo marker " .. ptidx .. " deleted.")
      return true
    end
    return false
  end,

  CountTempoTimeSigMarkers = function(proj)
    log_api_call("CountTempoTimeSigMarkers", proj)
    return #VirtualState.tempo_markers
  end,

  TimeMap_GetDividedBpmAtTime = function(time)
    log_api_call("TimeMap_GetDividedBpmAtTime", time)
    -- This is a simplified version. Real implementation depends on project settings.
    return mock_reaper.GetTempoAtTime(time)
  end,

  TimeMap_GetBpmAtTime = function(time) -- Alias for GetTempoAtTime in this mock
    log_api_call("TimeMap_GetBpmAtTime", time)
    return mock_reaper.GetTempoAtTime(time)
  end,

  TimeMap2_timeToBeats = function(proj, time, measures_out, cml_out, fullbeats_out, cdenom_out)
    log_api_call("TimeMap2_timeToBeats", proj, time)
    local current_bpm = mock_reaper.GetTempoAtTime(time)
    local beats = (time / 60.0) * current_bpm

    -- Simplified calculation for measures and beats
    -- Assumes constant time signature for simplicity in mock
    local ts_num, ts_den = mock_reaper.GetProjectTimeSignature2(proj, time)
    ts_num = ts_num or 4
    ts_den = ts_den or 4 -- Should not be 0

    if ts_den == 0 then ts_den = 4 end -- Prevent division by zero

    local beats_per_measure = ts_num * (4 / ts_den) -- e.g. 4/4 -> 4 beats, 6/8 -> 3 beats (if quarter note is beat)
                                                 -- More accurately, ts_num for x/4, ts_num/2 for x/8 if quarter is beat.
                                                 -- For simplicity, let's assume ts_num is beats per measure if ts_den is 4.
    if beats_per_measure == 0 then beats_per_measure = 4 end


    local measures = math.floor(beats / beats_per_measure)
    local remaining_beats = beats - (measures * beats_per_measure)
    
    -- For cml_out (cumulative measures length in beats) - this is complex, simplified here
    local cml = measures * beats_per_measure

    -- For fullbeats_out (cumulative beats from project start)
    local full_beats_val = beats

    -- For cdenom_out (time signature denominator)
    local cdenom = ts_den
    
    -- Note: The REAPER API returns these values directly if pointers are passed.
    -- In Lua, we'd return them as multiple values.
    -- For a more accurate mock, one might need to store these in a table passed as cml_out etc. if that's how the script expects it.
    -- However, typical Lua usage is to get them as return values.
    -- Returning as multiple values: measures + 1, remaining_beats, cml, full_beats_val, cdenom
    return beats -- Primary return is total beats from start of project
                 -- The other out parameters are harder to mock simply without knowing how the calling Lua script handles them.
                 -- Typically, a script would pass tables to be filled.
                 -- For now, returning the main 'beats' value.
  end,

  TimeMap2_beatsToTime = function(proj, beats, measures_in)
    log_api_call("TimeMap2_beatsToTime", proj, beats, measures_in)
    -- Simplified: assumes constant tempo and time signature
    local current_bpm = mock_reaper.GetTempoAtTime(0) -- Tempo at project start for simplicity
    if current_bpm == 0 then current_bpm = 120.0 end -- Prevent division by zero
    
    local total_beats = beats
    if measures_in and measures_in > 0 then
        local ts_num, ts_den = mock_reaper.GetProjectTimeSignature2(proj, 0)
        ts_num = ts_num or 4
        ts_den = ts_den or 4
        if ts_den == 0 then ts_den = 4 end
        local beats_per_measure = ts_num * (4 / ts_den)
        if beats_per_measure == 0 then beats_per_measure = 4 end
        total_beats = (measures_in * beats_per_measure) + beats
    end
    
    local time = (total_beats / current_bpm) * 60.0
    return time
  end,
  
  -- ==================== ENHANCED IMGUI CONTEXT MANAGEMENT ====================
  
  ImGui_CreateContext = function(name)
    local ctx = {
      id = #VirtualState.contexts + 1,
      name = name or ("Context_" .. (#VirtualState.contexts + 1)),
      created_time = VirtualState.time,
      
      -- Window management
      windows = {},
      window_stack = {},
      
      -- Font management  
      fonts = {},
      font_stack = {},
      default_font = { id = 1, size = 13, name = "Default" },
      
      -- Style management
      style_colors = {},
      style_vars = {},
      color_stack = {},
      var_stack = {},
      
      -- Input state
      mouse_pos = {x = 100, y = 100},
      mouse_down = {false, false, false},
      keys_down = {},
      
      -- Frame state
      frame_count = 0,
      visible = true,
      wants_keyboard = false,
      wants_mouse = false
    }
    
    -- Initialize default style colors (Dark theme)
    ctx.style_colors = {
      [0] = 0xF2F2F2FF, -- Text
      [1] = 0x1B1B1BFF, -- WindowBg
      [2] = 0x26BFBFFF, -- Button
      [3] = 0x3BD6D6FF, -- ButtonHovered
      [4] = 0x1FA8A8FF, -- ButtonActive
      [5] = 0x292929FF  -- FrameBg
    }
    
    table.insert(VirtualState.contexts, ctx)
    VirtualState.current_ctx = ctx
    log_api_call("ImGui_CreateContext", ctx, name)
    VirtualState.stats.windows_created = VirtualState.stats.windows_created + 1
    return ctx
  end,
  
  ImGui_DestroyContext = function(ctx)
    if ctx then
      log_api_call("ImGui_DestroyContext", ctx)
      for i, c in ipairs(VirtualState.contexts) do
        if c.id == ctx.id then
          table.remove(VirtualState.contexts, i)
          if VirtualState.current_ctx == ctx then
            VirtualState.current_ctx = VirtualState.contexts[1] or nil
          end
          break
        end
      end
    end
  end,
  
  -- ==================== WINDOW MANAGEMENT ====================
  
  ImGui_Begin = function(ctx, name, open, flags)
    if not ctx then 
      log_error("ImGui_Begin called with nil context")
      return false, false 
    end
    
    flags = flags or 0
    open = open == nil and true or open
    
    local window = {
      name = name,
      open = open,
      flags = flags,
      pos = {x = 100 + (#ctx.window_stack * 20), y = 100 + (#ctx.window_stack * 20)},
      size = {w = 400, h = 300},
      visible = true,
      focused = #ctx.window_stack == 0, -- First window gets focus
      hovered = false,
      collapsed = false
    }
    
    -- Only track windows that are actually visible (Begin returned true)
    if window.visible then
      table.insert(ctx.window_stack, window)
      table.insert(VirtualState.window_stack, window)
    end
    
    log_api_call("ImGui_Begin", ctx, name, open, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    
    return window.visible, window.open
  end,
  
  ImGui_End = function(ctx)
    if not ctx then
      log_error("ImGui_End called with nil context")
      return
    end

    -- Only pop window if Begin was called and returned true
    if #ctx.window_stack > 0 then
      local window = table.remove(ctx.window_stack)
      -- Correctly pop from the global stack as well
      if #VirtualState.window_stack > 0 then
        table.remove(VirtualState.window_stack)
      end
      log_api_call("ImGui_End", ctx)
    else
      log_warning("Mismatched ImGui_End() call: No window on the stack.")
    end
  end,

  ImGui_BeginChild = function(ctx, str_id, width, height, border, flags)
    log_api_call("ImGui_BeginChild", ctx, str_id, width, height, border, flags)
    -- In the mock, we always succeed in creating the child window.
    -- We push a placeholder to the stack to track Begin/End calls.
    table.insert(ctx.window_stack, {name = str_id, type = "child"})
    return true
  end,

  ImGui_EndChild = function(ctx)
    log_api_call("ImGui_EndChild", ctx)
    if #ctx.window_stack > 0 then
      local child = ctx.window_stack[#ctx.window_stack]
      if child.type == "child" then
        table.remove(ctx.window_stack)
      else
        log_warning("Mismatched ImGui_EndChild() call: Top of stack is not a child window, but a '" .. (child.type or "window") .. "'.")
      end
    else
      log_warning("Mismatched ImGui_EndChild() call: No window on the stack.")
    end
  end,

  -- Window properties
  ImGui_SetNextWindowSize = function(ctx, width, height, cond)
    log_api_call("ImGui_SetNextWindowSize", ctx, width, height, cond)
  end,

  -- Cond_Once constant for compatibility (must be a number, not a function)
  ImGui_Cond_Once = 1,
  
  ImGui_SetNextWindowPos = function(ctx, x, y, cond, pivot_x, pivot_y)
    log_api_call("ImGui_SetNextWindowPos", ctx, x, y, cond)
  end,
  
  ImGui_GetWindowSize = function(ctx)
    log_api_call("ImGui_GetWindowSize", ctx)
    return 400, 300 -- Default size
  end,
  
  ImGui_GetWindowPos = function(ctx)
    log_api_call("ImGui_GetWindowPos", ctx)
    return 100, 100 -- Default position
  end,
  
  -- ==================== MENU SYSTEM ====================
  
  ImGui_BeginMenuBar = function(ctx)
    table.insert(VirtualState.menu_stack, "MenuBar")
    log_api_call("ImGui_BeginMenuBar", ctx)
    return true
  end,
  
  ImGui_EndMenuBar = function(ctx)
    table.remove(VirtualState.menu_stack)
    log_api_call("ImGui_EndMenuBar", ctx)
  end,
  
  ImGui_BeginMenu = function(ctx, label, enabled)
    table.insert(VirtualState.menu_stack, label)
    log_api_call("ImGui_BeginMenu", ctx, label, enabled)
    return enabled ~= false
  end,
  
  ImGui_EndMenu = function(ctx)
    local menu = table.remove(VirtualState.menu_stack)
    log_api_call("ImGui_EndMenu", ctx)
  end,
  
  ImGui_MenuItem = function(ctx, label, shortcut, selected, enabled)
    log_api_call("ImGui_MenuItem", ctx, label, shortcut, selected, enabled)
    return false -- Never clicked in virtual mode
  end,
  
  -- ==================== TAB SYSTEM ====================
  
  ImGui_BeginTabBar = function(ctx, str_id, flags)
    table.insert(VirtualState.tab_stack, str_id)
    log_api_call("ImGui_BeginTabBar", ctx, str_id, flags)
    return true
  end,
  
  ImGui_EndTabBar = function(ctx)
    local tab_bar = table.remove(VirtualState.tab_stack)
    log_api_call("ImGui_EndTabBar", ctx)
  end,
  
  ImGui_BeginTabItem = function(ctx, label, open, flags)
    log_api_call("ImGui_BeginTabItem", ctx, label, open, flags)
    return true, open
  end,
  
  ImGui_EndTabItem = function(ctx)
    log_api_call("ImGui_EndTabItem", ctx)
  end,
  
  -- ==================== WIDGETS ====================
  
  -- Text widgets
  ImGui_Text = function(ctx, text)
    log_api_call("ImGui_Text", ctx, text)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
  end,
  
  ImGui_TextColored = function(ctx, col, text)
    log_api_call("ImGui_TextColored", ctx, col, text)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
  end,
  
  ImGui_TextDisabled = function(ctx, text)
    log_api_call("ImGui_TextDisabled", ctx, text)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
  end,
  
  ImGui_TextWrapped = function(ctx, text)
    log_api_call("ImGui_TextWrapped", ctx, text)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
  end,
  
  ImGui_LabelText = function(ctx, label, text)
    log_api_call("ImGui_LabelText", ctx, label, text)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
  end,
  
  ImGui_BulletText = function(ctx, text)
    log_api_call("ImGui_BulletText", ctx, text)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
  end,
  
  -- Button widgets
  ImGui_Button = function(ctx, label, size_w, size_h)
    log_api_call("ImGui_Button", ctx, label, size_w, size_h)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false -- Never clicked in virtual mode
  end,
  
  ImGui_SmallButton = function(ctx, label)
    log_api_call("ImGui_SmallButton", ctx, label)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false
  end,
  
  ImGui_InvisibleButton = function(ctx, str_id, size_w, size_h, flags)
    log_api_call("ImGui_InvisibleButton", ctx, str_id, size_w, size_h, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false
  end,
  
  ImGui_ArrowButton = function(ctx, str_id, dir)
    log_api_call("ImGui_ArrowButton", ctx, str_id, dir)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false
  end,
  
  -- Input widgets
  ImGui_InputText = function(ctx, label, buf, buf_sz, flags, callback, user_data)
    log_api_call("ImGui_InputText", ctx, label, tostring(buf):sub(1,20).."...", buf_sz, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, buf -- No change in virtual mode
  end,
  
  ImGui_InputTextMultiline = function(ctx, label, buf, buf_sz, size_w, size_h, flags, callback, user_data)
    log_api_call("ImGui_InputTextMultiline", ctx, label, "...", buf_sz, size_w, size_h, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, buf
  end,
  
  ImGui_InputTextWithHint = function(ctx, label, hint, buf, buf_sz, flags, callback, user_data)
    log_api_call("ImGui_InputTextWithHint", ctx, label, hint, "...", buf_sz, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, buf
  end,
  
  ImGui_InputInt = function(ctx, label, v, step, step_fast, flags)
    log_api_call("ImGui_InputInt", ctx, label, v, step, step_fast, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, v
  end,
  
  ImGui_InputDouble = function(ctx, label, v, step, step_fast, format, flags)
    log_api_call("ImGui_InputDouble", ctx, label, v, step, step_fast, format, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, v
  end,
  
  -- Checkbox and radio
  ImGui_Checkbox = function(ctx, label, v)
    log_api_call("ImGui_Checkbox", ctx, label, v)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, v
  end,
  
  ImGui_CheckboxFlags = function(ctx, label, flags, flags_value)
    log_api_call("ImGui_CheckboxFlags", ctx, label, flags, flags_value)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, flags
  end,
  
  ImGui_RadioButton = function(ctx, label, active)
    log_api_call("ImGui_RadioButton", ctx, label, active)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false
  end,
  
  ImGui_RadioButtonEx = function(ctx, label, v, v_button)
    log_api_call("ImGui_RadioButtonEx", ctx, label, v, v_button)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, v
  end,

  -- BeginChild/EndChild mocks for compatibility
  ImGui_BeginChild = function(ctx, str_id, width, height, border, flags)
    log_api_call("ImGui_BeginChild", ctx, str_id, width, height, border, flags)
    -- In the mock, we always succeed in creating the child window.
    -- We push a placeholder to the stack to track Begin/End calls.
    table.insert(ctx.window_stack, {name = str_id, type = "child"})
    return true
  end,
  ImGui_EndChild = function(ctx)
    log_api_call("ImGui_EndChild", ctx)
    if #ctx.window_stack > 0 then
      local child = ctx.window_stack[#ctx.window_stack]
      if child.type == "child" then
        table.remove(ctx.window_stack)
      else
        log_warning("Mismatched ImGui_EndChild() call: Top of stack is not a child window, but a '" .. (child.type or "window") .. "'.")
      end
    else
      log_warning("Mismatched ImGui_EndChild() call: No window on the stack.")
    end
  end,

  -- GetScrollY mock for compatibility
  ImGui_GetScrollY = function(ctx)
    log_api_call("ImGui_GetScrollY", ctx)
    return 0.0
  end,

  -- GetScrollMaxY mock for compatibility
  ImGui_GetScrollMaxY = function(ctx)
    log_api_call("ImGui_GetScrollMaxY", ctx)
    return 0.0
  end,

  -- SetScrollHereY mock for compatibility
  ImGui_SetScrollHereY = function(ctx, center_y_ratio)
    log_api_call("ImGui_SetScrollHereY", ctx, center_y_ratio)
  end,
  
  -- Combo and listbox
  ImGui_BeginCombo = function(ctx, label, preview_value, flags)
    log_api_call("ImGui_BeginCombo", ctx, label, preview_value, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false -- Never open in virtual mode
  end,
  
  ImGui_EndCombo = function(ctx)
    log_api_call("ImGui_EndCombo", ctx)
  end,
  
  ImGui_Combo = function(ctx, label, current_item, items, popup_max_height_in_items)
    log_api_call("ImGui_Combo", ctx, label, current_item, "...", popup_max_height_in_items)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, current_item
  end,
  
  ImGui_BeginListBox = function(ctx, label, size_w, size_h)
    log_api_call("ImGui_BeginListBox", ctx, label, size_w, size_h)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false
  end,
  
  ImGui_EndListBox = function(ctx)
    log_api_call("ImGui_EndListBox", ctx)
  end,
  
  ImGui_ListBox = function(ctx, label, current_item, items, height_in_items)
    log_api_call("ImGui_ListBox", ctx, label, current_item, "...", height_in_items)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, current_item
  end,
  
  ImGui_Selectable = function(ctx, label, selected, flags, size_w, size_h)
    log_api_call("ImGui_Selectable", ctx, label, selected, flags, size_w, size_h)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, selected
  end,
  -- Mock for ColorEdit3, supports both (ctx, label, {r,g,b}) and (ctx, label, r, g, b)
  ImGui_ColorEdit3 = function(ctx, label, ...)
    local args = {...}
    log_api_call("ImGui_ColorEdit3", ctx, label, table.unpack(args))
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    if type(args[1]) == 'table' then
      -- table form: return false, same table
      return false, args[1]
    else
      -- separate r,g,b args: return false, r,g,b
      return false, args[1], args[2], args[3]
    end
  end,
  
  -- Sliders and drags
  ImGui_SliderDouble = function(ctx, label, v, v_min, v_max, format, flags)
    log_api_call("ImGui_SliderDouble", ctx, label, v, v_min, v_max, format, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, v
  end,
  
  ImGui_SliderInt = function(ctx, label, v, v_min, v_max, format, flags)
    log_api_call("ImGui_SliderInt", ctx, label, v, v_min, v_max, format, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, v
  end,
  
  ImGui_DragDouble = function(ctx, label, v, v_speed, v_min, v_max, format, flags)
    log_api_call("ImGui_DragDouble", ctx, label, v, v_speed, v_min, v_max, format, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, v
  end,
  
  ImGui_DragInt = function(ctx, label, v, v_speed, v_min, v_max, format, flags)
    log_api_call("ImGui_DragInt", ctx, label, v, v_speed, v_min, v_max, format, flags)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
    return false, v
  end,
  
  -- ==================== LAYOUT AND SPACING ====================
  
  ImGui_Separator = function(ctx)
    log_api_call("ImGui_Separator", ctx)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
  end,
  
  ImGui_SeparatorText = function(ctx, text)
    log_api_call("ImGui_SeparatorText", ctx, text)
    VirtualState.stats.widgets_drawn = VirtualState.stats.widgets_drawn + 1
  end,
  
  ImGui_SameLine = function(ctx, offset_from_start_x, spacing)
    log_api_call("ImGui_SameLine", ctx, offset_from_start_x, spacing)
  end,
  
  ImGui_NewLine = function(ctx)
    log_api_call("ImGui_NewLine", ctx)
  end,
  
  ImGui_Spacing = function(ctx)
    log_api_call("ImGui_Spacing", ctx)
  end,
  
  ImGui_Dummy = function(ctx, size_w, size_h)
    log_api_call("ImGui_Dummy", ctx, size_w, size_h)
  end,
  
  ImGui_Indent = function(ctx, indent_w)
    log_api_call("ImGui_Indent", ctx, indent_w)
  end,
  
  ImGui_Unindent = function(ctx, indent_w)
    log_api_call("ImGui_Unindent", ctx, indent_w)
  end,
  
  ImGui_BeginGroup = function(ctx)
    log_api_call("ImGui_BeginGroup", ctx)
  end,
  
  ImGui_EndGroup = function(ctx)
    log_api_call("ImGui_EndGroup", ctx)
  end,
  
  -- ==================== STYLE MANAGEMENT ====================
  
  ImGui_StyleColorsDark = function(ctx)
    log_api_call("ImGui_StyleColorsDark", ctx)
    if ctx then
      -- Apply dark theme colors
      ctx.style_colors = {
        [0] = 0xF2F2F2FF, -- Text
        [1] = 0x1B1B1BFF, -- WindowBg
        [2] = 0x26BFBFFF, -- Button
        [3] = 0x3BD6D6FF, -- ButtonHovered
        [4] = 0x1FA8A8FF, -- ButtonActive
        [5] = 0x292929FF  -- FrameBg
      }
    end
  end,
  
  ImGui_PushStyleColor = function(ctx, idx, col)
    log_api_call("ImGui_PushStyleColor", ctx, idx, col)
    if ctx then
      table.insert(ctx.color_stack, {idx = idx, old_col = ctx.style_colors[idx]})
      ctx.style_colors[idx] = col
    end
  end,
  
  ImGui_PopStyleColor = function(ctx, count)
    count = count or 1
    log_api_call("ImGui_PopStyleColor", ctx, count)
    if ctx then
      for i = 1, count do
        local entry = table.remove(ctx.color_stack)
        if entry then
          ctx.style_colors[entry.idx] = entry.old_col
        end
      end
    end
  end,
  
  ImGui_PushStyleVar = function(ctx, idx, val, val2)
    log_api_call("ImGui_PushStyleVar", ctx, idx, val, val2)
    if ctx then
      table.insert(ctx.var_stack, {idx = idx, old_val = ctx.style_vars[idx]})
      ctx.style_vars[idx] = val2 and {val, val2} or val
    end
  end,
  
  ImGui_PopStyleVar = function(ctx, count)
    count = count or 1
    log_api_call("ImGui_PopStyleVar", ctx, count)
    if ctx then
      for i = 1, count do
        local entry = table.remove(ctx.var_stack)
        if entry then
          ctx.style_vars[entry.idx] = entry.old_val
        end
      end
    end
  end,
  
  -- ==================== FONT MANAGEMENT ====================
  
  ImGui_CreateFont = function(name, size, flags)
    local font = {
      id = #VirtualState.contexts > 0 and (#VirtualState.contexts[1].fonts + 1) or 1,
      name = name or "Default",
      size = size or 13,
      flags = flags or 0
    }
    log_api_call("ImGui_CreateFont", nil, name, size, flags)
    return font
  end,
  
  ImGui_Attach = function(ctx, font)
    log_api_call("ImGui_Attach", ctx, font and font.name)
    if ctx and font then
      table.insert(ctx.fonts, font)
    end
  end,
  
  ImGui_PushFont = function(ctx, font)
    log_api_call("ImGui_PushFont", ctx, font and font.name)
    if ctx and font then
      table.insert(ctx.font_stack, font)
    end
  end,
  
  ImGui_PopFont = function(ctx)
    log_api_call("ImGui_PopFont", ctx)
    if ctx then
      table.remove(ctx.font_stack)
    end
  end,
  
  -- ==================== TOOLTIPS ====================
  
  ImGui_BeginTooltip = function(ctx)
    log_api_call("ImGui_BeginTooltip", ctx)
    return true
  end,
  
  ImGui_EndTooltip = function(ctx)
    log_api_call("ImGui_EndTooltip", ctx)
  end,
  
  ImGui_SetTooltip = function(ctx, text)
    log_api_call("ImGui_SetTooltip", ctx, text)
  end,
  
  ImGui_SetItemTooltip = function(ctx, text)
    log_api_call("ImGui_SetItemTooltip", ctx, text)
  end,
  
  -- ==================== ITEM/WIDGET QUERY ====================
  
  ImGui_IsItemHovered = function(ctx, flags)
    log_api_call("ImGui_IsItemHovered", ctx, flags)
    return false -- Never hovered in virtual mode
  end,
  
  ImGui_IsItemActive = function(ctx)
    log_api_call("ImGui_IsItemActive", ctx)
    return false
  end,
  
  ImGui_IsItemFocused = function(ctx)
    log_api_call("ImGui_IsItemFocused", ctx)
    return false
  end,
  
  ImGui_IsItemClicked = function(ctx, mouse_button)
    log_api_call("ImGui_IsItemClicked", ctx, mouse_button)
    return false
  end,
  
  ImGui_IsItemVisible = function(ctx)
    log_api_call("ImGui_IsItemVisible", ctx)
    return true -- Always visible in virtual mode
  end,
  
  ImGui_IsItemEdited = function(ctx)
    log_api_call("ImGui_IsItemEdited", ctx)
    return false
  end,
  
  ImGui_IsItemActivated = function(ctx)
    log_api_call("ImGui_IsItemActivated", ctx)
    return false
  end,
  
  ImGui_IsItemDeactivated = function(ctx)
    log_api_call("ImGui_IsItemDeactivated", ctx)
    return false
  end,
  
  ImGui_IsItemDeactivatedAfterEdit = function(ctx)
    log_api_call("ImGui_IsItemDeactivatedAfterEdit", ctx)
    return false
  end,
  
  -- ==================== CONSTANTS AS FUNCTIONS ====================
  
  -- Window flags
  ImGui_WindowFlags_None = function() return 0 end,
  ImGui_WindowFlags_NoTitleBar = function() return 1 end,
  ImGui_WindowFlags_NoResize = function() return 2 end,
  ImGui_WindowFlags_NoMove = function() return 4 end,
  ImGui_WindowFlags_NoScrollbar = function() return 8 end,
  ImGui_WindowFlags_NoScrollWithMouse = function() return 16 end,
  ImGui_WindowFlags_NoCollapse = function() return 32 end,
  ImGui_WindowFlags_AlwaysAutoResize = function() return 64 end,
  ImGui_WindowFlags_NoBackground = function() return 128 end,
  ImGui_WindowFlags_NoSavedSettings = function() return 256 end,
  ImGui_WindowFlags_NoMouseInputs = function() return 512 end,
  ImGui_WindowFlags_MenuBar = function() return 1024 end,
  ImGui_WindowFlags_HorizontalScrollbar = function() return 2048 end,
  ImGui_WindowFlags_NoFocusOnAppearing = function() return 4096 end,
  ImGui_WindowFlags_NoBringToFrontOnFocus = function() return 8192 end,
  ImGui_WindowFlags_AlwaysVerticalScrollbar = function() return 16384 end,
  ImGui_WindowFlags_AlwaysHorizontalScrollbar = function() return 32768 end,
  ImGui_WindowFlags_AlwaysUseWindowPadding = function() return 65536 end,
  
  -- Color constants
  ImGui_Col_Text = function() return 0 end,
  ImGui_Col_TextDisabled = function() return 1 end,
  ImGui_Col_WindowBg = function() return 2 end,
  ImGui_Col_ChildBg = function() return 3 end,
  ImGui_Col_PopupBg = function() return 4 end,
  ImGui_Col_Border = function() return 5 end,
  ImGui_Col_BorderShadow = function() return 6 end,
  ImGui_Col_FrameBg = function() return 7 end,
  ImGui_Col_FrameBgHovered = function() return 8 end,
  ImGui_Col_FrameBgActive = function() return 9 end,
  ImGui_Col_TitleBg = function() return 10 end,
  ImGui_Col_TitleBgActive = function() return 11 end,
  ImGui_Col_TitleBgCollapsed = function() return 12 end,
  ImGui_Col_MenuBarBg = function() return 13 end,
  ImGui_Col_ScrollbarBg = function() return 14 end,
  ImGui_Col_ScrollbarGrab = function() return 15 end,
  ImGui_Col_ScrollbarGrabHovered = function() return 16 end,
  ImGui_Col_ScrollbarGrabActive = function() return 17 end,
  ImGui_Col_CheckMark = function() return 18 end,
  ImGui_Col_SliderGrab = function() return 19 end,
  ImGui_Col_SliderGrabActive = function() return 20 end,
  ImGui_Col_Button = function() return 21 end,
  ImGui_Col_ButtonHovered = function() return 22 end,
  ImGui_Col_ButtonActive = function() return 23 end,
  ImGui_Col_Header = function() return 24 end,
  ImGui_Col_HeaderHovered = function() return 25 end,
  ImGui_Col_HeaderActive = function() return 26 end,
  
  -- Style var constants
  ImGui_StyleVar_Alpha = function() return 0 end,
  ImGui_StyleVar_WindowPadding = function() return 1 end,
  ImGui_StyleVar_WindowRounding = function() return 2 end,
  ImGui_StyleVar_WindowBorderSize = function() return 3 end,
  ImGui_StyleVar_WindowMinSize = function() return 4 end,
  ImGui_StyleVar_WindowTitleAlign = function() return 5 end,
  ImGui_StyleVar_ChildRounding = function() return 6 end,
  ImGui_StyleVar_ChildBorderSize = function() return 7 end,
  ImGui_StyleVar_PopupRounding = function() return 8 end,
  ImGui_StyleVar_PopupBorderSize = function() return 9 end,
  ImGui_StyleVar_FramePadding = function() return 10 end,
  ImGui_StyleVar_FrameRounding = function() return 11 end,
  ImGui_StyleVar_FrameBorderSize = function() return 12 end,
  ImGui_StyleVar_ItemSpacing = function() return 13 end,
  ImGui_StyleVar_ItemInnerSpacing = function() return 14 end,
  ImGui_StyleVar_IndentSpacing = function() return 15 end,
  ImGui_StyleVar_ScrollbarSize = function() return 16 end,
  ImGui_StyleVar_ScrollbarRounding = function() return 17 end,
  ImGui_StyleVar_GrabMinSize = function() return 18 end,
  ImGui_StyleVar_GrabRounding = function() return 19 end,
  ImGui_StyleVar_TabRounding = function() return 20 end,
  
  -- Tab bar flags
  ImGui_TabBarFlags_None = function() return 0 end,
  ImGui_TabBarFlags_Reorderable = function() return 1 end,
  ImGui_TabBarFlags_AutoSelectNewTabs = function() return 2 end,
  ImGui_TabBarFlags_TabListPopupButton = function() return 4 end,
  ImGui_TabBarFlags_NoCloseWithMiddleMouseButton = function() return 8 end,
  ImGui_TabBarFlags_NoTabListScrollingButtons = function() return 16 end,
  ImGui_TabBarFlags_NoTooltip = function() return 32 end,
  ImGui_TabBarFlags_FittingPolicyResizeDown = function() return 64 end,
  ImGui_TabBarFlags_FittingPolicyScroll = function() return 128 end,
  
  -- Tab item flags
  ImGui_TabItemFlags_None = function() return 0 end,
  ImGui_TabItemFlags_UnsavedDocument = function() return 1 end,
  ImGui_TabItemFlags_SetSelected = function() return 2 end,
  ImGui_TabItemFlags_NoCloseWithMiddleMouseButton = function() return 4 end,
  ImGui_TabItemFlags_NoPushId = function() return 8 end,
  ImGui_TabItemFlags_NoTooltip = function() return 16 end,
  ImGui_TabItemFlags_NoReorder = function() return 32 end,
  ImGui_TabItemFlags_Leading = function() return 64 end,
  ImGui_TabItemFlags_Trailing = function() return 128 end
}

-- ==================== VIRTUAL TESTING FRAMEWORK ====================

function EnhancedVirtualReaper.create_environment()
  -- Initialize global reaper table
  _G.reaper = mock_reaper
  
  -- Setup virtual environment
  VirtualState.time = os.time()
  VirtualState.frame_count = 0
  
  print("🚀 Enhanced Virtual REAPER Environment Initialized")
  print("📊 Features: Comprehensive ImGui API, State Management, Performance Tracking")
  print("🎯 Ready for script testing and validation")
  print("----------------------------------------")
  
  return mock_reaper
end

function EnhancedVirtualReaper.run_test_script(script_path)
  print("🧪 Running test script: " .. script_path)
  print("----------------------------------------")
  
  -- Create environment
  EnhancedVirtualReaper.create_environment()
  
  -- Load and run script
  local success, result = pcall(dofile, script_path)
  
  if success then
    print("✅ Script executed successfully")
    if result then
      print("📋 Script result: " .. tostring(result))
    end
  else
    print("❌ Script execution failed: " .. tostring(result))
    VirtualState.stats.errors = VirtualState.stats.errors + 1
  end
  
  -- Print statistics
  EnhancedVirtualReaper.print_statistics()
  
  return success, result
end

function EnhancedVirtualReaper.validate_ui_structure(script_path)
  print("🔍 Validating UI structure for: " .. script_path)
  print("----------------------------------------")
  
  local original_begin = mock_reaper.ImGui_Begin
  local original_end = mock_reaper.ImGui_End
  local begin_count = 0
  local end_count = 0
  
  -- Hook Begin/End calls
  mock_reaper.ImGui_Begin = function(...)
    begin_count = begin_count + 1
    return original_begin(...)
  end
  
  mock_reaper.ImGui_End = function(...)
    end_count = end_count + 1
    return original_end(...)
  end
  
  -- Run script
  local success, result = EnhancedVirtualReaper.run_test_script(script_path)
  
  -- Restore original functions
  mock_reaper.ImGui_Begin = original_begin
  mock_reaper.ImGui_End = original_end
  
  -- Validate stack balance
  if begin_count == end_count then
    print("✅ UI stack is balanced: " .. begin_count .. " Begin/End pairs")
  else
    print("⚠️  UI stack imbalance: " .. begin_count .. " Begin calls, " .. end_count .. " End calls")
    VirtualState.stats.warnings = VirtualState.stats.warnings + 1
  end
  
  return success and (begin_count == end_count)
end

function EnhancedVirtualReaper.print_statistics()
  local runtime = os.time() - VirtualState.stats.start_time
  print("----------------------------------------")
  print("📈 Enhanced Virtual REAPER Statistics:")
  print("   Runtime: " .. runtime .. " seconds")
  print("   API calls: " .. VirtualState.stats.api_calls)
  print("   Windows created: " .. VirtualState.stats.windows_created)
  print("   Widgets drawn: " .. VirtualState.stats.widgets_drawn)
  print("   Errors: " .. VirtualState.stats.errors)
  print("   Warnings: " .. VirtualState.stats.warnings)
  print("   Memory: " .. collectgarbage("count") .. " KB")
  print("----------------------------------------")
end

function EnhancedVirtualReaper.set_verbose_logging(enabled)
  VirtualState.verbose_logging = enabled
  print("🔊 Verbose logging " .. (enabled and "enabled" or "disabled"))
end

function EnhancedVirtualReaper.reset_statistics()
  VirtualState.stats = {
    windows_created = 0,
    widgets_drawn = 0,
    api_calls = 0,
    errors = 0,
    warnings = 0,
    start_time = os.time()
  }
  print("📊 Statistics reset")
end

-- ==================== COMMAND LINE INTERFACE ====================

if arg and arg[0] then
  -- Running as standalone script
  if arg[1] == "--test" and arg[2] then
    EnhancedVirtualReaper.run_test_script(arg[2])
  elseif arg[1] == "--validate" and arg[2] then
    EnhancedVirtualReaper.validate_ui_structure(arg[2])
  elseif arg[1] == "--help" then
    print("Enhanced Virtual REAPER Environment")
    print("Usage:")
    print("  lua enhanced_virtual_reaper.lua --test <script.lua>      Run script in virtual environment")
    print("  lua enhanced_virtual_reaper.lua --validate <script.lua> Validate UI structure")
    print("  lua enhanced_virtual_reaper.lua --help                  Show this help")
  else
    -- Create environment for interactive use
    EnhancedVirtualReaper.create_environment()
  end
end

return EnhancedVirtualReaper


-- Auto-generated mock stubs from harden_envi_mocks.lua --
reaper.ImGui_SetCursorPosY = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetCursorPosY...
')
end

reaper.ImGui_AcceptDragDropPayloadFiles = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_AcceptDragDropPayloadFiles...
')
  return false
end

reaper.ImGui_DragIntRange2 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_DragIntRange2...
')
  return false
end

reaper.ImGui_Text = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_Text...
')
end

reaper.ImGui_BeginTabItem = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_BeginTabItem...
')
  return false
end

reaper.ImGui_BeginPopupModal = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_BeginPopupModal...
')
  return false
end

reaper.ImGui_DragInt = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_DragInt...
')
  return false
end

reaper.ImGui_GetDragDropPayloadFile = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetDragDropPayloadFile...
')
  return false
end

reaper.ImGui_LogToFile = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_LogToFile...
')
end

reaper.ImGui_SetTooltip = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetTooltip...
')
end

reaper.ImGui_GetScrollMaxY = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetScrollMaxY...
')
  return 0
end

reaper.ImGui_IsRectVisibleEx = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsRectVisibleEx...
')
  return false
end

reaper.ImGui_PopButtonRepeat = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_PopButtonRepeat...
')
end

reaper.ImGui_BeginDragDropSource = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_BeginDragDropSource...
')
  return false
end

reaper.ImGui_Unindent = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_Unindent...
')
end

reaper.ImGui_EndTabBar = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_EndTabBar...
')
end

reaper.ImGui_InputInt2 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_InputInt2...
')
  return false
end

reaper.ImGui_InputDouble3 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_InputDouble3...
')
  return false
end

reaper.ImGui_GetWindowPos = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetWindowPos...
')
end

reaper.ImGui_Spacing = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_Spacing...
')
end

reaper.ImGui_TextDisabled = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_TextDisabled...
')
end

reaper.ImGui_ShowMetricsWindow = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_ShowMetricsWindow...
')
end

reaper.ImGui_IsWindowAppearing = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsWindowAppearing...
')
  return false
end

reaper.ImGui_GetWindowSize = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetWindowSize...
')
end

reaper.ImGui_TableGetColumnName = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_TableGetColumnName...
')
  return ''
end

reaper.ImGui_SliderInt3 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SliderInt3...
')
  return false
end

reaper.ImGui_GetWindowContentRegionMin = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetWindowContentRegionMin...
')
end

reaper.ImGui_SetScrollHereY = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetScrollHereY...
')
end

reaper.ImGui_SetScrollHereX = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetScrollHereX...
')
end

reaper.ImGui_SmallButton = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SmallButton...
')
  return false
end

reaper.ImGui_SetScrollY = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetScrollY...
')
end

reaper.ImGui_GetMouseDelta = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetMouseDelta...
')
end

reaper.ImGui_DragDoubleN = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_DragDoubleN...
')
  return false
end

reaper.ImGui_InputDoubleN = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_InputDoubleN...
')
  return false
end

reaper.ImGui_SetNextWindowScroll = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetNextWindowScroll...
')
end

reaper.ImGui_GetDragDropPayload = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetDragDropPayload...
')
  return false
end

reaper.ImGui_EndTabItem = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_EndTabItem...
')
end

reaper.ImGui_GetScrollY = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetScrollY...
')
  return 0
end

reaper.ImGui_GetScrollX = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetScrollX...
')
  return 0
end

reaper.ImGui_Button = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_Button...
')
  return false
end

reaper.ImGui_BeginPopup = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_BeginPopup...
')
  return false
end

reaper.ImGui_ColorPicker3 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_ColorPicker3...
')
  return false
end

reaper.ImGui_EndMenuBar = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_EndMenuBar...
')
end

reaper.ImGui_SetNextWindowContentSize = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetNextWindowContentSize...
')
end

reaper.ImGui_GetWindowContentRegionMax = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetWindowContentRegionMax...
')
end

reaper.ImGui_GetContentRegionMax = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetContentRegionMax...
')
end

reaper.ImGui_GetFrameHeightWithSpacing = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetFrameHeightWithSpacing...
')
  return 0
end

reaper.ImGui_GetColorEx = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetColorEx...
')
  return 0
end

reaper.ImGui_GetMouseDragDelta = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetMouseDragDelta...
')
end

reaper.ImGui_SetNextWindowBgAlpha = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetNextWindowBgAlpha...
')
end

reaper.ImGui_SliderDouble = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SliderDouble...
')
  return false
end

reaper.ImGui_IsMouseHoveringRect = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsMouseHoveringRect...
')
  return false
end

reaper.ImGui_DragInt2 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_DragInt2...
')
  return false
end

reaper.ImGui_IsItemDeactivated = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsItemDeactivated...
')
  return false
end

reaper.ImGui_GetMousePos = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetMousePos...
')
end

reaper.ImGui_SetNextWindowFocus = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetNextWindowFocus...
')
end

reaper.ImGui_SetNextWindowCollapsed = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetNextWindowCollapsed...
')
end

reaper.ImGui_SetNextWindowSize = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetNextWindowSize...
')
end

reaper.ImGui_IsMouseReleased = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsMouseReleased...
')
  return false
end

reaper.ImGui_SetKeyboardFocusHere = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetKeyboardFocusHere...
')
end

reaper.ImGui_SetNextWindowPos = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetNextWindowPos...
')
end

reaper.ImGui_BeginMenuBar = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_BeginMenuBar...
')
  return false
end

reaper.ImGui_SetScrollFromPosY = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetScrollFromPosY...
')
end

reaper.ImGui_GetFrameHeight = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetFrameHeight...
')
  return 0
end

reaper.ImGui_SliderInt = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SliderInt...
')
  return false
end

reaper.ImGui_PushButtonRepeat = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_PushButtonRepeat...
')
end

reaper.ImGui_GetMainViewport = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetMainViewport...
')
end

reaper.ImGui_IsRectVisible = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsRectVisible...
')
  return false
end

reaper.ImGui_OpenPopup = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_OpenPopup...
')
end

reaper.ImGui_SetClipboardText = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetClipboardText...
')
end

reaper.ImGui_BeginListBox = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_BeginListBox...
')
  return false
end

reaper.ImGui_GetTime = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetTime...
')
  return 0
end

reaper.ImGui_GetItemRectMax = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetItemRectMax...
')
end

reaper.ImGui_PopStyleColor = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_PopStyleColor...
')
end

reaper.ImGui_BeginCombo = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_BeginCombo...
')
  return false
end

reaper.ImGui_GetItemRectSize = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetItemRectSize...
')
end

reaper.ImGui_DragDouble2 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_DragDouble2...
')
  return false
end

reaper.ImGui_GetMouseCursor = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetMouseCursor...
')
  return 0
end

reaper.ImGui_LogText = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_LogText...
')
end

reaper.ImGui_DragInt3 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_DragInt3...
')
  return false
end

reaper.ImGui_LogFinish = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_LogFinish...
')
end

reaper.ImGui_IsMouseClicked = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsMouseClicked...
')
  return false
end

reaper.ImGui_SetNextItemWidth = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetNextItemWidth...
')
end

reaper.ImGui_Checkbox = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_Checkbox...
')
  return false
end

reaper.ImGui_GetInputQueueCharacter = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetInputQueueCharacter...
')
  return false
end

reaper.ImGui_PopID = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_PopID...
')
end

reaper.ImGui_CollapsingHeader = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_CollapsingHeader...
')
  return false
end

reaper.ImGui_PushID = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_PushID...
')
end

reaper.ImGui_ProgressBar = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_ProgressBar...
')
end

reaper.ImGui_IsItemActivated = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsItemActivated...
')
  return false
end

reaper.ImGui_CloseCurrentPopup = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_CloseCurrentPopup...
')
end

reaper.ImGui_IsItemVisible = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsItemVisible...
')
  return false
end

reaper.ImGui_IsItemToggledOpen = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsItemToggledOpen...
')
  return false
end

reaper.ImGui_SetNextItemOpen = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetNextItemOpen...
')
end

reaper.ImGui_GetForegroundDrawList = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetForegroundDrawList...
')
end

reaper.ImGui_GetMouseClickedPos = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetMouseClickedPos...
')
end

reaper.ImGui_GetTreeNodeToLabelSpacing = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetTreeNodeToLabelSpacing...
')
  return 0
end

reaper.ImGui_TreePop = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_TreePop...
')
end

reaper.ImGui_AcceptDragDropPayload = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_AcceptDragDropPayload...
')
  return false
end

reaper.ImGui_ColorEdit3 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_ColorEdit3...
')
  return false
end

reaper.ImGui_ArrowButton = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_ArrowButton...
')
  return false
end

reaper.ImGui_TreeNodeEx = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_TreeNodeEx...
')
  return false
end

reaper.ImGui_SetMouseCursor = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetMouseCursor...
')
end

reaper.ImGui_GetClipboardText = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetClipboardText...
')
  return ''
end

reaper.ImGui_ResetMouseDragDelta = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_ResetMouseDragDelta...
')
end

reaper.ImGui_IsWindowFocused = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsWindowFocused...
')
  return false
end

reaper.ImGui_GetTextLineHeightWithSpacing = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetTextLineHeightWithSpacing...
')
  return 0
end

reaper.ImGui_ColorEdit4 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_ColorEdit4...
')
  return false
end

reaper.ImGui_DragFloatRange2 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_DragFloatRange2...
')
  return false
end

reaper.ImGui_ColorButton = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_ColorButton...
')
  return false
end

reaper.ImGui_SetDragDropPayload = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetDragDropPayload...
')
  return false
end

reaper.ImGui_DragDouble = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_DragDouble...
')
  return false
end

reaper.ImGui_ColorPicker4 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_ColorPicker4...
')
  return false
end

reaper.ImGui_PopTextWrapPos = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_PopTextWrapPos...
')
end

reaper.ImGui_PushTextWrapPos = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_PushTextWrapPos...
')
end

reaper.ImGui_SetCursorScreenPos = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetCursorScreenPos...
')
end

reaper.ImGui_BulletText = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_BulletText...
')
end

reaper.ImGui_SetColorEditOptions = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetColorEditOptions...
')
end

reaper.ImGui_Bullet = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_Bullet...
')
end

reaper.ImGui_SliderDouble3 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SliderDouble3...
')
  return false
end

reaper.ImGui_SliderDouble4 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SliderDouble4...
')
  return false
end

reaper.ImGui_IsAnyItemHovered = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsAnyItemHovered...
')
  return false
end

reaper.ImGui_BeginTabBar = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_BeginTabBar...
')
  return false
end

reaper.ImGui_SliderInt2 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SliderInt2...
')
  return false
end

reaper.ImGui_TextColored = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_TextColored...
')
end

reaper.ImGui_PushItemWidth = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_PushItemWidth...
')
end

reaper.ImGui_TableSetBgColor = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_TableSetBgColor...
')
end

reaper.ImGui_BeginTooltip = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_BeginTooltip...
')
  return false
end

reaper.ImGui_GetStyleVar = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetStyleVar...
')
end

reaper.ImGui_CheckboxFlags = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_CheckboxFlags...
')
  return false
end

reaper.ImGui_TableGetRowIndex = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_TableGetRowIndex...
')
  return 0
end

reaper.ImGui_SliderDouble2 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SliderDouble2...
')
  return false
end

reaper.ImGui_SetCursorPos = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetCursorPos...
')
end

reaper.ImGui_NewLine = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_NewLine...
')
end

reaper.ImGui_GetMouseWheel = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetMouseWheel...
')
end

reaper.ImGui_EndDragDropSource = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_EndDragDropSource...
')
end

reaper.ImGui_TableAngledHeadersRow = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_TableAngledHeadersRow...
')
end

reaper.ImGui_BeginPopupContextWindow = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_BeginPopupContextWindow...
')
  return false
end

reaper.ImGui_CalcItemWidth = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_CalcItemWidth...
')
  return 0
end

reaper.ImGui_TableSetupColumn = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_TableSetupColumn...
')
end

reaper.ImGui_TableSetupScrollFreeze = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_TableSetupScrollFreeze...
')
end

reaper.ImGui_TableHeader = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_TableHeader...
')
end

reaper.ImGui_AcceptDragDropPayloadRGB = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_AcceptDragDropPayloadRGB...
')
  return false
end

reaper.ImGui_TableHeadersRow = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_TableHeadersRow...
')
end

reaper.ImGui_IsItemEdited = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsItemEdited...
')
  return false
end

reaper.ImGui_BeginDragDropTarget = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_BeginDragDropTarget...
')
  return false
end

reaper.ImGui_TableNeedSort = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_TableNeedSort...
')
  return false
end

reaper.ImGui_InputInt3 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_InputInt3...
')
  return false
end

reaper.ImGui_GetCursorStartPos = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetCursorStartPos...
')
end

reaper.ImGui_TableGetColumnFlags = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_TableGetColumnFlags...
')
  return 0
end

reaper.ImGui_GetBackgroundDrawList = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetBackgroundDrawList...
')
end

reaper.ImGui_SetTabItemClosed = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetTabItemClosed...
')
end

reaper.ImGui_TreeNode = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_TreeNode...
')
  return false
end

reaper.ImGui_SetScrollX = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetScrollX...
')
end

reaper.ImGui_Selectable = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_Selectable...
')
  return false
end

reaper.ImGui_LabelText = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_LabelText...
')
end

reaper.ImGui_IsMouseDoubleClicked = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsMouseDoubleClicked...
')
  return false
end

reaper.ImGui_CalcTextSize = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_CalcTextSize...
')
end

reaper.ImGui_DragInt4 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_DragInt4...
')
  return false
end

reaper.ImGui_PushStyleColor = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_PushStyleColor...
')
end

reaper.ImGui_GetStyleColor = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetStyleColor...
')
  return 0
end

reaper.ImGui_InvisibleButton = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_InvisibleButton...
')
  return false
end

reaper.ImGui_GetColor = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetColor...
')
  return 0
end

reaper.ImGui_IsMouseDragging = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsMouseDragging...
')
  return false
end

reaper.ImGui_PopStyleVar = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_PopStyleVar...
')
end

reaper.ImGui_GetMouseDownDuration = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetMouseDownDuration...
')
  return 0
end

reaper.ImGui_PushStyleVar = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_PushStyleVar...
')
end

reaper.ImGui_VSliderDouble = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_VSliderDouble...
')
  return false
end

reaper.ImGui_OpenPopupOnItemClick = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_OpenPopupOnItemClick...
')
end

reaper.ImGui_VSliderInt = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_VSliderInt...
')
  return false
end

reaper.ImGui_Separator = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_Separator...
')
end

reaper.ImGui_BeginGroup = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_BeginGroup...
')
end

reaper.ImGui_AlignTextToFramePadding = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_AlignTextToFramePadding...
')
end

reaper.ImGui_SliderDoubleN = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SliderDoubleN...
')
  return false
end

reaper.ImGui_TableGetColumnCount = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_TableGetColumnCount...
')
  return 0
end

reaper.ImGui_GetScrollMaxX = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetScrollMaxX...
')
  return 0
end

reaper.ImGui_IsMousePosValid = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsMousePosValid...
')
  return false
end

reaper.ImGui_EndListBox = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_EndListBox...
')
end

reaper.ImGui_SetScrollFromPosX = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetScrollFromPosX...
')
end

reaper.ImGui_TextWrapped = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_TextWrapped...
')
end

reaper.ImGui_DragDouble4 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_DragDouble4...
')
  return false
end

reaper.ImGui_LogToTTY = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_LogToTTY...
')
end

reaper.ImGui_SliderAngle = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SliderAngle...
')
  return false
end

reaper.ImGui_PopItemWidth = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_PopItemWidth...
')
end

reaper.ImGui_IsPopupOpen = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsPopupOpen...
')
  return false
end

reaper.ImGui_GetTextLineHeight = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetTextLineHeight...
')
  return 0
end

reaper.ImGui_PlotHistogram = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_PlotHistogram...
')
end

reaper.ImGui_RadioButton = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_RadioButton...
')
  return false
end

reaper.ImGui_SameLine = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SameLine...
')
end

reaper.ImGui_PlotLines = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_PlotLines...
')
end

reaper.ImGui_PopClipRect = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_PopClipRect...
')
end

reaper.ImGui_GetCursorPosX = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetCursorPosX...
')
  return 0
end

reaper.ImGui_GetDeltaTime = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetDeltaTime...
')
  return 0
end

reaper.ImGui_GetItemRectMin = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetItemRectMin...
')
end

reaper.ImGui_BeginPopupContextItem = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_BeginPopupContextItem...
')
  return false
end

reaper.ImGui_EndMenu = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_EndMenu...
')
end

reaper.ImGui_IsItemClicked = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsItemClicked...
')
  return false
end

reaper.ImGui_GetContentRegionAvail = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetContentRegionAvail...
')
end

reaper.ImGui_IsAnyItemActive = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsAnyItemActive...
')
  return false
end

reaper.ImGui_InputInt4 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_InputInt4...
')
  return false
end

reaper.ImGui_GetCursorScreenPos = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetCursorScreenPos...
')
end

reaper.ImGui_IsMouseDown = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsMouseDown...
')
  return false
end

reaper.ImGui_DragDouble3 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_DragDouble3...
')
  return false
end

reaper.ImGui_GetFrameCount = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetFrameCount...
')
  return 0
end

reaper.ImGui_SetCursorPosX = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetCursorPosX...
')
end

reaper.ImGui_InputDouble4 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_InputDouble4...
')
  return false
end

reaper.ImGui_EndDragDropTarget = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_EndDragDropTarget...
')
end

reaper.ImGui_TreePush = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_TreePush...
')
end

reaper.ImGui_IsAnyItemFocused = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsAnyItemFocused...
')
  return false
end

reaper.ImGui_Dummy = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_Dummy...
')
end

reaper.ImGui_AcceptDragDropPayloadRGBA = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_AcceptDragDropPayloadRGBA...
')
  return false
end

reaper.ImGui_RadioButtonEx = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_RadioButtonEx...
')
  return false
end

reaper.ImGui_SliderInt4 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SliderInt4...
')
  return false
end

reaper.ImGui_InputDouble2 = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_InputDouble2...
')
  return false
end

reaper.ImGui_TabItemButton = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_TabItemButton...
')
  return false
end

reaper.ImGui_IsItemDeactivatedAfterEdit = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsItemDeactivatedAfterEdit...
')
  return false
end

reaper.ImGui_EndCombo = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_EndCombo...
')
end

reaper.ImGui_PushClipRect = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_PushClipRect...
')
end

reaper.ImGui_GetFontSize = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetFontSize...
')
  return 0
end

reaper.ImGui_GetCursorPosY = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetCursorPosY...
')
  return 0
end

reaper.ImGui_SetItemDefaultFocus = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_SetItemDefaultFocus...
')
end

reaper.ImGui_GetCursorPos = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetCursorPos...
')
end

reaper.ImGui_Indent = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_Indent...
')
end

reaper.ImGui_InputDouble = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_InputDouble...
')
  return false
end

reaper.ImGui_InputInt = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_InputInt...
')
  return false
end

reaper.ImGui_BeginMenu = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_BeginMenu...
')
  return false
end

reaper.ImGui_IsAnyMouseDown = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsAnyMouseDown...
')
  return false
end

reaper.ImGui_TableGetColumnIndex = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_TableGetColumnIndex...
')
  return 0
end

reaper.ImGui_GetMousePosOnOpeningCurrentPopup = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetMousePosOnOpeningCurrentPopup...
')
end

reaper.ImGui_IsItemFocused = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_IsItemFocused...
')
  return false
end

reaper.ImGui_GetWindowDrawList = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_GetWindowDrawList...
')
end

reaper.ImGui_MenuItem = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_MenuItem...
')
  return false
end

reaper.ImGui_LogToClipboard = function()
  reaper.ShowConsoleMsg('[MOCK] Called ImGui_LogToClipboard...
')
end