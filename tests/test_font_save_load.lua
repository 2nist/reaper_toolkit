-- Test font saving and loading
print("=== Font Save/Load Test ===")

-- Simulate font selection
local current_font_index = 4  -- Dymo font
local current_font_size_index = 6  -- 16pt

-- Available fonts (same as theming panel)
local available_fonts = {
    {name = "Default", family = "default", size = 14, description = "ReaImGui default font"},
    {name = "Helvetica", family = "Helvetica", size = 14, description = "Clean sans-serif (macOS)"},
    {name = "American Typewriter", family = "American Typewriter", size = 14, description = "Typewriter style (macOS)"},
    {name = "Dymo", family = "get_dymo_font_path_lazy", size = 14, description = "Embossed label font (custom)"},
    {name = "Segoe UI", family = "Segoe UI", size = 14, description = "System font (Windows)"},
}
local font_sizes = {10, 11, 12, 13, 14, 15, 16, 18, 20, 22, 24}

-- Test font saving (simulate save_theme function)
print("Selected font: " .. available_fonts[current_font_index].name)
print("Selected size: " .. font_sizes[current_font_size_index] .. "pt")

-- Create test theme content
local theme_content = "background=0x333333FF\n"
theme_content = theme_content .. "text=0xFFFFFFFF\n" 
theme_content = theme_content .. "button=0x4D4D80FF\n"
theme_content = theme_content .. "font_index=" .. current_font_index .. "\n"
theme_content = theme_content .. "font_size_index=" .. current_font_size_index .. "\n"

print("\nTheme file content would be:")
print(theme_content)

-- Test font loading (simulate load from theme file)
print("\n--- Simulating font loading ---")
local font_index = 1
local font_size_index = 5

for line in string.gmatch(theme_content, "[^\n]+") do
    local name, value = string.match(line, "([^=]+)=(.+)")
    if name == "font_index" then
        font_index = tonumber(value) or 1
    elseif name == "font_size_index" then
        font_size_index = tonumber(value) or 5
    end
end

print("Loaded font_index: " .. font_index)
print("Loaded font_size_index: " .. font_size_index)
print("Font: " .. available_fonts[font_index].name)
print("Size: " .. font_sizes[font_size_index] .. "pt")

print("=== Test Complete ===")
