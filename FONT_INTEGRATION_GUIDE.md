# Font Integration Guide for DevToolbox

## Overview
The DevToolbox now includes comprehensive font management capabilities, allowing you to customize the interface with system fonts and custom TTF/OTF files.

## Features

### 🔤 Font Configuration
- **System Font Support**: Choose from generic font families (sans-serif, serif, monospace, cursive, fantasy)
- **Custom TTF/OTF Integration**: Upload and use your own font files
- **Font Size Selection**: Pick from predefined sizes (8px to 48px)
- **Live Preview**: See how fonts look before applying
- **Font Management**: Install, remove, and organize custom fonts

### 📁 Custom Font Installation

#### Method 1: Through Config Panel
1. Open DevToolbox and select the **Config Panel**
2. Scroll to the **Font Configuration** section
3. In **Install Custom Font**, click **Browse...** to select a TTF/OTF file
4. Click **Install Font** to add it to your collection
5. The font will appear in the **Font Family** dropdown

#### Method 2: Manual Installation
1. Place your TTF/OTF files in the `/fonts/` directory
2. Click **Refresh Fonts** in the Config Panel
3. Your fonts will automatically appear in the dropdown

### 🛠️ Font Management Tools

#### Available Actions:
- **Export Font List**: Copy all available fonts to clipboard
- **Open Fonts Folder**: Direct access to the fonts directory
- **Refresh Fonts**: Scan for newly added font files
- **Remove Custom Font**: Delete unwanted custom fonts

## Supported Font Formats

### ✅ Supported
- **TTF (TrueType Font)** - Most common format
- **OTF (OpenType Font)** - Adobe/Microsoft standard

### ❌ Not Supported
- WOFF/WOFF2 (Web fonts)
- EOT (Embedded OpenType)
- Type1/PostScript fonts

## Font Examples

### Recommended Free Fonts for UI:
1. **Inter** - Modern sans-serif, excellent for interfaces
2. **Roboto** - Google's material design font
3. **Fira Code** - Monospace font with programming ligatures
4. **Source Sans Pro** - Adobe's open-source sans-serif
5. **Noto Sans** - Google's multilingual font family

### Where to Find Fonts:
- **Google Fonts** (fonts.google.com) - Free, open-source fonts
- **Font Squirrel** (fontsquirrel.com) - Curated free fonts
- **Adobe Fonts** (fonts.adobe.com) - Subscription service
- **DaFont** (dafont.com) - Free font archive

## Technical Details

### Font Loading Process:
1. Fonts are loaded using REAPER's ImGui font system
2. Custom fonts are copied to the local fonts directory
3. Font instances are created and attached to the ImGui context
4. Configuration is saved and persists between sessions

### Storage Locations:
- **Custom Fonts**: `/fonts/` directory in your project
- **Font Config**: `font_config.lua` in your project root
- **System Fonts**: Loaded from OS font families

### Performance Notes:
- Font loading happens during initialization
- Large fonts (>32px) may impact performance
- Custom fonts are cached for quick access
- Font preview uses temporary instances

## Usage Examples

### Example 1: Installing a Programming Font
```
1. Download "Fira Code" from GitHub releases
2. Use Config Panel > Browse... to select FiraCode-Regular.ttf
3. Click "Install Font"
4. Select "Fira Code (Custom)" from Font Family dropdown
5. Choose size 14px for optimal readability
```

### Example 2: Setting Up a Design Font
```
1. Download "Inter" font family from rsms.me/inter
2. Install Inter-Medium.ttf through the Config Panel
3. Select "Inter Medium (Custom)" and size 16px
4. Use for a clean, modern interface appearance
```

### Example 3: Bulk Font Installation
```
1. Place multiple TTF files in the /fonts/ directory
2. Click "Refresh Fonts" in Config Panel
3. All fonts will be automatically detected
4. Choose your preferred font from the expanded list
```

## Troubleshooting

### Font Not Appearing
- **Check file format**: Ensure it's TTF or OTF
- **Verify installation**: Look for success message
- **Refresh fonts**: Click the refresh button
- **Restart DevToolbox**: Close and reopen for complex fonts

### Font Looks Wrong
- **Try different sizes**: Some fonts need specific sizes
- **Check font weight**: Try Regular, Medium, or Bold variants
- **Verify font file**: Ensure the TTF/OTF isn't corrupted

### Performance Issues
- **Reduce font size**: Large fonts (>32px) can slow rendering
- **Limit custom fonts**: Too many fonts can impact startup time
- **Use system fonts**: Generic families (sans-serif) are optimized

## Advanced Configuration

### Manual Font Config Editing
The font configuration is stored in `font_config.lua`:

```lua
-- Example font_config.lua
return {
  current_font = {
    name = "Fira Code (Custom)",
    path = "/path/to/fonts/FiraCode-Regular.ttf",
    filename = "FiraCode-Regular.ttf",
  },
  current_font_size = 14,
}
```

### Font Fallback Chain
1. **Selected Custom Font** - Your chosen TTF/OTF
2. **Selected System Font** - OS font family
3. **Default Sans-Serif** - ImGui default
4. **Built-in Font** - REAPER's fallback font

## Integration with Themes

Custom fonts work seamlessly with the Enhanced Theming Panel:
- Font settings are independent of color themes
- All theme presets respect your font choice
- Font configuration persists across theme changes
- Export/import includes font information

## Future Enhancements

### Planned Features:
- Font weight selection (Regular, Bold, Light)
- Font style options (Italic, Oblique)
- Font subset loading for performance
- Font preview with custom text
- Automatic font pairing suggestions

Ready to customize your DevToolbox interface with beautiful fonts! 🎨✨
