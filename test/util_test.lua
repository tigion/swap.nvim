local swap_util = require('swap.util')

local M = {}

---The test suite name.
---@type string
M.name = 'swap.util'

---Describes the test cases.
---@type testCases
M.test_cases = {
  {
    id = 'tc01',
    name = 'mask.has_uppercase()',
    func = swap_util.mask.has_uppercase,
    values = {
      { input = { 'foo' }, expected = false },
      { input = { 'FOO' }, expected = true },
      { input = { 'Foo' }, expected = true },
      { input = { 'fooBar' }, expected = true },
    },
  },
  {
    id = 'tc02',
    name = 'mask.has_uppercase_words()',
    func = swap_util.mask.has_uppercase_words,
    values = {
      { input = { { 'foo', 'bar' } }, expected = false },
      { input = { { 'foo', 'bAr' } }, expected = true },
      { input = { { 'FOO', 'bar' } }, expected = true },
    },
  },
  {
    id = 'tc03',
    name = 'mask.get_case_sensitive_mask()',
    func = swap_util.mask.get_case_sensitive_mask,
    values = {
      { input = { 'foo' }, expected = false },
      { input = { 'FOO' }, expected = true },
      { input = { 'Foo' }, expected = 'Xxx' },
      { input = { 'fooBar' }, expected = 'xxxXxx' },
      { input = { 'foo Bar' }, expected = 'xxxxXxx' },
      { input = { '#a(A)-12A.a' }, expected = 'xxxXxxxxXxx' },
    },
  },
  {
    id = 'tc04',
    name = 'mask.apply_case_sensitive_mask()',
    func = swap_util.mask.apply_case_sensitive_mask,
    values = {
      { input = { 'foo', false }, expected = 'foo' },
      { input = { 'foo', true }, expected = 'FOO' },
      { input = { 'foo', 'xXx' }, expected = 'fOo' },
      { input = { 'foo bar', 'XxxxXxx' }, expected = 'Foo Bar' },
      { input = { '#a(a)-12a.a', 'xxxXxxxxXxx' }, expected = '#a(A)-12A.a' },
      { input = { '#a(a)-12a.a', true }, expected = '#A(A)-12A.A' },
    },
  },
  {
    id = 'tc05',
    name = 'table.find()',
    func = swap_util.table.find,
    values = {
      { input = { { 'a', 'b', 'c' }, 'a' }, expected = 1 },
      { input = { { 'a', 'b', 'c' }, 'b' }, expected = 2 },
      { input = { { 'a', 'b', 'c' }, 'c' }, expected = 3 },
      { input = { { 'a', 'b', 'c' }, 'd' }, expected = nil },
    },
  },
}

return M
