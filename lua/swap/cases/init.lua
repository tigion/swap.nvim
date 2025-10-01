local config = require('swap.config')
local notify = require('swap.notify')
local util = require('swap.util')

---@class swap.cases
M = {}

-- TODO: Needs some refactoring.

local snake = require('swap.cases.sources.snake')
local kebab = require('swap.cases.sources.kebab')
local camel = require('swap.cases.sources.camel')
local pascal = require('swap.cases.sources.pascal')

---Contains the supported case types.
---@type table<string, swap.CasesType>
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
---@return integer? # The start index of the word or nil.
---@return string? # The word or nil if not found.
local function find_word_in_line(line, col)
  local pattern = '[%w_%-]+'
  -- local pattern = '[a-zA-Z0-9_-]+'
  local start_idx, end_idx

  -- Finds the pattern matching word in the line.
  while true do
    start_idx, end_idx = string.find(line, pattern, (end_idx or 0) + 1)
    if start_idx == nil then break end
    if start_idx <= col + 1 and end_idx >= col + 1 then
      local word = line:sub(start_idx, end_idx)
      return start_idx, word
    end
  end

  return nil
end

---Gets the allowed case type ids filtered by the user config.
---@return swap.ConfigCasesTypes
local function get_allowed_case_type_ids()
  -- Gets the case types from the user config.
  local user_cases = config.options.cases.types
  if type(user_cases) ~= 'table' or #user_cases == 0 then return {} end

  -- Filters the case type ids.
  local allowed_case_ids = {}
  for _, id in ipairs(user_cases) do
    if cases[id] then table.insert(allowed_case_ids, id) end
  end

  return allowed_case_ids
end

---Parses the given word with the allowed case types.
---@param word string The word to parse.
---@return swap.CasesResult|boolean # The parsed result or false.
local function parse_allowed_case_types(word)
  for _, case_type_id in ipairs(get_allowed_case_type_ids()) do
    local case_type = cases[case_type_id]
    if case_type then
      local result = case_type.parser(word)
      if result then return result end
    end
  end

  return false
end

---Gets the next available case type id.
---@param case_type_id string
---@return string?
local function get_next_case_type_id(case_type_id)
  -- Gets the allowed case types and exits with nil if there are none.
  local allowed_case_type_ids = get_allowed_case_type_ids()
  if #allowed_case_type_ids == 0 then return nil end

  -- Finds the index of the given case type id.
  local index = util.table.find(allowed_case_type_ids, case_type_id)
  if index == nil then return nil end

  -- Gets the next case type id.
  local new_case_type_idx = index < #allowed_case_type_ids and index + 1 or 1

  return allowed_case_type_ids[new_case_type_idx]
end

---Switches the given word to its next case type or the given case type.
---
---Example: `switch_to_next_or_given_case_type('foo_bar')`
---
---    foo_bar -> FOO_BAR -> foo-bar -> FOO-BAR -> fooBar -> FooBar -> foo_bar
---
---Example: `switch_to_next_or_given_case_type('foo_bar', 'pascal')`
---
---    foo_bar -> FooBar
---
---@param word string The word to switch.
---@param case_id? swap.ConfigCasesId The case id for the new case type or `nil` for the next case type.
---@return string|boolean # Returns the word with the next or new case type or false if not supported.
local function switch_to_next_or_given_case_type(word, case_id)
  -- Exits if word is nil or empty.
  if word == nil or word == '' then return false end

  -- Extracts the prefix, inner word and suffix from the word.
  -- Allowed prefix/suffix chars are one or more underscores `_`.
  local prefix, inner_word, suffix = word:match('^(_*)(.*[^%_]+)(_*)')

  -- Parses given word to supported case type.
  -- Exits if word is not supported or has less than 2 parts.
  local result = parse_allowed_case_types(inner_word)
  if result == false or #result.parts < 2 then return false end

  -- Gets the next case type or use the given case type.
  local new_case_type_id = case_id == nil and get_next_case_type_id(result.case_type_id) or case_id

  -- If the new case type is the same as the current one, a change is not necessary.
  -- Returns the word as it is to handle the notification in the caller.
  if new_case_type_id == result.case_type_id then return word end

  -- Returns converted parts based on the new case type.
  if cases[new_case_type_id] then
    local converter = cases[new_case_type_id].converter
    if type(converter) == 'function' then return prefix .. converter(result.parts) .. suffix end
  end

  return false
end

---Returns the results for the found word and its next or new case type.
---@param line string The line string to search in.
---@param cursor swap.Cursor The cursors position.
---@param quiet? boolean Whether to quiet the notifications.
---@param case_id? swap.ConfigCasesId The case id for the new case type or `nil` for the next case type.
---@return swap.Results # The found results.
local function find_results(line, cursor, quiet, case_id)
  local results = {}

  -- Finds the word in the current line.
  local start_idx, word = find_word_in_line(line, cursor.col)
  if word == nil or word == '' then
    if not quiet and config.options.notify.not_found then notify.info('No word found', cursor) end
    return {}
  end

  -- Gets the new case type and checks if the word is supported.
  local new_word = switch_to_next_or_given_case_type(word, case_id)
  if new_word == false then
    if not quiet and config.options.notify.not_found then
      notify.info('`' .. word .. '` has an unsupported case type', cursor)
    end
    return {}
  elseif new_word == word then
    if not quiet and config.options.notify.not_found then
      notify.info('`' .. word .. '` already has the case type' .. (case_id and ' `' .. case_id .. '`' or ''), cursor)
    end
    return {}
  end

  -- Adds the result to the results list.
  table.insert(results, {
    str = word,
    new_str = new_word,
    start_idx = start_idx,
    cursor = cursor,
    module = 'cases',
  })

  return results
end

---Returns the found results.
---@param line string The line string to search in.
---@param cursor swap.Cursor The cursors position.
---@param quiet? boolean Whether to quiet the notifications.
---@param case_id? swap.ConfigCasesId The case id for the new case type or `nil` for the next case type.
---@return swap.Results # The found results.
function M.get_results(line, cursor, quiet, case_id)
  quiet = quiet or false

  -- Gets the found results.
  local results = find_results(line, cursor, quiet, case_id)

  -- Checks if we found any results.
  if #results > 0 and not quiet and config.options.notify.found then
    -- Results found.
    local new_strs = {}
    for _, result in ipairs(results) do
      table.insert(new_strs, result.new_str)
    end
    notify.info(results[1].str .. ' -> ' .. table.concat(new_strs, ', '), cursor)
  end

  return results
end

return M
