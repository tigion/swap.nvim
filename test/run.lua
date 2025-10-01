-- Run with `nvim -l test/run.lua` from the root directory
-- of this project.

local test = require('test.test')

-- The test options.
local options = {
  verbose = false,
}

-- Sets up needed plugin options for the test suits.
local swap = require('swap')
swap.setup({
  chains = {
    words = {
      { 'foo', 'bar', 'baz', 'qux' },
    },
  },
  cases = {
    types = {
      'snake',
      'screaming_snake',
      'kebab',
      'screaming_kebab',
      'camel',
      'pascal',
    },
  },
})

-- The names of the test-suite description files, without
-- the extension `.lua`, which are to be tested.
local test_suite_names = {
  'util_test',
  'core_test',
  'mask_test',
  'validation_test',
  'opposites_test',
  'todos_test',
  'cases_test',
  'chains_test',
}

-- Runs the test suits.
test.run(test_suite_names, options)
