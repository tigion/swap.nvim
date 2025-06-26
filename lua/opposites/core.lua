---@class opposites.core
local M = {}

---Replaces a string in a line.
---@param line string The line to replace in.
---@param result opposites.Result The result set.
---@return string # Returns the line with the relpaced string.
local function replace_str_in_line(line, result)
  local left_part = string.sub(line, 1, result.start_idx - 1)
  local right_part = string.sub(line, result.start_idx + #result.str)
  return left_part .. result.new_str .. right_part
end

---Corrects the cursor position if it is outside the new string
---or if the cursor position has changed.
---@param cursor opposites.Cursor
---@param start_idx integer
---@param new_str string
local function correct_cursor_position(cursor, start_idx, new_str)
  -- Gets the current cursor position.
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))

  -- Converts index (1-based) to column (0-based).
  local start_col = start_idx - 1
  local end_col = start_idx - 1 + #new_str - 1

  -- Corrects the cursor position if it is outside the new string.
  local new_col = cursor.col
  if new_col < start_col then
    new_col = start_col
  elseif new_col > end_col then
    new_col = end_col
  end

  -- Checks if the cursor position has to be changed.
  -- As a callback function, the cursor position is shifted one to the left. -- FIX: Why?
  if col ~= new_col then vim.api.nvim_win_set_cursor(0, { row, new_col }) end
end

---Replaces the string in the current line.
---This function is used as a callback function for `vim.ui.select`.
---@param result opposites.Result
function M.replace_str_in_current_line(result)
  -- Gets the current line.
  local current_line = vim.api.nvim_get_current_line()

  -- Gets the new line with the replaced string.
  local new_line = replace_str_in_line(current_line, result)

  -- Sets the new line.
  vim.api.nvim_set_current_line(new_line)

  -- Corrects the cursor position.
  correct_cursor_position(result.cursor, result.start_idx, result.new_str)
end

---Handles the results to replace the string in the current line.
---If there are multiple results, asks the user to select one.
---@param results opposites.Results
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
      table.insert(choices, result.str .. ' -> ' .. result.new_str .. ' (' .. result.module .. ')')
    end
    vim.ui.select(choices, {
      prompt = 'Opposites - Multiple results found:',
    }, function(_, idx)
      if idx ~= nil and idx > 0 then M.replace_str_in_current_line(results[idx]) end
    end)
  end
end

return M
