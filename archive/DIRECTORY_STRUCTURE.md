# DevToolbox Directory Structure

## 📁 **Organized Directory Structure**

The DevToolbox has been reorganized into a clear, logical structure that separates different types of code by their purpose and functionality.

---

## 📂 **Directory Breakdown:**

### **`/modules/` - Backend/Core Systems**
**Purpose:** Core systems and backend functionality that other parts of DevToolbox depend on.
**Loaded by:** `require()` statements in main.lua and other modules
**User Visibility:** Hidden from users - these are internal systems

**Files:**
- `console_logger.lua` - Core logging system with info/error/debug/warn functions
- `script_manager.lua` - Manages loading/unloading UI panels from `/panels/` directory
- `theme_manager.lua` - Global theming system for all UI elements
- `theming.lua` - Core theming utilities and helpers

---

### **`/panels/` - UI Panels (User-Facing Tools)**
**Purpose:** User-facing UI panels that appear in the DevToolbox interface
**Loaded by:** Script manager automatically scans this directory
**User Visibility:** **These appear in the "UI Panels" list in DevToolbox**

**Files:**
- `config_panel.lua` - Configuration UI panel for DevToolbox settings
- `enhanced_theming_panel.lua` - Advanced theming UI with presets and color pickers
- `style_editor_panel.lua` - Comprehensive ImGui style editor
- `template_tool.lua` - Template for creating new UI panels
- `test_mvp_tool.lua` - Test/development UI panel

**How Panels Work:**
- Each panel is a Lua module with `init()`, `draw()`, and `shutdown()` functions
- Users select panels from the "UI Panels" list in DevToolbox
- Selected panel appears in the main content area
- Panels can use the global theming system via `theme_manager`

---

### **`/utils/` - Development Utilities**
**Purpose:** Development and testing utilities that don't have UI
**Loaded by:** Manual require() when needed
**User Visibility:** Hidden from users - these are development tools

**Files:**
- `harden_envi_mocks.lua` - Development utility for testing environment mocks
- `parse_imgui_api_test_results.lua` - Utility for parsing ImGui API test results
- `sync_envi_mocks.lua` - Development utility for synchronizing environment mocks

---

## 🔄 **How the System Works:**

### **1. Main.lua Startup:**
```lua
-- Loads core modules
local script_manager = require 'script_manager'
local console_logger = require 'console_logger'
local theming_panel = require 'enhanced_theming_panel'

-- Script manager scans /panels/ directory
script_manager.init(script_path)
script_manager.reload_scripts()
```

### **2. Panel Discovery:**
- Script manager automatically finds all `.lua` files in `/panels/`
- Each panel is loaded as a module
- Panels appear in the "UI Panels" selection list

### **3. Panel Selection:**
- User clicks "Select" next to a panel name
- Selected panel's `draw()` function is called in main content area
- Panel can use global theming system for consistent appearance

### **4. Panel Structure:**
```lua
-- Example panel structure
local M = {}

function M.init()
    -- Initialize panel (called once when loaded)
end

function M.draw(ctx)
    -- Draw UI (called every frame when panel is selected)
    local ImGui = _G.ImGui or require('imgui')
    ImGui.Text(ctx, "Hello from panel!")
end

function M.shutdown()
    -- Cleanup (called when panel is unloaded)
end

return M
```

---

## 🎨 **Theming Integration:**

### **Global Theming System:**
- `/modules/theme_manager.lua` provides global theming API
- `/panels/enhanced_theming_panel.lua` is the UI for theme customization
- All panels can use themed elements:

```lua
-- In any panel:
local theme_manager = require 'theme_manager'

function M.draw(ctx)
    local ImGui = _G.ImGui
    
    -- Apply global theme
    local colors_pushed = theme_manager.apply_theme(ctx, ImGui)
    
    -- Your UI code here...
    ImGui.Text(ctx, "This text uses global theme colors!")
    
    -- Cleanup
    theme_manager.cleanup_theme(ctx, ImGui, colors_pushed)
end
```

---

## 🛠 **For Developers:**

### **Creating a New UI Panel:**
1. Copy `/panels/template_tool.lua` to `/panels/your_panel_name.lua`
2. Modify the `init()`, `draw()`, and `shutdown()` functions
3. Restart DevToolbox - your panel will appear in the UI Panels list automatically

### **Creating a New Backend Module:**
1. Create `/modules/your_module.lua`
2. Add `require 'your_module'` to main.lua if needed
3. Other modules and panels can use `require 'your_module'`

### **Creating Development Utilities:**
1. Create `/utils/your_utility.lua`
2. Use `require 'your_utility'` when needed for development/testing

---

## 📋 **Summary:**

| Directory | Purpose | User Visible | Auto-Loaded |
|-----------|---------|--------------|-------------|
| `/modules/` | Backend systems | ❌ No | ✅ Yes (by main.lua) |
| `/panels/` | UI panels | ✅ Yes | ✅ Yes (by script_manager) |
| `/utils/` | Dev utilities | ❌ No | ❌ Manual require() |

**Key Benefits:**
- ✅ Clear separation of concerns
- ✅ UI panels automatically discovered and loaded
- ✅ Easy to add new panels without modifying main.lua
- ✅ Backend modules stay hidden from users
- ✅ Development utilities separated from user-facing code
- ✅ Consistent global theming across all panels

**The DevToolbox now has a clean, organized structure that makes it easy to develop new UI panels and maintain the codebase!** 🎉
