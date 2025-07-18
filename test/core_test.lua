local swap_core = require('swap.core')

local M = {}

---The test suite name.
---@type string
M.name = 'swap.core'

---Describes the test cases.
---@type testCases
M.test_cases = {
  {
    id = 'tc01',
    name = 'find_str_in_line()',
    func = swap_core.find_str_in_line,
    values = {
      -- Start index of the second `art_id` is found.
      {
        input = {
          --    1                   2 c
          'if start_idx == nil or start_idx > col_idx then break end',
          --    ^                   ^ |
          'art_id',
          { row = 1, col = 27 },
        },
        expected = { 26 },
      },
      -- No start index is found. Cursor is not in any `art_id`.
      {
        input = {
          --    1     c             2
          'if start_idx == nil or start_idx > col_idx then break end',
          --    ^     |             ^
          'art_id',
          { row = 1, col = 11 },
        },
        expected = {},
      },
      -- Start index of the third `foofoo` is found.
      {
        input = {
          --           1  2                                  3  4c
          'Lorem ipsum foofoofoo dolor sit amet, consectetur foofoofoo elit.',
          --           ^  ^                                  ^  ^|
          'foofoo',
          { row = 1, col = 54 },
          { ignore_overlapping_matches = true },
        },
        expected = { 51 },
      },
      -- Start indexes of the third and fourth `foofoo` are found.
      {
        input = {
          --           1  2                                  3  4c
          'Lorem ipsum foofoofoo dolor sit amet, consectetur foofoofoo elit.',
          --           ^  ^                                  ^  ^|
          'foofoo',
          { row = 1, col = 54 },
          { ignore_overlapping_matches = false },
        },
        expected = { 51, 54 },
      },
    },
  },
  {
    id = 'tc02',
    name = 'replace_str_in_current_line()',
    func = function(...) return swap_core.test('replace_str_in_line', ...) end,
    values = {
      {
        input = {
          'Lorem ipsum **Vim** dolor sit amet.',
          {
            str = 'Vim',
            new_str = 'Neovim',
            start_idx = 15,
            cursor = { row = 1, col = 16 },
            module = 'opposites',
          },
        },
        expected = 'Lorem ipsum **Neovim** dolor sit amet.',
      },
      {
        input = {
          '    dev = false,',
          {
            str = 'false',
            new_str = 'true',
            start_idx = 11,
            cursor = { row = 1, col = 12 },
            module = 'opposites',
          },
        },
        expected = '    dev = true,',
      },
    },
  },
}

return M
