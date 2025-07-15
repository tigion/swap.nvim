local swap_validation = require('lua.swap.validation')

-- Hash tables are not ordered, so the order of the key/value pairs
-- is not guaranteed.
--
-- To make the opposites tests tc02 and tc03 deterministic, the smaller
-- key musst come first, because the greater key of redundant pairs
-- will be removed.

local M = {}

---The test suite name.
---@type string
M.name = 'swap.validation'

---Describes the test cases.
---@type testCases
M.test_cases = {
  {
    id = 'tc01',
    name = 'cleanup_modules()',
    func = swap_validation.cleanup_modules,
    values = {
      { input = { { 'opposites', 'cases', 'chains', 'todos' } } },
      { input = { { 'opposites', 'cases', 'chains', 'cases', 'todos' } } },
      { input = { { 'opposites', 'cases', 'chains', 'unsupported', 'todos' } } },
      { input = { { 'opposites', 'cases', 'chains', '', 'todos' } } },
      { input = { { 'opposites', 'cases', 'chains', 'todos', nil } } },
    },
    expected = { 'opposites', 'cases', 'chains', 'todos' },
  },
  {
    id = 'tc02',
    name = 'cleanup_opposite_words()',
    func = swap_validation.cleanup_opposite_words,
    values = {
      { input = { { disable = 'enable', ['=='] = '!=' } } },
      { input = { { ['=='] = '!=', disable = 'enable' } } },
      { input = { { disable = 'enable', enable = 'disable', ['=='] = '!=' } } },
      { input = { { disable = 'enable', yes = 'yes', ['=='] = '!=' } } },
    },
    expected = { disable = 'enable', ['=='] = '!=' },
  },
  {
    id = 'tc03',
    name = 'cleanup_opposite_words_by_ft()',
    func = swap_validation.cleanup_opposite_words_by_ft,
    values = {
      { input = { { lua = { ['=='] = '~=' }, sql = { asc = 'desc' } } } },
      { input = { { lua = { ['=='] = '~=' }, sql = { asc = 'desc', desc = 'asc' } } } },
      { input = { { lua = { ['=='] = '~=' }, sql = { asc = 'desc', foo = 'foo' } } } },
    },
    expected = { ['lua'] = { ['=='] = '~=' }, ['sql'] = { ['asc'] = 'desc' } },
  },
  {
    id = 'tc04',
    name = 'cleanup_words()',
    func = function(...) return swap_validation.test('cleanup_words', ...) end,
    values = {
      { input = { { 'foo', 'bar', 'baz' } } },
      { input = { { 'foo', 'bar', 'foo', 'baz' } } },
      { input = { { 'foo', 'bar', '', 'baz' } } },
      { input = { { 'foo', 'bar', true, 'baz' } } },
    },
    expected = { 'foo', 'bar', 'baz' },
  },
  {
    id = 'tc05',
    name = 'cleanup_word_chains()',
    func = swap_validation.cleanup_word_chains,
    values = {
      { input = { { { 'A', 'B', 'C' }, { 'foo', 'bar', 'baz' } } } },
      { input = { { { 'A', 'B', 'A', 'C' }, { 'foo', 'bar', 'foo', 'baz' } } } },
      { input = { { { 'A', 'B', '', 'C' }, { 'foo', 'bar', '', 'baz' } } } },
      { input = { { { 'A', 'B', true, 'C' }, { 'foo', 'bar', 1, 'baz' } } } },
    },
    expected = { { 'A', 'B', 'C' }, { 'foo', 'bar', 'baz' } },
  },
  {
    id = 'tc06',
    name = 'cleanup_word_chains_by_ft()',
    func = swap_validation.cleanup_word_chains_by_ft,
    values = {
      {
        input = {
          {
            lua = { { 'A', 'B', 'C' }, { 'foo', 'bar', 'baz' } },
            sql = { { 'A', 'B', 'C' }, { 'foo', 'bar', 'baz' } },
          },
        },
      },
      {
        input = {
          {
            lua = { { 'A', 'B', 'A', 'C' }, { 'foo', 'bar', 'foo', 'baz' } },
            sql = { { 'A', 'B', 'A', 'C' }, { 'foo', 'bar', 'foo', 'baz' } },
          },
        },
      },
      {
        input = {
          {
            lua = { { 'A', 'B', '', 'C' }, { 'foo', 'bar', '', 'baz' } },
            sql = { { 'A', 'B', '', 'C' }, { 'foo', 'bar', '', 'baz' } },
          },
        },
      },
      {
        input = {
          {
            lua = { { 'A', 'B', true, 'C' }, { 'foo', 'bar', 1, 'baz' } },
            sql = { { 'A', 'B', true, 'C' }, { 'foo', 'bar', 1, 'baz' } },
          },
        },
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
    func = swap_validation.cleanup_case_types,
    values = {
      { input = { { 'snake', 'screaming_snake', 'kebab', 'screaming_kebab', 'camel', 'pascal' } } },
      { input = { { 'snake', 'screaming_snake', 'kebab', 'screaming_kebab', 'unsupported', 'camel', 'pascal' } } },
      { input = { { 'snake', 'screaming_snake', 'kebab', 'screaming_kebab', '', 'camel', 'pascal' } } },
      { input = { { 'snake', 'screaming_snake', 'kebab', 'screaming_kebab', false, 11, 'camel', 'pascal' } } },
    },
    expected = { 'snake', 'screaming_snake', 'kebab', 'screaming_kebab', 'camel', 'pascal' },
  },
}

return M
