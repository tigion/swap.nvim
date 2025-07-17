local config = require('swap.config')
local notify = require('swap.notify')
local util = require('swap.util')

---@class swap.todos
local M = {}

---@type swap.TodosSyntax
local default_todo_syntax = {
  pattern = { before = '(- %[)', state = '([^%[%]]+)', after = '(%] )' },
  states = { switch = { ' ', 'x' } },
}

---@type swap.TodosSyntaxByFt
local todo_syntax_by_ft = {
  markdown = {
    pattern = { before = '([-*+]%s+%[)', state = '([^%[%]]+)', after = '(%] )' },
    states = { switch = { ' ', 'x' } },
  },
  asciidoc = {
    pattern = { before = '([-*]%**%s+%[)', state = '([^%[%]]+)', after = '(%] )' },
    states = { switch = { ' ', 'x' }, find = { '*' } },
  },
  org = {
    pattern = { before = '(-%s+%[)', state = '([^%[%]]+)', after = '(%] )' },
    states = { switch = { ' ', '-', 'X' }, find = { 'x' } },
  },
}

---Returns the combined todo syntaxes of the file type specific and standard ones.
---@return swap.TodosSyntaxes
local function get_todo_syntaxes()
  local filetype = vim.bo.filetype
  local syntaxes = {}

  -- Adds the filetype specific syntax.
  local todo_syntax = todo_syntax_by_ft[filetype]
  if todo_syntax ~= nil then table.insert(syntaxes, todo_syntax) end

  -- Adds the default syntax as fallback.
  table.insert(syntaxes, default_todo_syntax)

  return syntaxes
end

---Returns the results for the found todos in the given line.
---Only the first match is used.
---@param line string The line string to search in.
---@param cursor swap.Cursor The cursors position.
---@return swap.Results # The found results.
local function find_results(line, cursor)
  local results = {} ---@type swap.Results

  -- Gets the filetype specified todo syntaxes.
  local syntaxes = get_todo_syntaxes()

  -- Searches for the todo syntax in the line.
  -- The first match is used.
  for _, syntax in ipairs(syntaxes) do
    -- Gets the states to switch between and the pattern to search for.
    local states = syntax.states.switch
    local pattern = syntax.pattern.before .. syntax.pattern.state .. syntax.pattern.after

    -- Finds the first match in the line.
    local start_idx, end_idx, capture_before, capture_state, capture_after = string.find(line, pattern)

    -- Extends a deep copy of the states with the extra states to find,
    -- if there are more states to find than to switch between.
    local states_find = vim.list_extend(vim.deepcopy(states), syntax.states.find or {})

    -- Checks if a todo pattern and supported state was found.
    if start_idx ~= nil and capture_state ~= nil and vim.tbl_contains(states_find, capture_state) then
      -- Gets the state and the start index of the state.
      local state = capture_state
      local state_start_idx = start_idx + #capture_before

      -- Gets the next state.
      local idx = util.table.find(states, state)
      local next_state = states[next(states, idx) or next(states)]

      -- Adds the result to the results list.
      table.insert(results, {
        str = state,
        new_str = next_state,
        start_idx = state_start_idx,
        cursor = cursor,
        module = 'todos',
        opts = {
          cursor_outside = true,
        },
      })

      -- Stops searching after the first match.
      return results
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
