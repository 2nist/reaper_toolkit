# DevToolbox Global Theming System

## Overview

The DevToolbox now features a **comprehensive global theming system** that allows the Enhanced Theming Panel to control the appearance of **ALL modules and tools**, not just the main DevToolbox window.

## 🎨 **What the Theming System Affects:**

### ✅ **Currently Themed:**
- **DevToolbox Main Window** - Background, text, buttons, and borders
- **Enhanced Theming Panel** - Self-theming with live preview
- **Config Panel** - Theme status display and controls
- **All Script Tools** - When they adopt theming support

### 🔄 **Easy to Add Theming To:**
- Any new modules or tools
- Existing scripts can be updated to use global theming
- Third-party tools can integrate with the theme system

---

## 🚀 **How It Works:**

1. **Enhanced Theming Panel** manages global theme colors (background, text, buttons, etc.)
2. **Theme Manager Module** provides easy theming API for all tools
3. **Modules** use simple theme functions to inherit the global theme
4. **Real-time Updates** - Changes in theming panel apply immediately to all modules

---

## 🎯 **For Users:**

### **Using the Enhanced Theming Panel:**
1. Open DevToolbox in REAPER
2. Enhanced Theming Panel shows by default in main content area
3. **Apply Presets**: Click "Apply Dark", "Apply Light", or "Apply Blue" for instant themes
4. **Custom Colors**: Use color pickers to customize individual elements
5. **Live Preview**: See changes immediately across ALL DevToolbox tools
6. **Export/Share**: Export your custom themes to clipboard for sharing

### **What You Can Theme:**
- **Background Color** - Main window and tool backgrounds
- **Text Color** - All text throughout DevToolbox
- **Button Color** - Default button appearance
- **Button Hovered** - Button color when mouse hovers
- **Button Active** - Button color when clicked/pressed

---

## 🛠 **For Module Developers:**

### **Easy Integration - Method 1: Theme Manager**
```lua
-- In your module's init() function:
local theme_manager = require 'theme_manager'
theme_manager.init()

-- In your draw() function:
function M.draw(ctx)
    local ImGui = ... -- your ImGui setup
    
    -- Apply global theme automatically
    local colors_pushed = theme_manager.apply_theme(ctx, ImGui)
    
    -- Your regular ImGui code here...
    ImGui.Text(ctx, "This text uses theme colors!")
    
    -- Clean up when done
    theme_manager.cleanup_theme(ctx, ImGui, colors_pushed)
end
```

### **Themed Helpers - Method 2: Simple Functions**
```lua
-- Use themed helper functions:
theme_manager.themed_text(ctx, ImGui, "This text is themed!")
theme_manager.themed_button(ctx, ImGui, "Themed Button")

-- Get specific colors:
local bg_color = theme_manager.get_theme_color('background')
local text_color = theme_manager.get_theme_color('text')
```

### **Advanced Integration - Method 3: Direct Access**
```lua
-- Access enhanced theming panel directly:
local enhanced_theming = require 'enhanced_theming_panel'
local colors = enhanced_theming.get_theme_colors()

-- Apply specific colors:
ImGui.PushStyleColor(ctx, ImGui.Col_WindowBg, colors.background)
ImGui.PushStyleColor(ctx, ImGui.Col_Text, colors.text)
-- ... your UI code ...
ImGui.PopStyleColor(ctx, 2)
```

---

## 📋 **Available Theme Colors:**

| Color Name | Purpose | Example Use |
|------------|---------|-------------|
| `background` | Window/panel backgrounds | Main areas, child windows |
| `text` | Primary text color | Labels, descriptions, content |
| `button` | Default button color | Normal button state |
| `button_hovered` | Button hover color | When mouse is over button |
| `button_active` | Button pressed color | When button is clicked |

---

## 🎨 **Theme Presets:**

### **Dark Theme** (Default)
- Background: Dark gray (`#333333`)
- Text: White (`#FFFFFF`)
- Buttons: Blue-gray tones

### **Light Theme**
- Background: Light gray (`#F0F0F0`)
- Text: Dark gray (`#1A1A1A`)
- Buttons: Light blue tones

### **Blue Theme**
- Background: Dark blue (`#1A1A2E`)
- Text: White (`#FFFFFF`)
- Buttons: Blue gradient

---

## 🔄 **Real-time Theme Updates:**

When a user changes theme colors in the Enhanced Theming Panel:
1. ✅ **Main DevToolbox window** updates immediately
2. ✅ **Config Panel** shows new theme status
3. ✅ **All themed modules** inherit new colors automatically
4. ✅ **No restart required** - changes are instant

---

## 🎉 **Summary:**

**The DevToolbox theming system is now GLOBAL** - it affects the appearance of all modules and tools, not just the main window. Users can customize the entire DevToolbox experience with their preferred colors, and module developers can easily make their tools theme-aware with just a few lines of code.

**Changes in the Enhanced Theming Panel now control the look and feel of the entire DevToolbox ecosystem!** 🎨✨
