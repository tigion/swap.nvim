local config = require('opposites.config')
local notify = require('opposites.notify')

---@class opposites.opposite
local M = {}

---@class opposites.Result
---@field word string The found word.
---@field opposite_word string The opposite word.
---@field idx integer The index of the beginning of the word in the line near the cursor.

---Returns the index of the beginning of the word
---in the line near the cursor.
--
--         |
--     false            <- cursor at word end
--       false          <- cursor in word
--         false        <- cursor at word start
--         |
-- 45678901234567890123 <- column/index in line
--     ^ ^ |   ^
--         ^            <- cursor position
--
--        word len:  5
--             col: 12
-- min_idx in line:  8 <- 12 - (5 - 1)
--             idx: 10
--
---@param line string The line string to search in.
---@param col integer The cursors column position.
---@param word string The word to find.
---@return integer # The index of the beginning of the word or `-1` if not found.
local function find_word_in_line(line, col, word)
  local min_idx = col - (#word - 1)
  local idx = string.find(line, word, min_idx)
  return idx ~= nil and idx <= col and idx or -1
end

---Returns the results for the words found or their opposite
---in the given line near the given column.
---
---@param line string The line string to search in.
---@param col integer The cursors column position.
---@return table<opposites.Result> # The found results.
local function find_results(line, col)
  local results = {} ---@type table<opposites.Result>

  for w, ow in pairs(config.options.opposites) do
    -- Finds the word in the line.
    local word, opposite_word = w, ow
    local idx = find_word_in_line(line, col, word)
    if idx ~= -1 then table.insert(results, { word = word, opposite_word = opposite_word, idx = idx }) end
    -- Finds the opposite word in the line.
    word, opposite_word = ow, w
    idx = find_word_in_line(line, col, word)
    if idx ~= -1 then table.insert(results, { word = word, opposite_word = opposite_word, idx = idx }) end
  end

  -- Sorts the results by length and then alphabetically.
  table.sort(results, function(a, b)
    if #a.word == #b.word then return a.word < b.word end
    return #a.word < #b.word
  end)

  return results
end

---Returns the selected result or nil if no result was selected.
---
---@param results table<opposites.Result> The results to select from.
---@return opposites.Result|nil # The selected result or nil if no result was selected.
local function select_result(results)
  results = results or {}
  if #results == 0 then return nil end
  if #results == 1 then return results[1] end

  local choices = { 'Multiple results found:' }
  for idx, result in ipairs(results) do
    table.insert(choices, idx .. '. ' .. result.word .. ' -> ' .. result.opposite_word)
  end
  local idx = vim.fn.inputlist(choices)
  if idx == 0 or idx == nil then return nil end

  return results[idx]
end

---Returns the line with the replaced word at the index in the line.
---@param line string
---@param idx integer
---@param old_word string
---@param new_word string
---@return string
local function replace_word_in_line(line, idx, old_word, new_word)
  local left_part = string.sub(line, 1, idx - 1)
  local right_part = string.sub(line, idx + #old_word)
  return left_part .. new_word .. right_part
end

---Switches the word under the cursor to its opposite word.
function M.switch_word_to_opposite_word()
  -- Gets the current line string and the current cursor position.
  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  col = col + 1 -- Starts columns at index 1 not 0.
  local row_col_str = '[' .. row .. ':' .. col .. ']'

  -- Checks the max allowed line length.
  if line:len() > config.options.max_line_length then
    notify.error('Line too long: ' .. line:len() .. ' (max: ' .. config.options.max_line_length .. ')')
    return
  end

  -- Finds words or their opposite in the current line near the cursor.
  local results = find_results(line, col)

  -- Checks if we found any results.
  if #results < 1 then
    if config.options.notify.not_found then notify.info(row_col_str .. ' No opposite word found') end
    return
  end

  -- Selects the relevan result.
  local result = select_result(results)
  if result == nil then return end

  -- Replaces the current line with a new line in which the word at
  -- the given index has been replaced by the opposite word.
  local new_line = replace_word_in_line(line, result.idx, result.word, result.opposite_word)
  vim.api.nvim_set_current_line(new_line)
  if config.options.notify.found then
    notify.info(row_col_str .. ' ' .. result.word .. ' -> ' .. result.opposite_word)
  end
end

return M
