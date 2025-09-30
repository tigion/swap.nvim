local swap_cases = require('swap.cases')

local M = {}

---The test suite name.
---@type string
M.name = 'swap.cases'

---Describes the test cases.
---@type testCases
M.test_cases = {
  -- Tests the switch to the given case type.
  {
    id = 'tc01',
    name = 'get_results()',
    func = swap_cases.get_results,
    values = {
      -- Should find and not switch to snake_case.
      {
        input = { 'foo_bar', { row = 1, col = 0 }, true, 'snake' },
        expected = {},
      },
      -- Should find and switch to SCREAMING_SNAKE_CASE.
      {
        input = { 'foo_bar', { row = 1, col = 0 }, true, 'screaming_snake' },
        expected = {
          { str = 'foo_bar', new_str = 'FOO_BAR', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'cases' },
        },
      },
      -- Should find and switch to kebab-case.
      {
        input = { 'foo_bar', { row = 1, col = 0 }, true, 'kebab' },
        expected = {
          { str = 'foo_bar', new_str = 'foo-bar', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'cases' },
        },
      },
      -- Should find and switch to SCREAMING-KEBAB-CASE.
      {
        input = { 'foo_bar', { row = 1, col = 0 }, true, 'screaming_kebab' },
        expected = {
          { str = 'foo_bar', new_str = 'FOO-BAR', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'cases' },
        },
      },
      -- Should find and switch to camelCase.
      {
        input = { 'foo_bar', { row = 1, col = 0 }, true, 'camel' },
        expected = {
          { str = 'foo_bar', new_str = 'fooBar', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'cases' },
        },
      },
      -- Sould find and switch to PascalCase.
      {
        input = { 'foo_bar', { row = 1, col = 0 }, true, 'pascal' },
        expected = {
          { str = 'foo_bar', new_str = 'FooBar', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'cases' },
        },
      },
    },
  },
  -- Tests the switch to the next case type.
  {
    id = 'tc02',
    name = 'get_results()',
    func = swap_cases.get_results,
    values = {
      -- Should find and switch to next case type SCREAMING_SNAKE_CASE.
      {
        input = { 'foo_bar', { row = 1, col = 0 }, true },
        expected = {
          { str = 'foo_bar', new_str = 'FOO_BAR', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'cases' },
        },
      },
      -- Should find and switch to next case type kebab-case.
      {
        input = { 'FOO_BAR', { row = 1, col = 0 }, true },
        expected = {
          { str = 'FOO_BAR', new_str = 'foo-bar', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'cases' },
        },
      },
      -- Should find and switch to next case type SCREAMING-KEBAB-CASE.
      {
        input = { 'foo-bar', { row = 1, col = 0 }, true },
        expected = {
          { str = 'foo-bar', new_str = 'FOO-BAR', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'cases' },
        },
      },
      -- Should find and switch to next case type camelCase.
      {
        input = { 'FOO-BAR', { row = 1, col = 0 }, true },
        expected = {
          { str = 'FOO-BAR', new_str = 'fooBar', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'cases' },
        },
      },
      -- Should find and switch to next case type PascalCase.
      {
        input = { 'fooBar', { row = 1, col = 0 }, true },
        expected = {
          { str = 'fooBar', new_str = 'FooBar', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'cases' },
        },
      },
      -- Should find and switch to next case type snake_case.
      {
        input = { 'FooBar', { row = 1, col = 0 }, true },
        expected = {
          { str = 'FooBar', new_str = 'foo_bar', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'cases' },
        },
      },
    },
  },
  -- Tests the detection of supported case types.
  {
    id = 'tc03',
    name = 'get_results()',
    func = swap_cases.get_results,
    values = {
      -- Should find and switch to camelCase.
      {
        input = { 'foo_bar_baz_qux', { row = 1, col = 0 }, true, 'camel' },
        expected = {
          {
            str = 'foo_bar_baz_qux',
            new_str = 'fooBarBazQux',
            start_idx = 1,
            cursor = { row = 1, col = 0 },
            module = 'cases',
          },
        },
      },
      -- Should find and switch to camelCase.
      {
        input = { 'foo1_bar12', { row = 1, col = 0 }, true, 'camel' },
        expected = {
          { str = 'foo1_bar12', new_str = 'foo1Bar12', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'cases' },
        },
      },
      -- Should find and switch to camelCase
      {
        input = { 'f_b', { row = 1, col = 0 }, true, 'camel' },
        expected = {
          { str = 'f_b', new_str = 'fB', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'cases' },
        },
      },
      -- Should find and switch to snake_case.
      {
        input = { 'FooFooFooFoo', { row = 1, col = 5 }, true, 'snake' },
        expected = {
          {
            str = 'FooFooFooFoo',
            new_str = 'foo_foo_foo_foo',
            start_idx = 1,
            cursor = { col = 5, row = 1 },
            module = 'cases',
          },
        },
      },
    },
  },
  -- Tests the detection of case types.
  {
    id = 'tc04',
    name = 'get_results()',
    func = swap_cases.get_results,
    -- All variants should have an empty result.
    values = {
      -- Words must be at least 2 parts long.
      { input = { 'foo', { row = 1, col = 2 }, true, 'camel' } },
      -- No non-letters at the start of inner word parts
      { input = { 'foo_#bar', { row = 1, col = 2 }, true, 'camel' } },
      -- No numbers at the start of word parts.
      { input = { '1foo_bar', { row = 1, col = 2 }, true, 'camel' } },
      { input = { 'foo_1bar', { row = 1, col = 2 }, true, 'camel' } },
      -- No words with unsupported chars (allowed: `a-zA-Z0-9_-`).
      { input = { 'foo#_bar', { row = 1, col = 2 }, true, 'camel' } },
      -- No mixed underscores and hyphens.
      { input = { 'foo_bar-baz', { row = 1, col = 2 }, true, 'camel' } },
      -- No support of abbreviations in capital letters.
      { input = { 'foo_BAR', { row = 1, col = 2 }, true, 'camel' } },
      -- No mixed case types.
      { input = { 'foo_barBaz', { row = 1, col = 2 }, true, 'camel' } },
      -- No unsupported case types.
      { input = { 'foo_baR', { row = 1, col = 2 }, true, 'camel' } },
      { input = { 'fooBarBaz-qux', { row = 1, col = 2 }, true, 'camel' } },
      { input = { 'foo__bar', { row = 1, col = 2 }, true, 'camel' } },
      { input = { 'foo--bar', { row = 1, col = 2 }, true, 'camel' } },

      -- No case type under the cursor.
      {
        --                    c1
        input = { "    name = 'get_results()',", { row = 1, col = 11 }, true, 'camel' },
        --                    |^
      },

      -- Hyphens are only allowed between the word parts. -- TODO: Is this limitation necessary?
      { input = { '-foo-bar', { row = 1, col = 2 }, true, 'camel' } },
      { input = { 'foo_bar--', { row = 1, col = 2 }, true, 'camel' } },
    },
    expected = {},
  },
  -- Tests the switch of underscore prefixed and/or suffixed words to the next case type.
  {
    id = 'tc05',
    name = 'get_results()',
    func = swap_cases.get_results,
    values = {
      -- Should find and switch to next case type SCREAMING_SNAKE_CASE.
      {
        input = { '_foo_bar', { row = 1, col = 0 }, true },
        expected = {
          { str = '_foo_bar', new_str = '_FOO_BAR', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'cases' },
        },
      },
      {
        input = { '__foo_bar', { row = 1, col = 0 }, true },
        expected = {
          { str = '__foo_bar', new_str = '__FOO_BAR', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'cases' },
        },
      },
      {
        input = { 'foo_bar_', { row = 1, col = 0 }, true },
        expected = {
          { str = 'foo_bar_', new_str = 'FOO_BAR_', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'cases' },
        },
      },
      {
        input = { 'foo_bar__', { row = 1, col = 0 }, true },
        expected = {
          { str = 'foo_bar__', new_str = 'FOO_BAR__', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'cases' },
        },
      },
      -- Should find and switch to next case type snake_case.
      {
        input = { '_FooBar_', { row = 1, col = 0 }, true },
        expected = {
          { str = '_FooBar_', new_str = '_foo_bar_', start_idx = 1, cursor = { row = 1, col = 0 }, module = 'cases' },
        },
      },
      {
        input = { '__FooBar__', { row = 1, col = 0 }, true },
        expected = {
          {
            str = '__FooBar__',
            new_str = '__foo_bar__',
            start_idx = 1,
            cursor = { row = 1, col = 0 },
            module = 'cases',
          },
        },
      },
    },
  },
}

return M
