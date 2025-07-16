---@class swap.core
local M = {}

---Returns the start indexes of the found string in the line near the cursor.
---Multiple matches for overlapping words are possible.
--
--         |
--     false            <- cursor at word end
--       false          <- cursor in word
--         false        <- cursor at word start
--         |
-- 45678901234567890123 <- index in line
-- 34567890123456789012 <- column
--     ^   ^            <- min/max start index
--         |
--         ^            <- cursor position
--
--        word len:  5
--             col: 11 (12)
-- min_idx in line:  8 <- (11 + 1) - (5 - 1)
--             idx: 10
--
-- Find overlapping matches e.g. `foofoo` in `foofoofoofoo`:
--
--     foofoofoofoo     <- cursor in word
--         |
-- 45678901234567890123 <- index in line
-- 34567890123456789012 <- column
--         |
--     foofoo           <- match 1: start index 8
--        foofoo        <- match 2: start index 11
--         |
--         ^            <- cursor position
--
---@param line string The line string to search in.
---@param str string The string to find.
---@param cursor swap.Cursor The cursors position.
---@param opts? table The options.
---@return integer[] # The start indexes of the found string or empty if nothing found.
function M.find_str_in_line(line, str, cursor, opts)
  opts = opts or {}
  -- Converts index from column (0-based) to string (1-based).
  local col_idx = cursor.col + 1
  -- The minimum start index to start searching from.
  local min_start_idx = col_idx - (#str - 1)
  if min_start_idx < 1 then min_start_idx = 1 end

  local start_idx -- The found start index.
  local start_idxs = {} -- The found start indexes.

  -- Finds the start indexes of the string in the line.
  while min_start_idx <= col_idx do
    start_idx = string.find(line, str, min_start_idx, true) -- Uses no pattern matching.
    -- Breaks if the start index is nil or if it is after the cursor position.
    if start_idx == nil or start_idx > col_idx then break end
    -- Adds the start index to the list of start indexes.
    table.insert(start_idxs, start_idx)
    -- Breaks if the option is set to ignore overlapping matches.
    if opts.ignore_overlapping_matches then break end
    -- Sets the new minimum start index.
    min_start_idx = start_idx + 1
  end

  return start_idxs
end

-- function M.find_pattern_in_line(line, pattern, cursor)
--   local start_idx = string.find(line, pattern, cursor.col + 1, false) -- Uses pattern matching.
--   if start_idx == nil then return false end
--   return start_idx
-- end

---Replaces a string in a line.
---@param line string The line to replace in.
---@param result swap.Result The result set.
---@return string # Returns the line with the relpaced string.
local function replace_str_in_line(line, result)
  local left_part = string.sub(line, 1, result.start_idx - 1)
  local right_part = string.sub(line, result.start_idx + #result.str)
  return left_part .. result.new_str .. right_part
end

---Corrects the cursor position if it is outside the new string
---or if the cursor position has changed.
---@param cursor swap.Cursor
---@param start_idx integer
---@param new_str string
---@param can_outside? boolean The cursor can be outside the new string.
local function correct_cursor_position(cursor, start_idx, new_str, can_outside)
  can_outside = can_outside or false

  -- Gets the current cursor position.
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))

  -- Converts index from string (1-based) to column (0-based).
  local start_col = start_idx - 1
  local end_col = start_idx - 1 + #new_str - 1

  -- Corrects the cursor position if it is outside the new string.
  local new_col = cursor.col
  if not can_outside then
    if new_col < start_col then
      new_col = start_col
    elseif new_col > end_col then
      new_col = end_col
    end
  end

  -- Checks if the cursor position has to be changed.
  -- As a callback function, the cursor position is shifted one to the left. -- FIX: Why?
  if col ~= new_col then vim.api.nvim_win_set_cursor(0, { row, new_col }) end
end

---Replaces the string in the current line.
---This function is used as a callback function for `vim.ui.select`.
---@param result swap.Result
function M.replace_str_in_current_line(result)
  -- Gets the current line.
  local current_line = vim.api.nvim_get_current_line()

  -- Gets the new line with the replaced string.
  local new_line = replace_str_in_line(current_line, result)

  -- Sets the new line.
  vim.api.nvim_set_current_line(new_line)

  -- Corrects the cursor position.
  local cursor_outside = result.opts and result.opts.cursor_outside or false
  correct_cursor_position(result.cursor, result.start_idx, result.new_str, cursor_outside)
end

---Handles the results to replace the string in the current line.
---If there are multiple results, asks the user to select one.
---@param results swap.Results
function M.handle_results(results)
  if #results < 1 then
    -- No results found.
    return
  elseif #results == 1 then
    -- Only one result found.
    M.replace_str_in_current_line(results[1])
  else
    -- Multiple results found, asks the user to select one.
    local choices = {}
    for _, result in ipairs(results) do
      local module_match = ''
      if result.opts and result.opts.overlapping_match_idx then
        module_match = ', match ' .. result.opts.overlapping_match_idx
      end
      local choice_str = result.str .. ' -> ' .. result.new_str .. ' (' .. result.module .. module_match .. ')'
      table.insert(choices, choice_str)
    end
    vim.ui.select(choices, {
      prompt = 'Swap - Multiple results found:',
    }, function(_, idx)
      if idx ~= nil and idx > 0 then M.replace_str_in_current_line(results[idx]) end
    end)
  end
end

---Test interface for local functions.
---@param func_name string
---@param ... any
---@return any
function M.test(func_name, ...)
  local gateway = {
    replace_str_in_line = replace_str_in_line,
  }
  if type(gateway[func_name]) ~= 'function' then
    error("Test interface gateway for function name not found: '" .. func_name .. "'")
  end
  return gateway[func_name](...)
end

return M
