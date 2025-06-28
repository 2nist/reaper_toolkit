_TEST_ENV = true

-- Advanced Automation: Linting, Coverage, Log Archiving, Fail Fast, Retry, Test Stub Generation
local lfs = require('lfs')
local test_dir = './tests'
local test_files = {}
local fail_fast = os.getenv('FAIL_FAST') == '1' -- Set FAIL_FAST=1 in CI to stop on first failure
local retry_count = tonumber(os.getenv('RETRY_COUNT')) or 0 -- Set RETRY_COUNT=2 to retry flaky tests
local log_file = test_dir .. '/test-output.log'
local log_fh = io.open(log_file, 'w')

-- 1. Linting (luacheck)
print('--- Linting with luacheck ---')
local lint_ok = os.execute('luacheck . > ' .. test_dir .. '/luacheck.log 2>&1')
if lint_ok ~= 0 then
  print('LINT FAIL: See tests/luacheck.log for details.')
  if log_fh then log_fh:write('LINT FAIL: See tests/luacheck.log for details.\n') end
else
  print('LINT PASS')
  if log_fh then log_fh:write('LINT PASS\n') end
end

-- 2. Code Coverage (luacov)
print('--- Enabling code coverage (luacov) ---')
pcall(require, 'luacov')

-- 3. Collect all test_*.lua files except this runner
for file in lfs.dir(test_dir) do
  if file:match('^test_.*%.lua$') and file ~= 'run_all_tests.lua' and file ~= 'test_module_template.lua' then
    table.insert(test_files, file)
  end
end
table.sort(test_files)

local results = {}
local failures = 0

for _, file in ipairs(test_files) do
  print('--- Running', file, '---')
  if log_fh then log_fh:write('--- Running ' .. file .. ' ---\n') end
  local ok, err
  for attempt = 1, retry_count + 1 do
    ok, err = pcall(dofile, test_dir .. '/' .. file)
    if ok then break end
    print('  Attempt ' .. attempt .. ' failed.')
    if log_fh then log_fh:write('  Attempt ' .. attempt .. ' failed.\n') end
  end
  if ok then
    print('PASS:', file)
    if log_fh then log_fh:write('PASS: ' .. file .. '\n') end
    table.insert(results, {file=file, status='PASS'})
  else
    print('FAIL:', file)
    print('  Error: ' .. tostring(err))
    print('  Remedy:')
    print('    - Review the error message above.')
    print('    - Open ' .. test_dir .. '/' .. file .. ' and the related module.')
    print('    - Fix the code or test as needed.')
    print('    - Re-run the tests to confirm the fix.')
    print('    - If unsure, ask for help or consult the documentation.')
    if log_fh then log_fh:write('FAIL: ' .. file .. '\n  Error: ' .. tostring(err) .. '\n') end
    table.insert(results, {file=file, status='FAIL', error=err})
    failures = failures + 1
    if fail_fast then break end
  end
end

if log_fh then log_fh:write('\n=== Test Summary ===\n') end
print('\n=== Test Summary ===')
for _, r in ipairs(results) do
  print(r.status, r.file, r.error or '')
  if log_fh then log_fh:write(r.status .. ' ' .. r.file .. (r.error and (' ' .. r.error) or '') .. '\n') end
end
if failures == 0 then
  print('All tests passed!')
  print('You are ready to commit or deploy!')
  if log_fh then log_fh:write('All tests passed!\n') end
else
  print(failures .. ' test(s) failed.')
  print('Please address the failures above before merging or deploying.')
  if log_fh then log_fh:write(failures .. ' test(s) failed.\n') end
end

if log_fh then log_fh:close() end

-- 4. Archive logs and coverage (for CI)
print('Test log archived at ' .. log_file)
print('If using CI, upload ' .. log_file .. ' and .luacov/report.out as artifacts.')

-- 5. Automatic test stub generation for new modules
local modules_dir = './modules'
for file in lfs.dir(modules_dir) do
  if file:match('%.lua$') and not file:match('^init') then
    local test_name = 'test_' .. file:gsub('%.lua$', '') .. '.lua'
    local test_path = test_dir .. '/' .. test_name
    local fh = io.open(test_path, 'r')
    if not fh then
      print('Auto-generating test stub for ' .. file)
      local stub = '-- Auto-generated test for ' .. file .. '\n' ..
        'local mod = dofile("' .. modules_dir .. '/' .. file .. '")\n' ..
        'assert(type(mod) == "table", "Module should return a table")\n' ..
        'print("' .. file .. ' basic load test passed.")\n'
      local out = io.open(test_path, 'w')
      if out then
        out:write(stub)
        out:close()
      end
    else
      fh:close()
    end
  end
end

-- 6. Print coverage summary if available
local cov_fh = io.open('.luacov/report.out', 'r')
if cov_fh then
  print('\n--- Coverage Report (summary) ---')
  for line in cov_fh:lines() do
    print(line)
    if line:find('Summary') then break end
  end
  cov_fh:close()
else
  print('No coverage report found. Install luacov for coverage info.')
end

print('\n--- CI Integration Example ---')
print('To integrate with CI, add the following steps to your workflow:')
print('  luacheck .')
print('  lua EnviREAment/enviREAment_core_lib/enhanced_virtual_reaper.lua --test tests/run_all_tests.lua')
print('  # Optionally, upload tests/test-output.log and .luacov/report.out as artifacts')
