# A Simple Unit Test Framework

Only the **asserted equality** is supported.

## Test Runner

The test runner is located at `test/run.lua`.

To run the tests with the Lua version of Neovim, execute the following
command:

```sh
nvim -l test/run.lua
```

The test runner will run all test suits and show the test statistics.

Exit codes:

- `0` if all tests passed
- `1` if any test failed

## Test Runner Configuration

The test runner configuration is located at `test/run.lua`.

### Test Suites

The `test_suites` variable is a list of Lua modules with test suite descriptions.

```lua

-- The test suits to be tested.
local test_suites = {
  require('test.module1_test'),
  require('test.module2_test'),
}
```

### Options

- `verbose`: If `true`, all test results are printed. If `false` (default),
  only failed test results are printed.

```lua
-- The test runner options.
local options = {
  verbose = false,
}
```

## Test Suite Description

A test suite is described in his own file `test/module_test.lua` as follows:

- `name`: The name of the test suite.
- `test_cases`: A list of test cases.

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
  - `input`: The input values for the function to be tested.
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

An example in a test case description:

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

An example of a test interface:

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
