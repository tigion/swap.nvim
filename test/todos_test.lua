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
        input = { '- [ ] Some task', { col = 9, row = 1 }, true },
        expected = {
          {
            str = ' ',
            new_str = 'x',
            start_idx = 4,
            cursor = { col = 9, row = 1 },
            module = 'todos',
            opts = { cursor_outside = true },
          },
        },
      },
      -- Should find and open a closed todo from.
      {
        input = { '- [x] Some task', { col = 9, row = 1 }, true },
        expected = {
          {
            str = 'x',
            new_str = ' ',
            start_idx = 4,
            cursor = { col = 9, row = 1 },
            module = 'todos',
            opts = { cursor_outside = true },
          },
        },
      },
      -- Should find and close a sub todo.
      {
        input = { '  - [ ] Some task', { col = 11, row = 1 }, true },
        expected = {
          {
            str = ' ',
            new_str = 'x',
            start_idx = 6,
            cursor = { col = 11, row = 1 },
            module = 'todos',
            opts = { cursor_outside = true },
          },
        },
      },
      -- Should find and close an inline todo.
      {
        input = { '// - [ ] Some task', { col = 12, row = 1 }, true },
        expected = {
          {
            str = ' ',
            new_str = 'x',
            start_idx = 7,
            cursor = { col = 12, row = 1 },
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
      { input = { '-[ ] Some task', { col = 0, row = 1 }, true } },
      { input = { '- [ ]Some task', { col = 0, row = 1 }, true } },
      { input = { '- [] Some task', { col = 0, row = 1 }, true } },
      { input = { '- [x  ] Some task', { col = 0, row = 1 }, true } },
      { input = { '* [ ] Some task', { col = 0, row = 1 }, true } },
      { input = { '-  [ ] Some task', { col = 0, row = 1 }, true } },
      { input = { '- [ ]', { col = 0, row = 1 }, true } },
    },
    expected = {},
  },
}

return M
