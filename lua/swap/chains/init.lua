local config = require('swap.config')
local core = require('swap.core')
local notify = require('swap.notify')
local util = require('swap.util')

---@class swap.chains
local M = {}

---Returns the results for the words found or their opposite
---in the given line near the given column.
---@param line string The line string to search in.
---@param cursor swap.Cursor The cursors position.
---@return swap.Results # The found results.
local function find_results(line, cursor)
  local results = {} ---@type swap.Results
  local word_chains = config.get_word_chains_by_ft()

  -- Iterates over the word chains.
  for _, word_chain in ipairs(word_chains) do
    -- Ignores word chains with less than 2 words.
    if #word_chain < 2 then break end

    -- Uses a case sensitive mask if the option is activated and
    -- the words in the word chain contains no uppercase letters.
    local use_mask = false
    if config.options.chains.use_case_sensitive_mask and not util.mask.has_uppercase_words(word_chain) then
      use_mask = true
    end

    -- Iterates over the words in the word chain.
    for word_idx, word in ipairs(word_chain) do
      -- Finds the start indexes of the word in the line.
      local start_idxs = core.find_str_in_line(use_mask and line:lower() or line, word, cursor)

      if #start_idxs > 0 then
        -- Gets the next word from the word chain.
        local next_word = word_chain[next(word_chain, word_idx) or next(word_chain)]

        -- Iterates over the found start indexes.
        for match_idx, start_idx in ipairs(start_idxs) do
          -- Applies the case sensitive mask if the mask is used.
          if use_mask then
            -- Gets the original word.
            word = string.sub(line, start_idx, start_idx + #word - 1)
            local mask = util.mask.get_case_sensitive_mask(word)
            next_word = util.mask.apply_case_sensitive_mask(next_word, mask)
          end

          -- Adds the result to the results list.
          table.insert(results, {
            str = word,
            new_str = next_word,
            start_idx = start_idx,
            cursor = cursor,
            module = 'chains',
            opts = {
              -- Sets the match index if there are overlapping matches.
              overlapping_match_idx = (#start_idxs > 1 and match_idx or nil),
            },
          })
        end
      end
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
