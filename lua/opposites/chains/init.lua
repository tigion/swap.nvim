local config = require('opposites.config')
local notify = require('opposites.notify')

---@class opposites.chains
local M = {}

---Returns the results for the words found or their opposite
---in the given line near the given column.
---@param line string The line string to search in.
---@param cursor opposites.Cursor The cursors position.
---@return opposites.Results # The found results.
local function find_results(line, cursor)
  local results = {} ---@type opposites.Results

  -- Iterates over the word chains and the words they contain.
  for _, words in ipairs(config.options.chains.words) do
    for idx, word in ipairs(words) do
      -- Finds the word in the line under the cursor.
      local start_idx, end_idx
      while #words > 1 do
        start_idx, end_idx = string.find(line, word, (end_idx or 0) + 1, true) -- Uses no pattern matching.
        if start_idx == nil then break end
        if start_idx <= cursor.col + 1 and end_idx >= cursor.col + 1 then
          -- Adds the result to the results list.
          table.insert(results, {
            str = word,
            new_str = words[next(words, idx) or next(words)],
            start_idx = start_idx,
            cursor = cursor,
            module = 'chains',
          })
        end
      end
    end
  end

  return results
end

---Returns the found results.
---@param line string The line string to search in.
---@param cursor opposites.Cursor The cursors position.
---@param quiet? boolean Whether to quiet the notifications.
---@return opposites.Results # The found results.
function M.get_results(line, cursor, quiet)
  quiet = quiet or false

  -- Gets the found results.
  local results = find_results(line, cursor)

  -- Checks and notifies if we found any results.
  if #results < 1 then
    -- No results found.
    if not quiet and config.options.notify.not_found then notify.info('No next word found', cursor) end
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
