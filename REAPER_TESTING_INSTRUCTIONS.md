# REAPER Font Integration Testing Instructions

## Prerequisites

1. **REAPER 6.0+** with **ReaImGui extension** installed via ReaPack
2. DevToolbox font integration files in place
3. REAPER Console window open (Actions → Show console...)

## Testing Steps

### Step 1: Basic Font Integration Test

1. In REAPER, go to **Actions → Load/import ReaScript...**
2. Navigate to: `c:\Users\CraftAuto-Sales\AppData\Roaming\REAPER\Scripts\reaper_toolkit-1\`
3. Load: `test_font_integration_reaper.lua`
4. **Expected Result**: 
   - Window opens titled "Font Integration Test"
   - Shows font selector panel interface
   - Console shows: "Font Integration Test: Started"

### Step 2: Main DevToolbox Test

1. Load: `main.lua` from the same directory
2. **Expected Results**:
   - DevToolbox window opens with menu bar
   - Font Test section shows current font name and sample text
   - Console shows: "Font loaded: [FontName] [Size]px" or "Using default ImGui font"
   - No error messages about "font not attached to context"

### Step 3: Font Selector Panel Test

1. In DevToolbox, look for Tools menu or panel selector
2. Select "🔤 Font Selector" panel
3. **Expected Results**:
   - Font dropdown shows available fonts from font_config.lua
   - Size dropdown shows font sizes (8, 9, 10, 11, 12, 14, 16, 18, 20, 22, 24, 28, 32, 36, 48)
   - Preview checkbox works
   - Apply Font button functions
   - Diagnostics button provides feedback

### Step 4: Font Application Test

1. In Font Selector panel:
   - Select different font (e.g., "Consolas")
   - Select different size (e.g., "18")
   - Click "Apply Font"
2. **Expected Results**:
   - Status message shows "✅ Font applied: [FontName] [Size]px"
   - Preview text changes to selected font
   - Main DevToolbox font test section updates

### Step 5: Error Handling Test

1. Click "🔍 Diagnostics" button
2. Try applying different fonts
3. **Expected Results**:
   - Diagnostics show success/failure for each font
   - Failed fonts fall back gracefully to default
   - No crashes or ImGui errors

## Troubleshooting

### Common Issues:

**"ReaImGui not found"**
- Install ReaImGui from ReaPack (Extensions → ReaPack → Browse packages)
- Search for "ReaImGui" and install

**"Font not attached to context" error**
- This should be FIXED by our Font Loader Guide implementation
- If still occurring, check console for font loading messages

**Fonts not appearing**
- Check that font_config.lua is loading properly
- System fonts should always be available
- Custom TTF fonts need to be in fonts/ subdirectory

**DevToolbox not loading**
- Check console for Lua errors
- Verify all module files are present in modules/ directory

### Debug Information:

The following files help with debugging:

1. **test_font_loader_guide.lua** - Command line font system test
2. **test_font_sop_implementation.lua** - SOP compliance verification
3. **Console output** - Shows font loading success/failure messages

### Console Commands for Manual Testing:

```lua
-- Test font manager directly in REAPER console:
local font_manager = require('modules.font_manager')
font_manager.init()
local fonts = font_manager.get_available_fonts()
for i, font in ipairs(fonts) do print(i, font.name) end
```

## Success Criteria

✅ **Font integration working correctly when:**
- DevToolbox loads without font attachment errors
- Font selector panel shows all configured fonts
- Font changes apply immediately in preview
- Diagnostics button provides clear feedback
- No ImGui context destruction errors
- Font caching works (no repeated file loading)

## Additional Notes

- **Font files**: Custom TTF fonts should be placed in `fonts/` subdirectory
- **Performance**: Fonts are cached after first load for better performance
- **Fallback**: System always falls back to default ImGui font on errors
- **Cleanup**: REAPER handles ImGui context cleanup automatically

---

**🎯 Ready to test!** Follow these steps to verify the Font Loader Guide implementation works correctly in REAPER.
