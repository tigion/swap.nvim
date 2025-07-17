-- Adds the `lua` directory to the package path to find the
-- plugin modules from the root directory of the project.
package.path = './lua/?.lua;' .. './lua/?/init.lua;' .. package.path

local M = {}

---@class testCaseValue
---@field input table
---@field expected? any

---@alias testCaseValues testCaseValue[]

---@class testCase
---@field id string
---@field name string
---@field func function
---@field expected? any
---@field values testCaseValues

---@alias testCases testCase[]

---@class testCasesStats
---@field count number
---@field passed number
---@field failed number

---@class testSuiteStats
---@field test_cases testCasesStats
---@field variants number
---@field passed number
---@field failed number

---@class testSuitesStats
---@field count number
---@field passed number
---@field failed number

---@class testStats
---@field test_suites testSuitesStats
---@field test_cases testCasesStats
---@field variants number
---@field passed number
---@field failed number

---Returns a string with the result of a test case variant.
---@param test_case_id string
---@param variant_id number
---@param result boolean
---@param expected any
---@param received any
---@param input table
---@return string
local function get_result_string(test_case_id, variant_id, result, expected, received, input)
  local id = test_case_id .. '.' .. variant_id
  local icon = result == true and '✅' or '❌'
  local str = '- ' .. id .. ': ' .. icon .. ' ' .. (result == true and 'passed' or 'failed') .. '\n'

  if result == false then
    str = str .. '\n'
    str = str .. '  expected: ' .. string.gsub(vim.inspect(expected), '\n[ ]*', ' ') .. '\n'
    str = str .. '  received: ' .. string.gsub(vim.inspect(received), '\n[ ]*', ' ') .. '\n'
    str = str .. '  input   : ' .. string.gsub(vim.inspect(input), '\n[ ]*', ' ') .. '\n'
    str = str .. '\n'
  end

  return str
end

---Runs the defined test cases of the test suite.
---@param title string
---@param test_cases testCases
---@param opts? table
---@return boolean, testSuiteStats
local function run_test_suite(title, test_cases, opts)
  opts = opts or {}

  ---@type testSuiteStats
  local stats = {
    test_cases = {
      count = #test_cases,
      passed = 0,
      failed = 0,
    },
    variants = 0,
    passed = 0,
    failed = 0,
  }

  print("Test suite: '" .. title .. "'")

  -- Runs the test cases.
  for _, test_case in ipairs(test_cases) do
    local test_case_failed = false
    local result_str = '\n' .. test_case.id .. ': ' .. test_case.name .. '\n'
    -- Runs the test case variants.
    for idx, value in ipairs(test_case.values) do
      stats.variants = stats.variants + 1

      -- NOTE: Neovim uses Lua 5.1, so `table.[un]pack()` is not available.
      --       - Lua 5.1: `[un]pack()`, `table.[un]pack()` is not available.
      --       - Lua 5.2: `table.[un]pack()`, `[un]pack()` is deprecated.
      table.unpack = table.unpack or unpack -- FIX: 5.1 compatibility

      -- Calls the test case function.
      local received = test_case.func(table.unpack(vim.deepcopy(value.input)))

      -- Sets the expected value.
      local expected = nil
      if value.expected ~= nil then
        expected = value.expected
      elseif test_case.expected ~= nil then
        expected = test_case.expected
      end

      -- Asserts equality.
      local result = vim.deep_equal(received, expected)

      -- Updates the test suite statistics.
      if result == true then
        stats.passed = stats.passed + 1
      else
        if test_case_failed == false then test_case_failed = true end
        stats.failed = stats.failed + 1
      end

      -- Add the test case variant result to the result string.
      if opts.verbose == true or result == false then
        result_str = result_str .. get_result_string(test_case.id, idx, result, value.expected, received, value.input)
      end
    end
    -- Updates the test cases statistics.
    if test_case_failed == true then
      stats.test_cases.failed = stats.test_cases.failed + 1
    else
      stats.test_cases.passed = stats.test_cases.passed + 1
    end

    -- Prints the test case result.
    if opts.verbose == true or test_case_failed == true then print(result_str) end
  end

  local result = stats.failed == 0 and true or false
  return result, stats
end

---Adds the statistics of the test suite to the global statistics.
---@param stats testStats
---@param test_suite_stats testSuiteStats
local function append_stats(stats, test_suite_stats)
  stats.test_cases.count = stats.test_cases.count + test_suite_stats.test_cases.count
  stats.test_cases.passed = stats.test_cases.passed + test_suite_stats.test_cases.passed
  stats.test_cases.failed = stats.test_cases.failed + test_suite_stats.test_cases.failed
  stats.variants = stats.variants + test_suite_stats.variants
  stats.passed = stats.passed + test_suite_stats.passed
  stats.failed = stats.failed + test_suite_stats.failed
end

---Prints a line with the maximum length of the lines.
---@param str string
---@param line_char? string
local function print_line(str, line_char)
  line_char = line_char or '-'
  local max_len = 0
  for _, line in ipairs(vim.split(str, '\n')) do
    max_len = #line > max_len and #line or max_len
  end
  print(string.rep(line_char, max_len))
end

---Prints the global test statistics.
---@param stats testStats|testSuiteStats
local function show_test_suite_stats(stats)
  local str = ''
  local line_char = '-'
  if stats.test_suites ~= nil then
    line_char = '='
    str = str
      .. 'Test suites: '
      .. (stats.test_suites.failed > 0 and stats.test_suites.failed .. ' failed, ' or '')
      .. (stats.test_suites.passed > 0 and stats.test_suites.passed .. ' passed, ' or '')
      .. stats.test_suites.count
      .. ' total'
      .. '\n'
  end
  str = str
    .. 'Test cases:  '
    .. (stats.test_cases.failed > 0 and stats.test_cases.failed .. ' failed, ' or '')
    .. (stats.test_cases.passed > 0 and stats.test_cases.passed .. ' passed, ' or '')
    .. stats.test_cases.count
    .. ' total'
    .. '\n'
  str = str
    .. 'Tests:       '
    .. (stats.failed > 0 and stats.failed .. ' failed, ' or '')
    .. (stats.passed > 0 and stats.passed .. ' passed, ' or '')
    .. stats.variants
    .. ' total'
    .. '\n'
  print('\n')
  print_line(str, line_char)
  print(str)
  print_line(str, line_char)
  print('\n')
end

---Runs the given test suits and exits with an exit code.
-- - `0` if all tests passed
-- - `1` if any test failed
---@param test_suite_names table
---@param opts? table
function M.run(test_suite_names, opts)
  opts = opts or {}

  if #test_suite_names < 1 then
    print('\nNo test suites to run!')
    return
  end

  local test_suites = {}
  for _, test_suite_name in ipairs(test_suite_names) do
    table.insert(test_suites, require('test.' .. test_suite_name))
  end

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

  print('\nRunning tests...\n\n')

  for _, test_suite in ipairs(test_suites) do
    local result, test_suite_stats = run_test_suite(test_suite.name, test_suite.test_cases, opts)
    if opts.verbose == true or test_suite_stats.failed > 0 then show_test_suite_stats(test_suite_stats) end
    if result == false then
      stats.test_suites.failed = stats.test_suites.failed + 1
    else
      stats.test_suites.passed = stats.test_suites.passed + 1
    end
    append_stats(stats, test_suite_stats)
  end

  -- Shows the global test statistics.
  show_test_suite_stats(stats)

  -- Shows the final test result and exits with exit code.
  if stats.failed == 0 then
    print('✅ Tests passed!')
    os.exit(0)
  else
    print('❌ Tests failed!')
    os.exit(1)
  end
end

return M
