# DevToolbox Automated Tests

These tests use the EnviREAment virtual REAPER environment to validate DevToolbox scripts and modules.

## Running Tests

From the project root, run:

```
lua EnviREAment/enviREAment_core_lib/enhanced_virtual_reaper.lua --test tests/test_devtoolbox.lua
lua EnviREAment/enviREAment_core_lib/enhanced_virtual_reaper.lua --test tests/test_config_panel.lua
lua EnviREAment/enviREAment_core_lib/enhanced_virtual_reaper.lua --test tests/test_template_tool.lua
```

## Adding More Tests

- Add a new `test_<tool>.lua` file in this directory for each tool/module.
- Use the pattern in the existing test files to check for load errors and basic execution.
- For UI or functional tests, add assertions for expected state or output.

## Notes
- These tests run in the virtual environment and do not require REAPER to be open.
- For full integration testing, always do a final check in REAPER itself.
