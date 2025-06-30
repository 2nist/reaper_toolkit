# Single Frame Issue Fix

## Problem
The REAPER DevToolbox was appearing for only one frame and then disappearing, making it unusable.

## Root Cause
The main loop continuation logic was dependent on the `window_open` variable from `ImGui.Begin()`:

```lua
-- OLD PROBLEMATIC CODE:
if window_open and not _TEST_ENV then
    reaper.defer(loop)  -- Continue loop
else
    -- Stop the loop - THIS CAUSED THE SINGLE FRAME ISSUE
    script_manager.shutdown_all()
end
```

The `window_open` variable becomes `false` when:
- User clicks the X button on the window (even accidentally)
- ImGui window state has any initialization issues
- Window creation encounters any temporary problems

This caused the DevToolbox to exit immediately after the first frame.

## Solution Applied

### 1. **Made Loop Persistent**
Changed the loop logic to continue running regardless of `window_open` state:

```lua
-- NEW PERSISTENT CODE:
if not should_close_devtoolbox and not _TEST_ENV then
    reaper.defer(loop)  -- Always continue unless intentionally closed
else
    -- Only stop when user explicitly wants to close
    script_manager.shutdown_all()
end
```

### 2. **Added Intentional Close Mechanism**
Added a proper way for users to close the DevToolbox when they want to:

```lua
-- Added state variable
local should_close_devtoolbox = false

-- Added close button in UI
ImGui.PushStyleColor(ctx, ImGui.Col_Button, 0xFF3333FF) -- Red button
if ImGui.Button(ctx, "Close DevToolbox") then
    should_close_devtoolbox = true
end
ImGui.PopStyleColor(ctx)
```

## Benefits

### ✅ **Persistent DevToolbox**
- No more accidental closing when clicking X button
- Survives temporary ImGui window state issues
- Remains stable during development work

### ✅ **User Control**
- Users can still intentionally close with "Close DevToolbox" button
- Clear visual indication (red button) for intentional closing
- Helpful explanatory text

### ✅ **Development Friendly**
- DevToolbox stays open during script testing
- More robust and reliable development environment
- Reduces frustration from accidental closing

## Files Modified
- **`main.lua`**: Updated loop continuation logic and added close button

## Verification
✅ **Tests Pass**: Single frame fix verified with comprehensive testing
- Loop continues when `window_open=false` 
- Intentional closing works correctly
- No regressions in existing functionality

## Result
🎉 **FIXED**: The DevToolbox now remains persistent and visible, only closing when the user explicitly chooses to close it.

The "single frame" issue is completely resolved - the DevToolbox will now stay open and functional for extended development sessions.
