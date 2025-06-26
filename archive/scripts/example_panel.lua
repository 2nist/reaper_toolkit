-- Example panel script for DevToolbox (place in scripts/panels/example_panel.lua)
local panel = {}

panel.visible = false

function panel.draw(ctx)
  if not panel.visible then return end
  if imgui.Begin(ctx, "Example Panel", true) then
    imgui.Text(ctx, "Hello from Example Panel!")
    if imgui.Button(ctx, "Close") then
      panel.visible = false
    end
  end
  imgui.End(ctx)
end

return panel
