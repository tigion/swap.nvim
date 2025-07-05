local config = require('swap.config')
local notify = require('swap.notify')
local util = require('swap.util')

-- TODO:
-- - [ ] Allow multiple default or filetype specific todo patterns.
-- - [ ] Add better state position identification.

---@class swap.todos
local M = {}

---@class swap.TodoPattern
---@field pattern string The pattern to search for.
---@field states string[] The states to switch between.
---@field state_pos_offset integer The offset off the end index for the state position.

---@alias swap.TodoPatterns swap.TodoPattern[]
---@alias swap.TodoPatternByFt table<string, swap.TodoPattern>

local todo_pattern_default = {
  pattern = '- %[([ -x])%] ',
  states = { ' ', 'x' },
  state_pos_offset = 2,
}
local todo_pattern_by_ft = {
  markdown = {
    pattern = '^%s*[-*] %[([ -x])%] ',
    states = { ' ', '-', 'x' },
    state_pos_offset = 2,
  },
  asciidoc = {
    pattern = '^%s*[-*]%** %[([ *x])%] ',
    states = { ' ', 'x' },
    state_pos_offset = 2,
  },
}

---Returns the combined todo patterns of the default and
---the current file type specific ones.
---@return swap.TodoPatterns
local function get_todo_patterns()
  local patterns = {}
  local pattern_by_ft = todo_pattern_by_ft[vim.bo.filetype]
  if pattern_by_ft ~= nil then table.insert(patterns, pattern_by_ft) end
  table.insert(patterns, todo_pattern_default)
  return patterns
end

---Returns the results for the found todos in the given line.
---Only the first match is used.
---@param line string The line string to search in.
---@param cursor swap.Cursor The cursors position.
---@return swap.Results # The found results.
local function find_results(line, cursor)
  local results = {} ---@type swap.Results

  -- Gets the filetype specified todo syntaxes.
  local syntaxes = get_todo_patterns()

  -- Searches for the todo syntax in the line.
  -- The first match is used.
  for _, syntax in ipairs(syntaxes) do
    local start_idx, end_idx, state = string.find(line, syntax.pattern)
    if start_idx ~= nil then
      -- Sets start index to the state position between the brackets.
      start_idx = end_idx - syntax.state_pos_offset

      -- Sets the next state.
      local idx = util.table.find(syntax.states, state)
      local new_state = syntax.states[next(syntax.states, idx) or next(syntax.states)]

      -- Adds the result to the results list.
      table.insert(results, {
        str = state,
        new_str = new_state,
        start_idx = start_idx,
        cursor = cursor,
        module = 'todos',
        opts = {
          cursor_outside = true,
        },
      })

      -- Stops searching after the first match.
      break
    end
  end

  return results
end

---Returns the found results.
---@param line string The line string to search in.
---@param cursor swap.Cursor The cursors position.
---@param quiet? boolean Whether to quiet the notifications.
---@return swap.Results # The found results.
function M.get_results(line, cursor, quiet)
  quiet = quiet or false

  -- Gets the found results.
  local results = find_results(line, cursor)

  -- Checks and notifies if we found any results.
  if #results < 1 then
    -- No results found.
    if not quiet and config.options.notify.not_found then notify.info('No todo found', cursor) end
    return {}
  elseif not quiet and config.options.notify.found then
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
