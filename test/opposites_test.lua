local swap_opposites = require('swap.opposites')

local M = {}

---The test suite name.
---@type string
M.name = 'swap.opposites'

---Describes the test cases.
---@type testCases
M.test_cases = {
  {
    id = 'tc01',
    name = 'get_results()',
    func = swap_opposites.get_results,
    values = {
      -- Cursor in word `disable` found `enable`.
      {
        input = { 'disable', { col = 0, row = 1 }, true },
        expected = {
          {
            str = 'disable',
            new_str = 'enable',
            start_idx = 1,
            cursor = { col = 0, row = 1 },
            module = 'opposites',
            opts = {},
          },
        },
      },
      -- Cursor not in word `disable` found nothing.
      {
        input = { 'disable', { col = 8, row = 1 }, true },
        expected = {},
      },
      -- Word `unknown` not in config found nothing.
      {
        input = { 'unknown', { col = 0, row = 1 }, true },
        expected = {},
      },
      -- Cursor on `<` in word `<=` found `>` and `>=`.
      {
        input = { '<=', { col = 0, row = 1 }, true },
        expected = {
          {
            str = '<',
            new_str = '>',
            start_idx = 1,
            cursor = { col = 0, row = 1 },
            module = 'opposites',
            opts = {},
          },
          {
            str = '<=',
            new_str = '>=',
            start_idx = 1,
            cursor = { col = 0, row = 1 },
            module = 'opposites',
            opts = {},
          },
        },
      },
    },
  },
}

return M
