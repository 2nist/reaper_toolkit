-- tools_registry.lua
-- Central registry for all available tools/panels
-- This file defines which tools are available and their metadata

return {
  config_panel = {
    label = "⚙ Config Panel",
    icon = "⚙",
    active = true,
    file = "config_panel.lua",
    category = "Configuration"
  },
  style_editor_panel = {
    label = "🎨 Style Editor",
    icon = "🎨",
    active = false,
    file = "style_editor_panel.lua",
    category = "UI"
  },
  enhanced_theming_panel = {
    label = "🎛 Theme Panel",
    icon = "🎛",
    active = true,
    file = "enhanced_theming_panel.lua",
    category = "UI"
  },
  template_tool = {
    label = "📋 Template Tool",
    icon = "📋",
    active = true,
    file = "template_tool.lua",
    category = "Development"
  },
  test_mvp_tool = {
    label = "🧪 Test MVP Tool",
    icon = "🧪",
    active = false,
    file = "test_mvp_tool.lua",
    category = "Testing"
  },
  tool_browser_panel = {
    label = "🧰 Tool Browser",
    icon = "🧰",
    active = true,
    file = "tool_browser_panel.lua",
    category = "Utility"
  },
  chord_dataset_browser = {
    label    = "🎼 Chord Browser",
    icon     = "🎼",
    active   = true,
    file     = "chord_dataset_browser.lua",
    category = "MIDI"
  },
}
