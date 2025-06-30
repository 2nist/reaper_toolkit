![1751250641456](image/CUSTOM_THEMES_GUIDE/1751250641456.png)![1751250649094](image/CUSTOM_THEMES_GUIDE/1751250649094.png)![1751250703278](image/CUSTOM_THEMES_GUIDE/1751250703278.png)![1751250710349](image/CUSTOM_THEMES_GUIDE/1751250710349.png)# 🎨 DevToolbox Custom Theme![1751250748244](image/CUSTOM_THEMES_GUIDE/1751250748244.png) Creation Guide

The enhanced theming panel now supports multiple ways to create custom themes! Here are all the methods available:

## 📋 Available Built-in Themes

The enhanced theming panel now includes **7 built-in themes**:

1. **Dark** - Classic dark gray theme
2. **Light** - Clean light theme  
3. **Blue** - Professional blue theme
4. **Green** - Nature-inspired emerald theme
5. **Purple** - Creative purple theme
6. **Orange** - Warm orange theme
7. **Slate** - Modern blue-gray theme

## 🛠️ Methods to Create Custom Themes

### Method 1: Interactive Theme Editor
**Best for:** Quick adjustments and experimentation

1. Open DevToolbox → Enhanced Theming Panel
2. Click "Edit" next to any color to see current values in console
3. Use "Darken All" or "Lighten All" for quick adjustments
4. Use "Export Theme" to save your custom colors
5. Copy the exported values for later use

### Method 2: Custom Theme Template File
**Best for:** Creating complete custom themes with documentation

1. Edit `custom_theme_template.lua` in the DevToolbox folder
2. Modify the color values in the template:
   ```lua
   local my_theme = {
       background = 0x1A1A2EFF,     -- Your background color
       text = 0xFFFFFFFF,           -- Your text color
       button = 0x3B82F6FF,         -- Your button color
       button_hovered = 0x60A5FAFF, -- Button hover color
       button_active = 0x2563EBFF,  -- Button active color
   }
   ```
3. Save the file
4. In DevToolbox, click "Load Custom" to apply your theme

### Method 3: Direct Code Integration
**Best for:** Permanent custom themes

1. Open `panels/enhanced_theming_panel.lua`
2. Find the `presets` table (around line 27)
3. Add your custom theme:
   ```lua
   ["My Theme"] = {
       background = 0x2D1B14FF,     -- Your colors here
       text = 0xFFF8F0FF,
       button = 0xD2691EFF,
       button_hovered = 0xFF7F00FF,
       button_active = 0xB8860BFF,
   },
   ```
4. Your theme will appear as a preset button

### Method 4: Console-Based Editing
**Best for:** Precise color adjustments

1. Click "Edit" buttons in the Enhanced Theming Panel
2. See current color values in the console
3. Use online color picker tools to find new colors
4. Apply colors using the template method

## 🎯 Color Format Guide

### Hex Color Format: `0xRRGGBBAA`
- **RR** = Red component (00-FF)
- **GG** = Green component (00-FF)  
- **BB** = Blue component (00-FF)
- **AA** = Alpha/opacity (FF = solid, 00 = transparent)

### Common Colors:
```
0xFF0000FF = Red        0x008000FF = Green
0x0000FFFF = Blue       0xFFFF00FF = Yellow  
0xFF00FFFF = Magenta    0x00FFFFFF = Cyan
0x000000FF = Black      0xFFFFFFFF = White
0x808080FF = Gray       0xFFA500FF = Orange
```

### Converting RGB to Hex:
RGB(255, 128, 64) → 0xFF8040FF

## 🌈 Theme Ideas & Inspiration

### **Warm Themes:**
- Autumn: Browns, oranges, reds
- Sunset: Orange, pink, yellow gradients
- Coffee: Dark browns with cream accents

### **Cool Themes:**  
- Ocean: Blues, teals, sea greens
- Winter: Light blues, whites, grays
- Forest: Dark greens with earth tones

### **Special Themes:**
- **High Contrast**: Pure black/white for accessibility
- **Pastel**: Soft, muted colors for gentle appearance
- **Neon**: Bright, vibrant colors for modern look
- **Monochrome**: Single color with different saturations

## 🔧 Quick Start Examples

### Example 1: Warm Coffee Theme
```lua
local coffee_theme = {
    background = 0x3C2415FF,     -- Dark coffee brown
    text = 0xF5DEB3FF,           -- Wheat/cream color
    button = 0x8B4513FF,         -- Saddle brown
    button_hovered = 0xA0522DFF, -- Sienna
    button_active = 0x654321FF,  -- Dark brown
}
```

### Example 2: Ocean Theme
```lua
local ocean_theme = {
    background = 0x001F3FFF,     -- Navy blue
    text = 0xF0F8FFFF,           -- Alice blue
    button = 0x0074D9FF,         -- Ocean blue
    button_hovered = 0x7FDBFFFF, -- Light sky blue
    button_active = 0x004B7AFF,  -- Dark blue
}
```

### Example 3: Retro Gaming Theme  
```lua
local retro_theme = {
    background = 0x2E0016FF,     -- Dark magenta
    text = 0x00FF41FF,           -- Matrix green
    button = 0xFF1493FF,         -- Deep pink
    button_hovered = 0xFF69B4FF, -- Hot pink
    button_active = 0xDC143CFF,  -- Crimson
}
```

## 📝 Best Practices

1. **Test Readability**: Ensure text contrasts well with background
2. **Consistent Palette**: Use colors that work well together
3. **Button Hierarchy**: Make hover/active states clearly different
4. **Save Your Work**: Always export themes you like
5. **Start Simple**: Begin with small color adjustments

## 🚀 Advanced Tips

- **Use Color Theory**: Complementary colors create good contrast
- **Online Tools**: Use color palette generators for inspiration
- **Copy Existing Themes**: Start with a built-in theme and modify it
- **Test in Different Lighting**: Check your theme in various environments

Your custom themes will be applied immediately when you click the preset buttons or use the load functions!
