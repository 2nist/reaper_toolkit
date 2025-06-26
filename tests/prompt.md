# Prompt Examples for DevToolbox Testing and CI

## Function Prompt Example

> "Add a new tool module called `my_tool` with a `draw` function that displays a button and logs a message when clicked. Also, create a test file that asserts the tool loads and the draw function runs without error."

## Terminal Input Example for Running All Tests

```sh
lua EnviREAment/enviREAment_core_lib/enhanced_virtual_reaper.lua --test tests/run_all_tests.lua
```

## Terminal Input Example for Running a Single Test

```sh
lua EnviREAment/enviREAment_core_lib/enhanced_virtual_reaper.lua --test tests/test_template_tool.lua
```

## CI Integration Example (GitHub Actions)

```yaml
- name: Run DevToolbox Tests
  run: lua EnviREAment/enviREAment_core_lib/enhanced_virtual_reaper.lua --test tests/run_all_tests.lua
```

## Error Handling Prompt Example

> "Test failed: test_template_tool.lua
> Error: ...
> Remedy:
>   - Review the error message above.
>   - Open tests/test_template_tool.lua and the related module.
>   - Fix the code or test as needed.
>   - Re-run the tests to confirm the fix."

---
Use these prompts and examples to guide development, testing, and CI integration for DevToolbox and future modules.
