# Advanced Automation for DevToolbox Testing

This project uses a robust, automated test runner with the following features:

## Features

- **Linting:** Runs `luacheck` on all Lua files before tests. Lint results are saved to `tests/luacheck.log`.
- **Code Coverage:** Enables `luacov` for coverage reporting. Coverage summary is printed after tests and full report is in `.luacov/report.out`.
- **Log Archiving:** All test output is saved to `tests/test-output.log` for CI artifact upload or later review.
- **Fail Fast & Retry:** Supports stopping on first failure (`FAIL_FAST=1`) and retrying flaky tests (`RETRY_COUNT=2`).
- **Automatic Test Stub Generation:** Creates basic test files for new modules if missing, ensuring every module is tested.
- **Coverage Summary:** Prints a summary from `.luacov/report.out` if available.

## Running All Tests

```sh
lua EnviREAment/enviREAment_core_lib/enhanced_virtual_reaper.lua --test tests/run_all_tests.lua
```

## Environment Variables

- `FAIL_FAST=1` — Stop on first test failure.
- `RETRY_COUNT=2` — Retry each test up to 2 times if it fails.

## CI Integration Example (GitHub Actions)

```yaml
- name: Lint Lua code
  run: luacheck .

- name: Run all DevToolbox tests
  run: lua EnviREAment/enviREAment_core_lib/enhanced_virtual_reaper.lua --test tests/run_all_tests.lua

- name: Upload test logs
  uses: actions/upload-artifact@v2
  with:
    name: test-logs
    path: tests/test-output.log

- name: Upload coverage report
  uses: actions/upload-artifact@v2
  with:
    name: coverage-report
    path: .luacov/report.out
```

## Adding New Modules

- Place new Lua modules in the `modules/` directory.
- The test runner will auto-generate a `test_<module>.lua` if missing.
- Add more detailed assertions to the generated test as needed.

## Reviewing Results

- Lint results: `tests/luacheck.log`
- Test log: `tests/test-output.log`
- Coverage report: `.luacov/report.out`

## Troubleshooting

- If a test fails, review the error and remedy steps in the test log.
- Fix the code or test, then re-run the test suite.
- For coverage, ensure `luacov` is installed and configured.

---

This automation ensures high code quality, fast feedback, and easy CI integration for DevToolbox development.
