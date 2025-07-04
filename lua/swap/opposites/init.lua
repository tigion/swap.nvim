local config = require('swap.config')
local core = require('swap.core')
local notify = require('swap.notify')
local util = require('swap.util')

---@class swap.opposites
local M = {}

---Returns the results for the words found or their opposite
---in the given line near the given column.
---@param line string The line string to search in.
---@param cursor swap.Cursor The cursors position.
---@return swap.Results # The found results.
local function find_results(line, cursor)
  local words = config.get_opposite_words_by_ft()
  local results = {} ---@type swap.Results

  -- Finds the word or the opposite word in the line.
  for w, ow in pairs(words) do
    for _, v in ipairs({ { w, ow }, { ow, w } }) do
      local word, opposite_word = v[1], v[2]

      -- Uses a case sensitive mask if the option is activated and
      -- the word or the opposite word contains no uppercase letters.
      local use_mask = false
      if
        config.options.opposites.use_case_sensitive_mask
        and not (util.mask.has_uppercase(word) or util.mask.has_uppercase(opposite_word))
      then
        use_mask = true
      end

      -- Finds the start indexes of the word in the line.
      local start_idxs = core.find_str_in_line(use_mask and line:lower() or line, cursor, word)

      -- Iterates over the found start indexes.
      for match_idx, start_idx in ipairs(start_idxs) do
        -- Applies the case sensitive mask if the option is activated.
        if use_mask then
          -- Gets the original word.
          word = string.sub(line, start_idx, start_idx + #word - 1)
          local mask = util.mask.get_case_sensitive_mask(word)
          opposite_word = util.mask.apply_case_sensitive_mask(opposite_word, mask)
        end

        -- Adds the result to the results list.
        table.insert(results, {
          str = word,
          new_str = opposite_word,
          start_idx = start_idx,
          cursor = cursor,
          module = 'opposites',
          opts = {
            -- Sets the match index if there are overlapping matches.
            overlapping_match_idx = (#start_idxs > 1 and match_idx or nil),
          },
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
