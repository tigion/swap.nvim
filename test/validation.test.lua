-- Unit tests for lua/swap/validation.lua.
--
-- Run with `nvim -l test/validation.test.lua`.
--
-- The private functions need a test interface or musst be exposed.
--
-- NOTE: Hash tables are not ordered, so the order of the key/value pairs
--       is not guaranteed.
--       To make the opposites tests tc02 and tc03 deterministic, the smaller
--       key musst come first, because the greater key of redundant pairs
--       will be removed.
--

_SWAP_NVIM_UNIT_TEST = true
_SWAP_NVIM_UNIT_TEST_OPTS = {
  verbose = false,
}

local validation = require('lua.swap.validation')
-- validation._prepare_unit_test()

---Defines the test cases.
local test_cases = {
  {
    id = 'tc01',
    name = 'cleanup_modules()',
    func = validation.cleanup_modules,
    inputs = {
      { 'opposites', 'cases', 'chains', 'todos' },
      { 'opposites', 'cases', 'chains', 'cases', 'todos' },
      { 'opposites', 'cases', 'chains', 'unsupported', 'todos' },
      { 'opposites', 'cases', 'chains', '', 'todos' },
      { 'opposites', 'cases', 'chains', 'todos', nil },
    },
    expected = { 'opposites', 'cases', 'chains', 'todos' },
  },
  {
    id = 'tc02',
    name = 'cleanup_opposite_words()',
    func = validation.cleanup_opposite_words,
    inputs = {
      { ['disable'] = 'enable', ['=='] = '!=' },
      { ['=='] = '!=', ['disable'] = 'enable' },
      { ['disable'] = 'enable', ['enable'] = 'disable', ['=='] = '!=' },
      { ['disable'] = 'enable', ['yes'] = 'yes', ['=='] = '!=' },
    },
    expected = { ['disable'] = 'enable', ['=='] = '!=' },
  },
  {
    id = 'tc03',
    name = 'cleanup_opposite_words_by_ft()',
    func = validation.cleanup_opposite_words_by_ft,
    inputs = {
      { ['lua'] = { ['=='] = '~=' }, ['sql'] = { ['asc'] = 'desc' } },
      { ['lua'] = { ['=='] = '~=' }, ['sql'] = { ['asc'] = 'desc', ['desc'] = 'asc' } },
      { ['lua'] = { ['=='] = '~=' }, ['sql'] = { ['asc'] = 'desc', ['foo'] = 'foo' } },
    },
    expected = {
      ['lua'] = { ['=='] = '~=' },
      ['sql'] = { ['asc'] = 'desc' },
    },
  },
  {
    id = 'tc04',
    name = 'cleanup_words()',
    func = 'cleanup_words',
    inputs = {
      { 'foo', 'bar', 'baz' },
      { 'foo', 'bar', 'foo', 'baz' },
      { 'foo', 'bar', '', 'baz' },
      { 'foo', 'bar', 1, 'baz' },
    },
    expected = { 'foo', 'bar', 'baz' },
  },
  {
    id = 'tc05',
    name = 'cleanup_word_chains()',
    func = validation.cleanup_word_chains,
    inputs = {
      { { 'A', 'B', 'C' }, { 'foo', 'bar', 'baz' } },
      { { 'A', 'B', 'A', 'C' }, { 'foo', 'bar', 'foo', 'baz' } },
      { { 'A', 'B', '', 'C' }, { 'foo', 'bar', '', 'baz' } },
      { { 'A', 'B', true, 'C' }, { 'foo', 'bar', 1, 'baz' } },
    },
    expected = { { 'A', 'B', 'C' }, { 'foo', 'bar', 'baz' } },
  },
  {
    id = 'tc06',
    name = 'cleanup_word_chains_by_ft()',
    func = validation.cleanup_word_chains_by_ft,
    inputs = {
      {
        lua = { { 'A', 'B', 'C' }, { 'foo', 'bar', 'baz' } },
        sql = { { 'A', 'B', 'C' }, { 'foo', 'bar', 'baz' } },
      },
      {
        lua = { { 'A', 'B', 'A', 'C' }, { 'foo', 'bar', 'foo', 'baz' } },
        sql = { { 'A', 'B', 'A', 'C' }, { 'foo', 'bar', 'foo', 'baz' } },
      },
      {
        lua = { { 'A', 'B', '', 'C' }, { 'foo', 'bar', '', 'baz' } },
        sql = { { 'A', 'B', '', 'C' }, { 'foo', 'bar', '', 'baz' } },
      },
      {
        lua = { { 'A', 'B', true, 'C' }, { 'foo', 'bar', 1, 'baz' } },
        sql = { { 'A', 'B', true, 'C' }, { 'foo', 'bar', 1, 'baz' } },
      },
    },
    expected = {
      lua = { { 'A', 'B', 'C' }, { 'foo', 'bar', 'baz' } },
      sql = { { 'A', 'B', 'C' }, { 'foo', 'bar', 'baz' } },
    },
  },
  {
    id = 'tc07',
    name = 'cleanup_case_types()',
    func = validation.cleanup_case_types,
    inputs = {
      { 'snake', 'screaming_snake', 'kebab', 'screaming_kebab', 'camel', 'pascal' },
      { 'snake', 'screaming_snake', 'kebab', 'screaming_kebab', 'unsupported', 'camel', 'pascal' },
      { 'snake', 'screaming_snake', 'kebab', 'screaming_kebab', '', 'camel', 'pascal' },
      { 'snake', 'screaming_snake', 'kebab', 'screaming_kebab', false, 11, 'camel', 'pascal' },
    },
    expected = { 'snake', 'screaming_snake', 'kebab', 'screaming_kebab', 'camel', 'pascal' },
  },
}

---Creates a string with the result of a test case variant.
---@param test_case_id string
---@param variant_id number
---@param result boolean
---@param expected table
---@param received table
---@param input table
---@return string
local function get_result_string(test_case_id, variant_id, result, expected, received, input)
  local id = test_case_id .. '.' .. variant_id
  local icon = result == true and '✅' or '❌'
  local str = '- ' .. id .. ': ' .. icon .. ' ' .. tostring(result) .. '\n'

  if result == false then
    str = str .. '\n'
    str = str .. '  expected: ' .. string.gsub(vim.inspect(expected), '\n[ ]*', ' ') .. '\n'
    str = str .. '  received: ' .. string.gsub(vim.inspect(received), '\n[ ]*', ' ') .. '\n'
    str = str .. '  input   : ' .. string.gsub(vim.inspect(input), '\n[ ]*', ' ') .. '\n'
    str = str .. '\n'
  end

  return str
end

---Runs the defined test cases.
---Exits with exit code `0` if all tests passed, or `1` if any test failed.
local function run(title)
  local test_case_count = #test_cases
  local test_variant_count = 0
  local passed_count = 0
  local failed_count = 0

  print("\nTesting '" .. title .. "'")

  -- Runs test cases.
  for _, test_case in ipairs(test_cases) do
    local test_case_failed = false
    local result_str = '\n' .. test_case.id .. ': ' .. test_case.name .. '\n'
    -- Runs test case variants.
    for idx, input in ipairs(test_case.inputs) do
      test_variant_count = test_variant_count + 1

      local received = nil
      if type(test_case.func) == 'function' then
        received = test_case.func(vim.deepcopy(input))
      elseif type(test_case.func) == 'string' then
        received = validation.test(test_case.func, vim.deepcopy(input))
      end

      local result = vim.deep_equal(received, test_case.expected)
      if result == true then
        passed_count = passed_count + 1
      else
        if test_case_failed == false then test_case_failed = true end
        failed_count = failed_count + 1
      end
      if _SWAP_NVIM_UNIT_TEST_OPTS.verbose == true or result == false then
        result_str = result_str .. get_result_string(test_case.id, idx, result, test_case.expected, received, input)
      end
    end
    if _SWAP_NVIM_UNIT_TEST_OPTS.verbose == true or test_case_failed == true then print(result_str) end
  end

  -- Show test statistics.
  print('\nTest cases: ' .. test_case_count .. ' (' .. test_variant_count .. ' variants)')
  print(
    'Tests:      '
      .. (failed_count > 0 and failed_count .. ' failed, ' or '')
      .. (passed_count > 0 and passed_count .. ' passed, ' or '')
      .. test_variant_count
      .. ' total'
  )

  -- Shows final test result and exits with appropriate exit code.
  if failed_count == 0 then
    print('\n✅ Tests passed!')
    os.exit(0)
  else
    print('\n❌ Tests failed!')
    os.exit(1)
  end
end

-- Runs tests.
run('lua.swap.validation')
