# REAPER DevToolbox

A comprehensive development environment and toolkit for REAPER, featuring modern UI components, customizable theming, and advanced font management.

## ✨ Features

### 🎨 **Enhanced Theming System**
- **7 Built-in Themes**: Dark, Light, Blue, Green, Purple, Orange, Slate
- **🎲 Random Color Generator**: Create cohesive random color schemes
- **Custom Theme Support**: Create and load your own color schemes
- **Real-time Application**: See changes instantly
- **Interactive Color Editing**: Adjust individual color components
- **Theme Export/Import**: Share themes via clipboard or files

### 🔤 **Advanced Font Management**
- **System Font Integration**: Choose from generic font families
- **Custom TTF/OTF Support**: Upload and use your own fonts
- **16 Font Sizes**: From 8px to 48px
- **Live Preview**: See font changes before applying
- **Font Management Tools**: Install, remove, and organize fonts

### 🛠️ **Development Tools**
- **Script Manager**: Organize and execute REAPER scripts
- **Console Logger**: Real-time debugging and logging
- **Test Framework**: Comprehensive testing utilities
- **Panel System**: Modular UI components

## 🚀 Quick Start

### Prerequisites
- REAPER v6.44 or newer
- ReaImGui extension (install via ReaPack)

### Installation
1. Clone or download this repository
2. Place in your REAPER Scripts directory
3. Run `main.lua` from REAPER's Actions menu
4. The DevToolbox interface will appear

### Basic Usage
1. **Select Tools**: Use the panel selector to switch between tools
2. **Customize Themes**: Open Enhanced Theming Panel for color options
3. **Configure Fonts**: Use Config Panel for font selection and management
4. **Install Custom Fonts**: Browse and install TTF/OTF files
5. **Export Settings**: Save your configurations for sharing

## 📁 Project Structure

```
devtoolbox-reaper-master/
├── main.lua                    # Entry point
├── modules/
│   ├── script_manager.lua      # Tool loading system
│   ├── console_logger.lua      # Logging utilities
│   └── font_manager.lua        # Font management system
├── panels/
│   ├── enhanced_theming_panel.lua  # Theme customization
│   ├── config_panel.lua           # General configuration
│   └── style_editor_panel.lua     # Style editing (backup)
├── fonts/                      # Custom font storage
├── themes/                     # Custom theme files
├── tests/                      # Test suites
└── docs/                       # Documentation and examples
```

## 🎨 Theming Guide

### Built-in Themes
- **Dark**: Professional dark interface
- **Light**: Clean light interface  
- **Blue**: Ocean-inspired blue tones
- **Green**: Nature-inspired green palette
- **Purple**: Creative purple scheme
- **Orange**: Energetic orange design
- **Slate**: Sophisticated gray tones

### Custom Theme Creation
1. Use Enhanced Theming Panel
2. Try the 🎲 Generate Random button for inspiration
3. Adjust colors with Edit buttons
4. Use Darken/Lighten All for quick adjustments
5. Export theme to clipboard or file
6. Share with others or save as template

See `THEMING_STATUS.md` for complete theming documentation.

## 🔤 Font Integration

### System Fonts
Choose from generic font families:
- Sans-serif (default)
- Serif
- Monospace
- Cursive
- Fantasy

### Custom Fonts
Install your own TTF/OTF files:
1. Open Config Panel
2. Click "Browse..." in Font Configuration
3. Select your font file
4. Click "Install Font"
5. Choose from Font Family dropdown

### Recommended Fonts
- **Inter**: Modern interface font
- **Fira Code**: Programming font with ligatures
- **Roboto**: Google's material design font
- **Source Sans Pro**: Adobe's open-source font

See `FONT_INTEGRATION_GUIDE.md` for complete font documentation.

## 🧪 Testing

### Run Tests
```bash
# Test font manager
lua test_font_manager.lua

# Test individual components
lua tests/test_suite.lua
```

### Test Coverage
- ✅ Font manager functionality
- ✅ Theme system integration
- ✅ Panel loading and switching
- ✅ Configuration persistence
- ✅ Error handling and fallbacks

## 📖 Documentation

- `THEMING_STATUS.md` - Complete theming system documentation
- `FONT_INTEGRATION_GUIDE.md` - Font management and installation guide
- `FONT_SYSTEM_STATUS.md` - Font system implementation status
- `CUSTOM_THEMES_GUIDE.md` - Custom theme creation tutorial
- `fonts/README.md` - Font directory usage instructions

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

### Development Guidelines
- Follow existing code style
- Add documentation for new features
- Test thoroughly before submitting
- Update relevant documentation files

## 📝 Version History

### v2.0.0 (Current)
- ✅ Enhanced theming system with 7 presets
- ✅ 🎲 Random color theme generator with HSL color space
- ✅ Complete font management system
- ✅ TTF/OTF custom font support
- ✅ Interactive color editing
- ✅ Theme export/import functionality

### v1.0.0 (Previous)
- Basic panel system
- Simple theming support
- Script management tools
- Console logging

## 📄 License

This project is open source. See individual files for specific licensing information.

## 🙏 Acknowledgments

- REAPER community for inspiration and feedback
- ReaImGui developers for the excellent GUI framework
- Font creators for beautiful typefaces
- Beta testers for valuable feedback

---

**Ready to enhance your REAPER development experience!** 🚀✨
