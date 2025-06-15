local config = require('opposites.config')
local notify = require('opposites.notify')

local util = require('opposites.cases.util')

---@class opposites.cases
M = {}

-- TODO: Needs some refactoring.
-- - Refactor case data like `pascal.lua`.
-- - Optimize annotations and naming.

---@class opposites.CasesSource
---@field id opposites.ConfigCasesId
---@field name string
---@field parser fun(word: string): opposites.CasesResult|boolean
---@field converter fun(parts: table<string>, scream?: boolean): string
---@field screaming? opposites.CasesSource

---@class opposites.CasesType
---@field name string
---@field parser fun(word: string): opposites.CasesResult|boolean
---@field converter fun(parts: table<string>, scream?: boolean): string

---@class opposites.CasesResult
---@field parts table<string>
---@field case_type_id string

local snake = require('opposites.cases.sources.snake')
local kebab = require('opposites.cases.sources.kebab')
local camel = require('opposites.cases.sources.camel')
local pascal = require('opposites.cases.sources.pascal')

---Contains the supported case types.
---@type table<string, opposites.CasesType>
local cases = {
  [snake.id] = {
    name = snake.name,
    parser = snake.parser,
    converter = snake.converter,
  },
  [snake.screaming.id] = {
    name = snake.screaming.name,
    parser = snake.screaming.parser,
    converter = snake.screaming.converter,
  },
  [kebab.id] = {
    name = kebab.name,
    parser = kebab.parser,
    converter = kebab.converter,
  },
  [kebab.screaming.id] = {
    name = kebab.screaming.name,
    parser = kebab.screaming.parser,
    converter = kebab.screaming.converter,
  },
  [camel.id] = {
    name = camel.name,
    parser = camel.parser,
    converter = camel.converter,
  },
  [pascal.id] = {
    name = pascal.name,
    parser = pascal.parser,
    converter = pascal.converter,
  },
}

---Gets the allowed case types filtered by the user config.
---@return opposites.ConfigCases
local function get_allowed_case_types()
  -- Gets the case types from the user config.
  local user_cases = config.options.cases.types
  if type(user_cases) ~= 'table' or #user_cases == 0 then return {} end

  -- Filters the case types.
  local allowed_cases = {}
  for _, id in ipairs(user_cases) do
    if cases[id] then allowed_cases[id] = cases[id] end
  end

  return allowed_cases
end

---Parses the given word with the allowed case types.
---@param word string The word to parse.
---@return opposites.CasesResult|boolean # The parsed result or false.
local function parse_allowed_case_types(word)
  for _, case_type in pairs(get_allowed_case_types()) do
    local parser = case_type.parser
    if type(parser) == 'function' then
      local result = parser(word)
      if result then return result end
    end
  end

  return false
end

---Gets the next available case type id.
---@param case_type_id string
---@return string|nil
local function get_next_case_type_id(case_type_id)
  -- Gets the allowed case types and exits with nil if there are none.
  local allowed_case_types = get_allowed_case_types()
  if util.table_length(allowed_case_types) == 0 then return nil end

  -- Gets the next case type id.
  local new_case_type_id = next(allowed_case_types, case_type_id)
  -- Gets the first case type id if the next one is nil.
  if new_case_type_id == nil then new_case_type_id = next(allowed_case_types) end

  return new_case_type_id
end

---Switches the given word to its next case type.
---
---Example:
---
---    foo_bar -> FOO_BAR -> foo-bar -> FOO-BAR -> fooBar -> FooBar -> foo_bar
---
---@param word string The word to switch.
---@return string|boolean # The next case type or false if not supported.
local function switch_to_next_case_type(word)
  -- Exits if word is nil or empty.
  if word == nil or word == '' then return false end

  -- Parses given word to supported case type.
  -- Exits if word is not supported or has less than 2 parts.
  local result = parse_allowed_case_types(word)
  if result == false or #result.parts < 2 then return false end

  -- Returns converted parts based on next case type.
  local next_case_type_id = get_next_case_type_id(result.case_type_id)
  if cases[next_case_type_id] then
    local converter = cases[next_case_type_id].converter
    if type(converter) == 'function' then return converter(result.parts) end
  end

  return false
end

---Finds the word with start and end position
---in the line under the cursor.
--
-- INFO: Supports currently only words with alphanumeric characters,
--       underscores and dashes.
--
--         |
--     foo_bar          <- cursor in word
--         |
-- 45678901234567890123 <- index in line
-- 34567890123456789012 <- column
--     ^ ^ |   ^
--         ^            <- cursor position
--
--        word len:  7
--      word start:  8
--        word end: 14
--             col: 11 (12)
--
---@param line string The line string to search in.
---@param col integer The cursors column position.
---@return string|nil # The word or nil if not found.
---@return integer|nil # The start index of the word or nil.
---@return integer|nil # The end index of the word or nil.
local function find_word_in_line(line, col)
  local pattern = '[a-zA-Z0-9_-]+'
  local word_start, word_end

  -- Finds the pattern matching word in the line under the cursor.
  while true do
    word_start, word_end = string.find(line, pattern, (word_end or 0) + 1)
    if word_start == nil then break end
    if word_start <= col + 1 and word_end >= col + 1 then
      local word = line:sub(word_start, word_end)
      return word, word_start, word_end
    end
  end

  return nil
end

---Switches the word under the cursor to its next case type.
function M.switch_word_to_next_case_type()
  -- Gets the current line string and the current cursor position.
  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local cursor = { row = row, col = col }

  -- Checks the max allowed line length.
  if line:len() > config.options.max_line_length then
    notify.error('Line too long: ' .. line:len() .. ' (max: ' .. config.options.max_line_length .. ')')
    return
  end

  -- Finds the word in the current line.
  local word, word_start, word_end = find_word_in_line(line, cursor.col)
  if word == nil and config.options.notify.not_found then
    local row_col_str = '[' .. cursor.row .. ':' .. cursor.col + 1 .. ']'
    notify.info(row_col_str .. ' No word found')
    return
  end

  -- Checks if the word is nil or empty.
  if word == nil or word == '' then return end

  -- Gets the next case type and checks if the word is supported.
  local new_word = switch_to_next_case_type(word)
  if new_word == false and config.options.notify.not_found then
    local row_col_str = '[' .. cursor.row .. ':' .. cursor.col + 1 .. ']'
    notify.info(row_col_str .. ' Word `' .. word .. '` is an unsupported case type')
    return
  end

  -- Replaces the found word in the current line.
  local left_part = string.sub(line, 1, word_start - 1)
  local right_part = string.sub(line, word_end + 1)
  local new_line = left_part .. new_word .. right_part
  vim.api.nvim_set_current_line(new_line)

  -- Corrects the cursor position if the opposite word is shorter than the word.
  local max_col = word_start - 1 + #new_word - 1
  local new_col = cursor.col
  if new_col > max_col then new_col = max_col end

  -- Checks if the cursor position has changed.
  if new_col ~= cursor.col then vim.api.nvim_win_set_cursor(0, { cursor.row, new_col }) end

  -- Shows a success notification if the option is activated.
  if config.options.notify.found then
    local row_col_str = '[' .. cursor.row .. ':' .. cursor.col + 1 .. ']'
    notify.info(row_col_str .. ' ' .. word .. ' -> ' .. new_word)
  end
end

return M
