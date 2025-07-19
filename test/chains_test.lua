local swap_chains = require('swap.chains')

local M = {}

---The test suite name.
---@type string
M.name = 'swap.chains'

---Describes the test cases.
---@type testCases
M.test_cases = {
  -- Should find and switch to next word in chain.
  {
    id = 'tc01',
    name = 'get_results()',
    func = swap_chains.get_results,
    values = {
      {
        input = { 'foo', { row = 1, col = 0 }, true },
        expected = {
          { str = 'foo', new_str = 'bar', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'chains', opts = {} },
        },
      },
      {
        input = { 'bar', { row = 1, col = 0 }, true },
        expected = {
          { str = 'bar', new_str = 'baz', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'chains', opts = {} },
        },
      },
      {
        input = { 'baz', { row = 1, col = 0 }, true },
        expected = {
          { str = 'baz', new_str = 'qux', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'chains', opts = {} },
        },
      },
      {
        input = { 'qux', { row = 1, col = 0 }, true },
        expected = {
          { str = 'qux', new_str = 'foo', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'chains', opts = {} },
        },
      },
      {
        input = { 'xxfooxx', { row = 1, col = 3 }, true },
        expected = {
          { str = 'foo', new_str = 'bar', start_idx = 3, cursor = { row = 1, col = 3 }, module = 'chains', opts = {} },
        },
      },
    },
  },
  -- Should find nothing and have an empty result.
  {
    id = 'tc02',
    name = 'get_results()',
    func = swap_chains.get_results,
    values = {
      { input = { 'unsupported', { row = 1, col = 0 }, true } },
      { input = { 'Lorem foo ipsum.', { row = 1, col = 0 }, true } },
    },
    expected = {},
  },
}

return M
