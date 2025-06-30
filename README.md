# REAPER DevToolbox

[![GitHub](https://img.shields.io/badge/github-2nist/reaper_toolkit-blue)](https://github.com/2nist/reaper_toolkit)
[![REAPER](https://img.shields.io/badge/REAPER-v6.44%2B-orange)](https://www.reaper.fm/)
[![ReaImGui](https://img.shields.io/badge/ReaImGui-Required-green)](https://github.com/cfillion/reaimgui)

A comprehensive development environment and toolkit for REAPER, featuring advanced theming, font management, and modular development tools.

## ✨ Features

### 🎨 **Enhanced Theming System**
- **7 Built-in Themes**: Dark, Light, Blue, Green, Purple, Orange, Slate
- **🎲 Random Color Generator**: HSL-based cohesive color schemes
- **Custom Theme Support**: Create and load your own color schemes
- **Real-time Application**: See changes instantly across the interface
- **Interactive Color Editing**: Adjust individual color components
- **Theme Export/Import**: Share themes via clipboard or template files

### 🔤 **Font Management System**
- **Custom Font Support**: Install and use TTF/OTF fonts
- **Font Preview**: Real-time preview of font selections
- **Multiple Font Sizes**: From 8px to 48px
- **Font Organization**: Dedicated fonts directory with management tools
- **System Font Fallbacks**: Graceful handling when custom fonts fail

### 🛠️ **Development Framework**
- **Modular Panel System**: Easy-to-extend UI components
- **Script Manager**: Organize and execute REAPER scripts
- **Console Logger**: Real-time debugging and logging
- **Error Handling**: Comprehensive error reporting and recovery
- **Hot Reloading**: Dynamic panel loading and reloading

## 🚀 Quick Start

### Prerequisites
- **REAPER v6.44 or newer**
- **ReaImGui extension** (install via ReaPack)

### Installation
1. Clone this repository:
   ```bash
   git clone https://github.com/2nist/reaper_toolkit.git
   ```
2. Place in your REAPER Scripts directory
3. Run `main.lua` from REAPER's Actions menu
4. The DevToolbox interface will appear

### Basic Usage
1. **Panel Selection**: Use the left sidebar to switch between tools
2. **Theming**: Open Enhanced Theming Panel for complete color customization
3. **Font Configuration**: Use Config Panel for font management
4. **Custom Assets**: Install TTF/OTF fonts and create custom themes

## 📁 Project Structure

```
devtoolbox-reaper-master/
├── main.lua                    # Entry point and main interface
├── modules/                    # Core system modules
│   ├── script_manager.lua      # Panel loading and management
│   ├── console_logger.lua      # Logging and debugging
│   ├── font_manager_working.lua # Font system (latest)
│   └── theme_manager.lua       # Global theme management
├── panels/                     # UI panels and tools
│   ├── enhanced_theming_panel.lua # Advanced theming interface
│   ├── config_panel.lua           # Configuration and settings
│   └── style_editor_panel.lua     # Style editing (backup)
├── fonts/                      # Custom font storage
│   ├── README.md              # Font usage instructions
│   └── *.ttf, *.otf          # Custom font files
├── tests/                      # Test suites and validation
├── archive/                    # Historical documentation
└── docs/                       # API references and examples
```

## 🎨 Theming Guide

### Built-in Themes
- **Dark**: Professional dark interface for long coding sessions
- **Light**: Clean light interface for bright environments
- **Blue**: Ocean-inspired blue tones for calm focus
- **Green**: Nature-inspired green palette for creativity
- **Purple**: Creative purple scheme for artistic work
- **Orange**: Energetic orange design for high productivity
- **Slate**: Sophisticated gray tones for professional use

### Advanced Features
- **🎲 Random Generator**: Creates harmonious color schemes using HSL color theory
- **Color Theory**: Ensures proper contrast and accessibility
- **Live Preview**: See changes instantly in the main interface
- **Export System**: Share themes as Lua tables or template files

## 🔤 Font Integration

### Current Status
The font system provides:
- **Custom Font Installation**: TTF/OTF file support
- **Font Management Interface**: Browse, install, and organize fonts
- **Error-Safe Loading**: Graceful fallbacks when fonts fail
- **Debug Capabilities**: Comprehensive logging for troubleshooting

### Tested Fonts
- **Roboto Mono**: Programming font with excellent readability
- **System Defaults**: Built-in fallback fonts

### Font Management
```lua
-- Font Directory
/fonts/RobotoMono-Regular.ttf  # Example custom font

-- Installation Process
1. Open Config Panel
2. Click "Browse..." in Font Configuration
3. Select TTF/OTF file
4. Click "Install Font"
5. Font appears in dropdown selection
```

## 🧪 Testing

### Test Coverage
- ✅ **Theming System**: Complete theme application and switching
- ✅ **Panel Loading**: Module loading and error handling
- ✅ **Font Management**: Font installation and organization
- ✅ **UI Components**: Window management and layout
- ✅ **Error Recovery**: Graceful handling of component failures

### Running Tests
```bash
# Test specific components
lua test_font_working.lua
lua test_font_loading.lua

# Run test suite
cd tests/
lua test_floating_windows.lua
```

## 🔧 System Architecture

### Core Systems
1. **Script Manager**: Handles panel loading and lifecycle
2. **Theme Manager**: Global color management and application  
3. **Font Manager**: Custom font loading and system integration
4. **Console Logger**: Debug output and error tracking

### Panel Framework
```lua
-- Panel Structure
local M = {}

function M.init()
    -- Panel initialization
end

function M.draw(ctx)
    -- ImGui rendering code
    return true
end

return M
```

### Error Handling
- **Graceful Degradation**: System continues functioning if components fail
- **Comprehensive Logging**: Detailed error reporting in console
- **Safe Fallbacks**: Default behavior when advanced features unavailable

## 🔮 Future Development

### Planned Features
- **🎯 Enhanced Font Loading**: Direct ReaImGui font rendering
- **📦 Theme Marketplace**: Community theme sharing
- **🔌 Plugin Integration**: Support for external REAPER plugins
- **📱 Mobile Preview**: Theme preview for mobile interfaces
- **🤖 AI Theme Generation**: ML-powered color scheme creation

### Technical Roadmap
- **ReaImGui API Improvements**: Better font loading support
- **Performance Optimization**: Faster theme switching and rendering
- **Plugin Architecture**: Extensible panel system for third-party tools
- **Configuration Persistence**: Advanced settings management

## 📖 Documentation

### Available Guides
- `FONT_INTEGRATION_GUIDE.md` - Complete font system documentation
- `FONT_SYSTEM_STATUS.md` - Current font implementation status  
- `fonts/README.md` - Font directory usage and organization
- `tests/README.md` - Testing framework and procedures

### API References
- **ReaImGui Integration**: Modern UI framework for REAPER
- **REAPER Script API**: Integration with REAPER's scripting system
- **Lua Modules**: Modular architecture and component system

## 🤝 Contributing

### Development Workflow
1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes with proper testing
4. Update documentation as needed
5. Submit a pull request

### Coding Standards
- **Lua Style**: Follow existing code formatting
- **Error Handling**: Always include proper error checking
- **Documentation**: Comment complex logic and public APIs
- **Testing**: Add tests for new functionality

## 📝 Version History

### v2.1.0 (Current - June 2025)
- ✅ **Complete Theming System**: 7 presets + random generator
- ✅ **Font Management**: TTF/OTF installation and preview
- ✅ **Robust Error Handling**: Comprehensive failure recovery
- ✅ **Modular Architecture**: Clean panel-based system
- ✅ **Production Ready**: Tested and deployed in REAPER

### v2.0.0 (Previous)
- Enhanced theming with interactive editing
- Custom theme creation and export
- Font system foundation
- Panel management framework

### v1.0.0 (Legacy)
- Basic script management
- Simple theming support
- Console logging system

## 🙏 Acknowledgments

- **REAPER Community**: Inspiration and feedback for development
- **ReaImGui Developers**: Excellent GUI framework for modern interfaces
- **Font Creators**: Beautiful typefaces that enhance the user experience
- **Beta Testers**: Valuable feedback and bug reports

## 📄 License

This project is open source. See individual files for specific licensing information.

---

**🚀 Ready to enhance your REAPER development experience!**

*For issues, feature requests, or contributions, visit the [GitHub repository](https://github.com/2nist/reaper_toolkit).*