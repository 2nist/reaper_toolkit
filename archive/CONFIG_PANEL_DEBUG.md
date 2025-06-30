# ImGui Color Stack Issue - Config Panel Debug

## Problem
User reports ImGui assertion failure when accessing config panel:
```
/Users/Matthew/devtoolbox-reaper-master/main.lua:198: ImGui_EndChild: ImGui assertion failed: SizeOfColorStack >= g.ColorStack.Size && "PushStyleColor/PopStyleColor Mismatch!"
```

## Analysis

### Error Location
- **File**: `main.lua`, **Line 198**: `ImGui.EndChild(ctx)` 
- **Context**: This is the end of the content area child window where panels are drawn
- **Panel**: Config panel (`config_panel.lua`)

### Root Cause Investigation

1. **Main Window Color Stack**: Already fixed with 5 colors properly balanced
2. **Config Panel Color Stack**: Uses `theme_manager.apply_theme()` which pushes 5 colors
3. **Cleanup**: Uses `theme_manager.cleanup_theme()` to pop the same 5 colors

### Potential Issues
1. **Nested Windows**: Config panel runs inside a child window, colors might affect parent stack
2. **Error Interruption**: If an error occurs in config panel, cleanup might be skipped
3. **Font Manager Integration**: Font preview using `font_manager.use_font()` (uses font stack, not color stack)

## Debug Approach

### Step 1: Added Debug Logging
- Config panel logs color push/pop counts
- Theme manager logs cleanup operations
- This will show if cleanup is being called and with correct counts

### Step 2: Temporary Theme Disable
- Disabled theme application in config panel to isolate the issue
- If this fixes the problem, the issue is in theme application within child windows

## Code Changes

### Config Panel Debug
```lua
-- BEFORE:
if theme_manager and colors_pushed > 0 then
    theme_manager.cleanup_theme(ctx, ImGui, colors_pushed)
end

-- AFTER (with logging):
if theme_manager and colors_pushed > 0 then
    print("Config panel: Cleaning up", colors_pushed, "style colors")
    theme_manager.cleanup_theme(ctx, ImGui, colors_pushed)
    print("Config panel: Theme cleanup completed")
else
    print("Config panel: No theme cleanup needed, colors_pushed =", colors_pushed)
end
```

### Theme Manager Debug
```lua
-- BEFORE:
function M.cleanup_theme(ctx, ImGui, colors_pushed)
    if ctx and ImGui and colors_pushed > 0 then
        ImGui.PopStyleColor(ctx, colors_pushed)
    end
end

-- AFTER (with logging):
function M.cleanup_theme(ctx, ImGui, colors_pushed)
    if ctx and ImGui and colors_pushed > 0 then
        print("Theme manager: Popping", colors_pushed, "style colors")
        ImGui.PopStyleColor(ctx, colors_pushed)
        print("Theme manager: PopStyleColor completed")
    else
        print("Theme manager: No cleanup needed, colors_pushed =", colors_pushed)
    end
end
```

### Temporary Theme Disable
```lua
-- TEMPORARILY DISABLED FOR DEBUGGING:
local colors_pushed = 0
-- if theme_manager then
--     colors_pushed = theme_manager.apply_theme(ctx, ImGui)
-- end
```

## Expected Results

### If Theme Disable Fixes It
- Problem is theme application in child window context
- Need to modify theme_manager to detect child window context
- Possible solutions:
  1. Don't apply themes in child windows
  2. Use different approach for child window theming
  3. Apply themes at higher level only

### If Theme Disable Doesn't Fix It
- Look for other color stack manipulations in config panel
- Check font manager for hidden color operations
- Investigate ImGui child window behavior

## Next Steps

1. **Test with theme disabled** - does config panel work without assertion?
2. **Check debug logs** - what do the print statements reveal?
3. **Implement proper fix** based on findings:
   - Child window theme handling
   - Error-safe cleanup wrapper
   - Alternative theming approach

## Status: 🔍 DEBUGGING IN PROGRESS

The config panel theme application has been temporarily disabled to isolate the color stack issue. Debug logging added to track color push/pop operations.

**Ready for testing in REAPER environment to see debug output and verify fix.**
