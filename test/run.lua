-- Run with `nvim -l test/run.lua`.

local util = require('test.util')

-- The test runner options.
local options = {
  verbose = false,
}

-- The test suits to be tested.
local test_suites = {
  require('test.validation_test'),
  require('test.util_test'),
}

---The global test statistics.
---@type testStats
local stats = {
  test_suites = {
    count = #test_suites,
    passed = 0,
    failed = 0,
  },
  test_cases = {
    count = 0,
    passed = 0,
    failed = 0,
  },
  variants = 0,
  passed = 0,
  failed = 0,
}

-- Runs the test suits.
print('\nRunning test...\n\n')
for _, test_suite in ipairs(test_suites) do
  local result, test_suite_stats = util.run(test_suite.name, test_suite.test_cases, options)
  if options.verbose == true or test_suite_stats.failed > 0 then util.show_test_suite_stats(test_suite_stats) end
  if result == false then
    stats.test_suites.failed = stats.test_suites.failed + 1
  else
    stats.test_suites.passed = stats.test_suites.passed + 1
  end
  util.append_stats(stats, test_suite_stats)
end

-- Shows the global test statistics.
util.show_test_suite_stats(stats)

-- Shows final test result.
-- Exits with exit code `0` if all tests passed, or `1` if any test failed.
if stats.failed == 0 then
  print('✅ Tests passed!')
  os.exit(0)
else
  print('❌ Tests failed!')
  os.exit(1)
end
