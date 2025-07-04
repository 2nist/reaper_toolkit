# DevToolbox Enhanced Agent Prompt - Complete Usage Guide

## What is the Enhanced Agent Prompt?

The **Enhanced Agent Prompt** is an advanced panel in the DevToolbox that helps you:
1. **Create production-ready REAPER tools** with structured templates
2. **Generate complete Lua scripts** with working REAPER API calls
3. **Deploy tools automatically** to DevToolbox with one click
4. **Optimize AI prompts** for better code generation results

## How to Access the Enhanced Agent Prompt

1. **Open DevToolbox** in REAPER (run the main.lua script)
2. **Select "enhanced_agent_prompt"** from the UI Panels list on the left (loads by default)
3. You'll see the enhanced agent prompt interface in the main content area

## Step-by-Step Usage (Enhanced Version)

### Step 1: Choose Your Tool Type
Select from the **Tool Type** dropdown:
- **Track Tool** - Work with tracks, routing, track properties
- **FX Tool** - Manage effects, parameters, FX chains
- **Automation Tool** - Handle envelopes, automation lanes
- **Project Tool** - Project settings, markers, regions
- **Custom Tool** - Free-form tool development

### Step 2: Enter Tool Details
- **Tool Name**: Enter a descriptive name (e.g., "Track Color Manager")
- **Requirements**: Describe what your tool should do

**Enhanced prompts** (tool type guides the template):
```
Track Color Manager
Requirements: Show all tracks with color picker, include presets, save/load schemes
```

### Step 3: Use the Enhanced Workflow

#### **🎯 Generate & Test Tool** Button (One-Click Magic!)
- **What it does**: Creates complete working tool and deploys it automatically
- **Process**: Generates code → Saves to panels/ → Reloads DevToolbox → Ready to test!
- **Result**: Your tool appears in the UI Panels list immediately
- **Time**: Under 30 seconds from idea to working tool

#### **📋 Copy AI Prompt** Button
- **What it does**: Creates optimized prompt for ChatGPT/Claude
- **Includes**: Technical context, REAPER API requirements, tool type specifics
- **Usage**: Paste into AI assistant for custom development
- **Result**: AI generates production-ready code with proper error handling

### Step 3: Review the Draft Preview

The bottom section shows your generated script template:
```lua
-- your_tool_name.lua
-- Your original description here
-- Generated: 2025-07-04

local M = {}

function M.init()
    -- Setup code here
end

function M.draw(ctx)
    -- ImGui/Lua UI code here
end

return M
```

## Best Practices for Agent Prompts

### 1. Be Specific About UI Elements
```
❌ "Create a mixer tool"
✅ "Create a mixer with 8 faders, mute/solo buttons, and a master volume"
```

### 2. Include REAPER-Specific Details
```
❌ "Make an audio tool"
✅ "Tool that works with selected tracks in REAPER, using track sends and FX"
```

### 3. Mention ReaImGui Elements
```
❌ "Add some controls"
✅ "Use ImGui sliders for gain, buttons for mute/solo, and text display for track names"
```

### 4. Specify Integration Points
```
❌ "Tool for REAPER"
✅ "Tool that integrates with DevToolbox panel system, saves settings to REAPER resource folder"
```

## Enhanced Workflows

### Workflow 1: Rapid Prototyping (Recommended)
1. Select tool type from dropdown
2. Enter tool name and brief requirements  
3. Click **"🎯 Generate & Test Tool"**
4. Tool automatically appears in DevToolbox - test immediately!
5. Iterate by modifying generated code and reloading

**Time: 1-2 minutes from idea to working tool**

### Workflow 2: AI-Assisted Development
1. Select tool type and enter requirements
2. Click **"📋 Copy AI Prompt"** 
3. Paste into ChatGPT/Claude
4. Get production-ready code with proper REAPER API integration
5. Save code to panels/ directory and reload DevToolbox

**Result: Professional-quality tools with error handling**

### Workflow 3: Template-Based Development
1. Use enhanced tool type templates as starting points
2. Copy generated code structure
3. Customize implementation for specific needs
4. Leverage included REAPER API patterns

## Integration with DevToolbox

### Adding Your New Tool
1. **Save script** to `/panels/` or `/modules/` directory
2. **Restart DevToolbox** (it auto-scans for new panels)
3. **Select your tool** from the UI Panels list
4. **Test and debug** using the console log panel

### Using DevToolbox Features in Your Tool
```lua
-- Access console logging
console_logger.log("Your debug message here")

-- Use global ImGui context
function M.draw(ctx)
    ImGui.Text(ctx, "Your tool UI here")
end

-- Access REAPER safely
if reaper then
    local track_count = reaper.CountTracks(0)
end
```

## Troubleshooting

### Issue: "Log Prompt" doesn't work
- **Cause**: Directory permissions or path issues
- **Solution**: Check if `[REAPER Resources]/Scripts/devtoolbox/logs/` exists and is writable

### Issue: Draft script looks incomplete
- **Cause**: This is normal - it's just a template
- **Solution**: Use it as starting point, add your actual implementation code

### Issue: Can't find simple_agent_prompt panel
- **Cause**: Panel loading issue
- **Solution**: Check console log for loading errors, restart DevToolbox

## Example: Complete Agent Prompt Session

**Prompt:**
```
Create a track color manager for REAPER:
- Show all tracks in project with current colors
- Allow changing track colors with color picker
- Include color presets (drums=red, bass=blue, etc.)
- Save/load color schemes to files
- Apply colors to track items too
```

**Actions:**
1. ✅ Log Prompt (saves to log file)
2. ✅ Copy Prompt for Agent (paste to AI assistant)  
3. ✅ Draft Lua Script (generates template)
4. ✅ Copy Draft Script (paste to new file)

**Result:**
- Logged request for future reference
- AI-generated working script
- Template to build upon
- Clear development plan

This workflow helps you go from idea to working REAPER tool efficiently! 🎯

## Tips for Working with AI Assistants

When you copy the prompt to use with AI:

**Add this context:**
```
Create a REAPER script using ReaImGui (Dear ImGui for REAPER). 
The script should follow this structure:
- Use reaper.ImGui_* functions for UI
- Return a module with init() and draw(ctx) functions
- Handle errors gracefully with pcall()
- Log debug info with console_logger.log()

Here's my tool request:
[paste your prompt here]
```

This gives the AI the proper context for REAPER/ReaImGui development.
