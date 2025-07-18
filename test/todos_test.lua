local swap_todos = require('swap.todos')

local M = {}

---The test suite name.
---@type string
M.name = 'swap.todos'

---Describes the test cases.
---@type testCases
M.test_cases = {
  {
    id = 'tc01',
    name = 'get_results()',
    func = swap_todos.get_results,
    values = {
      -- Should find and close an open todo from.
      {
        input = { '- [ ] Some task', { row = 1, col = 9 }, true },
        expected = {
          {
            str = ' ',
            new_str = 'x',
            start_idx = 4,
            cursor = { row = 1, col = 9 },
            module = 'todos',
            opts = { cursor_outside = true },
          },
        },
      },
      -- Should find and open a closed todo from.
      {
        input = { '- [x] Some task', { row = 1, col = 9 }, true },
        expected = {
          {
            str = 'x',
            new_str = ' ',
            start_idx = 4,
            cursor = { row = 1, col = 9 },
            module = 'todos',
            opts = { cursor_outside = true },
          },
        },
      },
      -- Should find and close a sub todo.
      {
        input = { '  - [ ] Some task', { row = 1, col = 11 }, true },
        expected = {
          {
            str = ' ',
            new_str = 'x',
            start_idx = 6,
            cursor = { row = 1, col = 11 },
            module = 'todos',
            opts = { cursor_outside = true },
          },
        },
      },
      -- Should find and close an inline todo.
      {
        input = { '// - [ ] Some task', { row = 1, col = 12 }, true },
        expected = {
          {
            str = ' ',
            new_str = 'x',
            start_idx = 7,
            cursor = { row = 1, col = 12 },
            module = 'todos',
            opts = { cursor_outside = true },
          },
        },
      },
    },
  },
  {
    -- Should not find any valid todos (default syntax).
    id = 'tc02',
    name = 'get_results()',
    func = swap_todos.get_results,
    values = {
      { input = { '-[ ] Some task', { row = 1, col = 0 }, true } },
      { input = { '- [ ]Some task', { row = 1, col = 0 }, true } },
      { input = { '- [] Some task', { row = 1, col = 0 }, true } },
      { input = { '- [x  ] Some task', { row = 1, col = 0 }, true } },
      { input = { '* [ ] Some task', { row = 1, col = 0 }, true } },
      { input = { '-  [ ] Some task', { row = 1, col = 0 }, true } },
      { input = { '- [ ]', { row = 1, col = 0 }, true } },
    },
    expected = {},
  },
}

return M
