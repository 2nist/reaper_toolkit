# ReaImGui API Reference

This document provides an overview of the simulated ReaImGui functions available in the EnviREAment virtual REAPER environment.

## Context Management
- `ImGui_CreateContext()`: Create a new ImGui context. Returns a context object.
- `ImGui_DestroyContext(ctx)`: Destroy the given ImGui context.

## Frame Control
- `ImGui_NewFrame(ctx)`: Begin a new ImGui frame.
- `ImGui_Render(ctx)`: Render the current ImGui frame.

## Widgets
- `ImGui_Text(ctx, text)`: Display a line of text.
- `ImGui_Button(ctx, label)`: Display a button; returns `true` if clicked.

## TODO
Expand with additional functions such as:
- Input controls (InputText, SliderFloat, etc.)
- Window management (Begin, End)
- Style/Color functions (PushStyleColor, PopStyleColor)

