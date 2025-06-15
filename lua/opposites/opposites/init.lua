local config = require('opposites.config')
local notify = require('opposites.notify')

local util = require('opposites.opposites.util')

---@class opposites.opposites
local M = {}

---@class opposites.OppositesResult
---@field word string The found word.
---@field opposite_word string The opposite word.
---@field idx integer The index of the beginning of the word in the line near the cursor.
---@field use_mask boolean Whether to use a case sensitive mask.
---@field cursor { row: integer, col: integer } The cursor position.

---Returns the index of the beginning of the word
---in the line near the cursor.
--
--         |
--     false            <- cursor at word end
--       false          <- cursor in word
--         false        <- cursor at word start
--         |
-- 45678901234567890123 <- index in line
-- 34567890123456789012 <- column
--     ^ ^ |   ^
--         ^            <- cursor position
--
--        word len:  5
--             col: 11 (12)
-- min_idx in line:  8 <- (11 + 1) - (5 - 1)
--             idx: 10
--
---@param line string The line string to search in.
---@param col integer The cursors column position.
---@param word string The word to find.
---@return integer # The index of the beginning of the word or `-1` if not found.
local function find_word_in_line(line, col, word)
  local min_idx = (col + 1) - (#word - 1)
  local idx = string.find(line, word, min_idx, true)
  return idx ~= nil and idx <= (col + 1) and idx or -1
end

---Returns the results for the words found or their opposite
---in the given line near the given column.
---@param line string The line string to search in.
---@param cursor { row: integer, col: integer } The cursors position.
---@return table<opposites.OppositesResult> # The found results.
local function find_results(line, cursor)
  local words = config.merge_opposite_words()
  local results = {} ---@type table<opposites.OppositesResult>

  -- Finds the word or the opposite word in the line.
  for w, ow in pairs(words) do
    for _, v in ipairs({ { w, ow }, { ow, w } }) do
      local word, opposite_word = v[1], v[2]
      local use_mask = false
      -- Uses a case sensitive mask if the option is activated and
      -- the word or the opposite word contains no uppercase letters.
      if
        config.options.opposites.use_case_sensitive_mask
        and not (util.has_uppercase(word) or util.has_uppercase(opposite_word))
      then
        use_mask = true
      end
      -- Finds the word in the line.
      local idx = find_word_in_line(use_mask and line:lower() or line, cursor.col, word)
      if idx ~= -1 then
        -- Adds the result to the results list.
        table.insert(results, {
          word = word,
          opposite_word = opposite_word,
          idx = idx,
          use_mask = use_mask,
          cursor = cursor,
        })
      end
    end
  end

  -- Sorts the results by length and then alphabetically.
  table.sort(results, function(a, b)
    if #a.word == #b.word then
      if a.word == b.word then return a.opposite_word < b.opposite_word end
      return a.word < b.word
    end
    return #a.word < #b.word
  end)

  return results
end

---Returns the line with the replaced word at the index in the line.
---@param line string
---@param result opposites.OppositesResult
---@return string
local function replace_word_in_line(line, result)
  local idx = result.idx
  local old_word = result.word
  local new_word = result.opposite_word
  local use_mask = result.use_mask

  local left_part = string.sub(line, 1, idx - 1)
  if use_mask then
    local middle_part = string.sub(line, idx, idx + #old_word - 1)
    local mask = util.get_case_sensitive_mask(middle_part)
    new_word = util.apply_case_sensitive_mask(new_word, mask)
  end
  local right_part = string.sub(line, idx + #old_word)

  return left_part .. new_word .. right_part
end

---Replaces the result in the current line.
---This function is used as a callback function for `vim.ui.select`.
---@param result opposites.OppositesResult
function M.replace_result_in_current_line(result)
  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))

  -- Replaces the current line with a new line in which the word at
  -- the given index has been replaced by the opposite word.
  local new_line = replace_word_in_line(line, result)
  vim.api.nvim_set_current_line(new_line)

  -- Corrects the cursor position if the opposite word is shorter than the word.
  local max_col = result.idx - 1 + #result.opposite_word - 1
  if result.cursor.col > max_col then result.cursor.col = max_col end

  -- Checks if the cursor position has changed.
  -- As a callback function, the cursor position is shifted one to the left. -- FIX: Why?
  if col ~= result.cursor.col then
    -- Restores the cursor position.
    col = result.cursor.col
    vim.api.nvim_win_set_cursor(0, { row, col })
  end

  if config.options.notify.found then
    local row_col_str = '[' .. row .. ':' .. col + 1 .. ']'
    notify.info(row_col_str .. ' ' .. result.word .. ' -> ' .. result.opposite_word)
  end
end

---Switches the word under the cursor to its opposite word.
function M.switch_word_to_opposite_word()
  -- Gets the current line string and the current cursor position.
  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local cursor = { row = row, col = col }

  -- Checks the max allowed line length.
  if line:len() > config.options.max_line_length then
    notify.error('Line too long: ' .. line:len() .. ' (max: ' .. config.options.max_line_length .. ')')
    return
  end

  -- Finds words or their opposite in the current line near the cursor.
  local results = find_results(line, cursor)

  -- Checks if we found any results.
  if #results < 1 then
    -- No results found.
    local row_col_str = '[' .. cursor.row .. ':' .. cursor.col + 1 .. ']'
    if config.options.notify.not_found then notify.info(row_col_str .. ' No opposite word found') end
  elseif #results == 1 then
    -- Only one result found.
    M.replace_result_in_current_line(results[1])
  else
    -- Multiple results found, asks the user to select one.
    local choices = {}
    for _, result in ipairs(results) do
      table.insert(choices, result.word .. ' -> ' .. result.opposite_word)
    end
    vim.ui.select(choices, {
      prompt = 'Opposites - Multiple results found:',
    }, function(_, idx)
      if idx ~= nil and idx > 0 then M.replace_result_in_current_line(results[idx]) end
    end)
  end
end

return M
