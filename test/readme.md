# A Simple Test Module

This is a simple and limited test module for testing Lua modules
in a Neovim plugin project.

Only the **asserted equality** is supported.

It runs all described test suites with its test cases and shows the test statistics.

Exit codes:

- `0` if all tests passed
- `1` if any test failed

## Sample Test Runs

A **successful** test run:

```shell
❯ nvim -l test/run.lua

Running tests...

Test suite: 'plugin.util'
Test suite: 'plugin.config'

================================
Test suites: 2 passed, 2 total
Test cases:  7 passed, 7 total
Tests:       14 passed, 14 total
================================

✅ Tests passed!
```

An **unsuccessful** test run:

```shell
❯ nvim -l test/run.lua

Running tests...

Test suite: 'plugin.util'
- tc01.2: ❌ failed

  expected: 11
  received: -1
  input   : { '+', 5, 6 }

Test suite: 'plugin.config'

==========================================
Test suites: 1 failed, 1 passed, 2 total
Test cases:  1 failed, 6 passed, 7 total
Tests:       1 failed, 13 passed, 14 total
==========================================

❌ Tests failed!
```

## Installation

Add a `test` folder with the `run.lua` and `test.lua` files to the root directory
of your project. The `test/` folder should look like this:

- `test/` ... The test directory.
  - `readme.lua` ... (optional) This file.
  - `run.lua` ... The test runner with the configuration.
  - `test.lua` ... The simple test module.

## Usage

Run the tests with the following command from the root directory
of your project:

```sh
nvim -l test/run.lua
```

This runs the configured tests with the Lua version of the installed Neovim.

## Configuration

The test suites to be used, and the test options, are specified in the
`run.lua` file.

### Test Suites

The `test_suite_names` variable is a list of test-suite description file names,
without the extension `.lua`.

```lua
local test_suites = {
  'module1_test',
  'module2_test',
}
```

The test suite description files must be located in the `test/` directory.

- `test/` ... The test directory.
  - `run.lua` ... The test runner with the configuration.
  - `test.lua` ... The simple test module.
  - `module1_test.lua` ... The `module1` [Test Suite Description](#test-suite-description).
  - `module2_test.lua` ... The `module2` [Test Suite Description](#test-suite-description).

### Options

```lua
local options = {
  verbose = false,
}
```

- `verbose`: If `true`, all test results are printed. If `false` (default),
  only failed test results are printed.

## Test Descriptions

The tests are described in test suites with test cases and variants.

## Test Suite Description

A test suite is described in his own file `test/module_test.lua` as follows:

- `name`: The name of the test suite.
- `test_cases`: A list of [Test Case Descriptions](#test-case-description).

Example:

```lua
local module_to_test = require('lua.module.module_to_test')

local M = {}

---The test suite name.
---@type string
M.name = 'module_to_test'

---Describes the test cases.
---@type testCases
M.test_cases = {
  -- Test case description.
  {
    id = 'tc01',
    name = 'function_to_test()',
    func = module_to_test.function_to_test,
    values = {
      { input = { 'foo', 11 }, expected = 'foo11', }
    },
  },
  -- Next test case description.
  {
    ...
  },
}

return M
```

### Test Case Description

A test case is described as follows:

- `id`: A (unique) identifier for the test case.
- `name`: The name of the test case.
- `func`: The function to be tested.
- `values`: A list of variants of input values and expected result pairs.
  - `input`: The input values (arguments) for the function to be tested.
  - `expected`: The expected return value of the function to be tested.
- `expected`: The default expected value of the test case. Good for many inputs with the same expected result.

> [!NOTE]
> The `values.expected` had priority over the `expected` value.
> One of the two must be set.

Example:

```lua
-- Test case description
{
  id = 'tc01',
  name = 'function_to_test()',
  func = module_to_test.function_to_test,
  values = {
    -- Variants
    { input = { '+', 5, 6 }, }
    { input = { '+', 3, 8 }, }
    { input = { '+', 7, 4 }, }
    { input = { '-', 9, 5 }, expected = 4, }
  },
  expected = 11,
}
```

## Notes

### Local Functions

In general, internal functions do not need to be tested. If it is necessary,
a test interface must be defined or they local functions must be exposed.

#### Test Interface Example

A `func` value in a test case description:

```lua
{
  id = 'tc01',
  name = 'local_function_name()',
  func = function(...) return module_to_test.test('local_function_name', ...) end,
  values = {
    { input = { 'foo', 11 }, expected = 'bar11', }
  },
},
```

A test interface in a module to test:

```lua
---Test interface for local functions.
---@param func_name string
---@param ... any
---@return any
function M.test(func_name, ...)
  local gateway = {
    local_function_name = local_function_name,
  }
  if type(gateway[func_name]) ~= 'function' then
    error("Test interface gateway for function name not found: '" .. func_name .. "'")
  end
  return gateway[func_name](...)
end
```
