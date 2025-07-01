local config = require('opposites.config')
local notify = require('opposites.notify')
local util = require('opposites.util')

---@class opposites.opposites
local M = {}

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
---@return integer # The start index of the word or `-1` if not found.
local function find_word_in_line(line, col, word)
  local min_idx = (col + 1) - (#word - 1)
  local idx = string.find(line, word, min_idx, true) -- Uses no pattern matching.
  return idx ~= nil and idx <= (col + 1) and idx or -1
end

---Returns the results for the words found or their opposite
---in the given line near the given column.
---@param line string The line string to search in.
---@param cursor opposites.Cursor The cursors position.
---@return opposites.Results # The found results.
local function find_results(line, cursor)
  local words = config.merge_opposite_words()
  local results = {} ---@type opposites.Results

  -- Finds the word or the opposite word in the line.
  for w, ow in pairs(words) do
    for _, v in ipairs({ { w, ow }, { ow, w } }) do
      local word, opposite_word = v[1], v[2]
      local use_mask = false
      -- Uses a case sensitive mask if the option is activated and
      -- the word or the opposite word contains no uppercase letters.
      if
        config.options.opposites.use_case_sensitive_mask
        and not (util.mask.has_uppercase(word) or util.mask.has_uppercase(opposite_word))
      then
        use_mask = true
      end
      -- Finds the word in the line.
      local idx = find_word_in_line(use_mask and line:lower() or line, cursor.col, word)
      if idx ~= -1 then
        -- Applies the case sensitive mask if the option is activated.
        if use_mask then
          -- Gets the original word.
          word = string.sub(line, idx, idx + #word - 1)
          local mask = util.mask.get_case_sensitive_mask(word)
          opposite_word = util.mask.apply_case_sensitive_mask(opposite_word, mask)
        end

        -- Adds the result to the results list.
        table.insert(results, {
          str = word,
          new_str = opposite_word,
          start_idx = idx,
          cursor = cursor,
          module = 'opposites',
        })
      end
    end
  end

  -- Sorts the results by length and then alphabetically.
  table.sort(results, function(a, b)
    if #a.str == #b.str then
      if a.str == b.str then return a.new_str < b.new_str end
      return a.str < b.str
    end
    return #a.str < #b.str
  end)

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
    if not quiet and config.options.notify.not_found then notify.info('No opposite word found', cursor) end
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
