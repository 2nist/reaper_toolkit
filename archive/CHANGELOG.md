# Changelog

## v1.1.0 - 2025-06-28

### Added

* **EnviREAment Automation:**
  * `autogen_imgui_api_tests.lua`: Automatically generates a comprehensive test suite for the ReaImGui API from the C++ source code.
  * `parse_imgui_api_test_results.lua`: Parses the results of the test suite runs in both the real and mock environments.
  * `sync_envi_mocks.lua`: Appends missing function stubs to `enhanced_virtual_reaper.lua` based on the test results.
  * `harden_envi_mocks.lua`: Regenerates the `enhanced_virtual_reaper.lua` file, adding type-checking and hardening the mock functions.
* **CI/CD:**
  * Added a GitHub Actions workflow (`.github/workflows/ci.yml`) to automate the entire testing and mock synchronization process.

### Changed

* Updated `EnviREAment/README.md` and the root `README.md` to reflect the new automation features.

## v1.0.0 - 2025-06-25
