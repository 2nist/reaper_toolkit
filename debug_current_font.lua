-- Test current font selection
print("=== Current Font Selection Debug ===")

-- Simulate REAPER environment
local mock_reaper = {
    GetResourcePath = function()
        return "/Users/Matthew/devtoolbox-reaper-master"
    end
}

-- Check what's in the theme file
local theme_file_path = mock_reaper.GetResourcePath() .. "/devtoolbox_theme.txt"
print("Looking for theme file at: " .. theme_file_path)

local file = io.open(theme_file_path, "r")
if file then
    print("Theme file found! Contents:")
    for line in file:lines() do
        print("  " .. line)
        
        local name, value = line:match("([^=]+)=(.+)")
        if name == "font_index" then
            print("    → Font index: " .. (tonumber(value) or "invalid"))
        elseif name == "font_size_index" then 
            print("    → Font size index: " .. (tonumber(value) or "invalid"))
        end
    end
    file:close()
else
    print("❌ Theme file not found!")
    print("This means no font preferences have been saved yet.")
    print("Try selecting a font in the theming panel and clicking 'Apply Font'")
end

-- Available fonts (should match theming panel)
local available_fonts = {
    {name = "Default", family = "default"},
    {name = "Helvetica", family = "Helvetica"},
    {name = "American Typewriter", family = "American Typewriter"},
    {name = "Dymo", family = "get_dymo_font_path_lazy"},
    {name = "Segoe UI", family = "Segoe UI"},
    {name = "Times New Roman", family = "Times New Roman"},
    {name = "Sans-serif", family = "sans-serif"},
    {name = "Serif", family = "serif"},
    {name = "Monospace", family = "monospace"},
    {name = "Monaco", family = "Monaco"},
    {name = "Consolas", family = "Consolas"},
}

print("\nAvailable fonts:")
for i, font in ipairs(available_fonts) do
    print("  " .. i .. ". " .. font.name .. " (" .. font.family .. ")")
end

print("=== End Debug ===")
