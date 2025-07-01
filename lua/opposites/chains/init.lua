local config = require('opposites.config')
local notify = require('opposites.notify')

local opposites_util = require('opposites.opposites.util')

---@class opposites.chains
local M = {}

---Returns the combined word chains of the default and
---the current file type specific ones.
---@return opposites.ConfigChainsWords
local function get_word_chains()
  local word_chains = vim.deepcopy(config.options.chains.words) or {}
  local word_chains_by_ft = config.options.chains.words_by_ft[vim.bo.filetype]
  if word_chains_by_ft then vim.list_extend(word_chains, word_chains_by_ft) end
  return word_chains
end

---Checks if the words in the word chain contain uppercase letters.
---@param word_chain string[]
---@return boolean
local function has_uppercase_words(word_chain)
  for _, word in ipairs(word_chain) do
    if opposites_util.has_uppercase(word) then return true end
  end
  return false
end

---Returns the results for the words found or their opposite
---in the given line near the given column.
---@param line string The line string to search in.
---@param cursor opposites.Cursor The cursors position.
---@return opposites.Results # The found results.
local function find_results(line, cursor)
  local results = {} ---@type opposites.Results
  local word_chains = get_word_chains()

  -- Iterates over the word chains.
  for _, word_chain in ipairs(word_chains) do
    -- Ignores word chains with less than 2 words.
    if #word_chain < 2 then break end

    -- Uses a case sensitive mask if the option is activated and
    -- the words in the word chain contains no uppercase letters.
    local use_mask = false
    if config.options.chains.use_case_sensitive_mask and not has_uppercase_words(word_chain) then use_mask = true end

    -- Iterates over the words in the word chain.
    for idx, word in ipairs(word_chain) do
      -- Finds the word in the line under the cursor.
      local start_idx, end_idx
      while true do
        -- Finds the word in the line.
        start_idx, end_idx = string.find(use_mask and line:lower() or line, word, (end_idx or 0) + 1, true) -- Uses no pattern matching.
        if start_idx == nil then break end

        -- Uses the word if the cursor is inside it.
        if start_idx <= cursor.col + 1 and end_idx >= cursor.col + 1 then
          -- Gets the next word in the word chain.
          local next_word = word_chain[next(word_chain, idx) or next(word_chain)]

          -- Applies the case sensitive mask if the mask is used.
          if use_mask then
            -- Gets the original word.
            word = string.sub(line, start_idx, start_idx + #word - 1)
            local mask = opposites_util.get_case_sensitive_mask(word)
            next_word = opposites_util.apply_case_sensitive_mask(next_word, mask)
          end

          -- Adds the result to the results list.
          table.insert(results, {
            str = word,
            new_str = next_word,
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
