-- DevToolbox Custom Theme Template
-- Copy this file and modify the colors to create your own custom theme

-- Theme Name: [Enter your theme name here]
-- Description: [Describe your theme]

local custom_theme = {
    -- Window background color (0xRRGGBBAA format)
    background = 0x2B2B2BFF,     -- Dark gray
    
    -- Text color
    text = 0xFFFFFFFF,           -- Pure white
    
    -- Button colors
    button = 0x404040FF,         -- Medium gray
    button_hovered = 0x505050FF, -- Lighter gray (when mouse hovers)
    button_active = 0x606060FF,  -- Even lighter gray (when clicked)
}

--[[
HOW TO USE THIS TEMPLATE:

1. **Understand the Color Format:**
   Colors are in hexadecimal format: 0xRRGGBBAA
   - RR = Red component (00-FF)
   - GG = Green component (00-FF) 
   - BB = Blue component (00-FF)
   - AA = Alpha/transparency (FF = opaque, 00 = transparent)

2. **Color Examples:**
   0xFF0000FF = Pure red
   0x00FF00FF = Pure green  
   0x0000FFFF = Pure blue
   0x000000FF = Black
   0xFFFFFFFF = White
   0x808080FF = Gray
   0xFF00FFFF = Magenta
   0x00FFFFFF = Cyan
   0xFFFF00FF = Yellow

3. **Creating Your Theme:**
   - Modify the color values above
   - Keep the AA (alpha) values as FF for solid colors
   - Test your colors by converting RGB values:
     RGB(255, 128, 0) = 0xFF8000FF (orange)

4. **Applying Your Theme:**
   Method A - Code Integration:
   - Copy the custom_theme table values
   - Add them as a new preset in enhanced_theming_panel.lua

   Method B - Manual Application:
   - Copy each color value 
   - Use the "Edit" buttons in the Enhanced Theming Panel
   - Apply individual colors one by one

5. **Color Picker Tools:**
   Use online color pickers to find colors you like:
   - https://htmlcolorcodes.com/color-picker/
   - Convert RGB(r,g,b) to hex: 0xRRGGBBFF

6. **Theme Ideas:**
   - **Warm Theme**: Orange/brown tones
   - **Cool Theme**: Blue/teal tones  
   - **Monochrome**: Various shades of one color
   - **High Contrast**: Very light/dark combinations
   - **Pastel Theme**: Soft, muted colors
   - **Neon Theme**: Bright, vibrant colors
]]

-- Example: Warm Orange Theme
local warm_theme = {
    background = 0x2D1B14FF,     -- Dark brown
    text = 0xFFF8F0FF,           -- Warm white
    button = 0xD2691EFF,         -- Chocolate orange
    button_hovered = 0xFF7F00FF, -- Bright orange
    button_active = 0xB8860BFF,  -- Dark golden rod
}

-- Example: Cool Teal Theme  
local cool_theme = {
    background = 0x0D1B2AFF,     -- Dark navy
    text = 0xF0FDFFFF,           -- Cool white
    button = 0x1B4B6BFF,         -- Steel blue
    button_hovered = 0x2E86ABFF, -- Light blue
    button_active = 0x0F3460FF,  -- Dark blue
}

-- Example: High Contrast Theme
local contrast_theme = {
    background = 0x000000FF,     -- Pure black
    text = 0xFFFFFFFF,           -- Pure white
    button = 0x333333FF,         -- Dark gray
    button_hovered = 0x666666FF, -- Medium gray
    button_active = 0x999999FF,  -- Light gray
}

return {
    custom = custom_theme,
    warm = warm_theme,
    cool = cool_theme,
    contrast = contrast_theme
}
