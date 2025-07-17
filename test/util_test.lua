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
