---@class swap.config.validation
local M = {}

---Validates the option types.
---@param opts swap.Config
function M.validate_types(opts)
  vim.validate('options', opts, 'table')
  -- Base
  vim.validate('max_line_length', opts.max_line_length, 'number')
  vim.validate('ignore_overlapping_matches', opts.ignore_overlapping_matches, 'boolean')
  -- All
  vim.validate('all', opts.all, 'table')
  vim.validate('all.modules', opts.all.modules, 'table')
  -- Opposites
  vim.validate('opposites', opts.opposites, 'table')
  vim.validate('opposites.use_case_sensitive_mask', opts.opposites.use_case_sensitive_mask, 'boolean')
  vim.validate('opposites.use_default_words', opts.opposites.use_default_words, 'boolean')
  vim.validate('opposites.use_default_words_by_ft', opts.opposites.use_default_words_by_ft, 'boolean')
  vim.validate('opposites.words', opts.opposites.words, 'table')
  vim.validate('opposites.words_by_ft', opts.opposites.words_by_ft, 'table')
  -- Chains
  vim.validate('chains', opts.chains, 'table')
  vim.validate('chains.use_case_sensitive_mask', opts.chains.use_case_sensitive_mask, 'boolean')
  vim.validate('chains.words', opts.chains.words, 'table')
  vim.validate('chains.words_by_ft', opts.chains.words_by_ft, 'table')
  -- Cases
  vim.validate('cases', opts.cases, 'table')
  vim.validate('cases.types', opts.cases.types, 'table')
  -- Notify
  vim.validate('notify', opts.notify, 'table')
  vim.validate('notify.found', opts.notify.found, 'boolean')
  vim.validate('notify.not_found', opts.notify.not_found, 'boolean')
end

---Cleans up redundant or unsupported modules.
---@param modules swap.ConfigModule[]
---@return swap.ConfigModule[]
function M.cleanup_modules(modules)
  ---@type swap.ConfigModule[]
  local supported_modules = { 'opposites', 'cases', 'chains', 'todos' }
  local cleaned_modules = {}
  for _, module in ipairs(modules) do
    if vim.list_contains(supported_modules, module) and not vim.list_contains(cleaned_modules, module) then
      table.insert(cleaned_modules, module)
    end
  end
  return cleaned_modules
end

---Cleans up redundant opposite words.
---@param words swap.ConfigOppositesWords
---@return swap.ConfigOppositesWords
function M.cleanup_opposite_words(words)
  for w, ow in pairs(words) do
    if w == words[w] then
      -- The key is the same as the value.
      words[w] = nil
    elseif words[ow] and words[ow] == w then
      -- The key/value pair exists also as value/key pair.
      --
      -- NOTE: Removes the smaller key to get consistent results for unit tests
      --       instead only `words[ow] = nil`.
      --       Hash tables are not ordered, so the order of the key/value pairs
      --       is not guaranteed.
      --
      if w <= ow then
        words[ow] = nil
      else
        words[w] = nil
      end
    end
  end
  return words
end

---Cleans up redundant opposite words by ft.
---@param words swap.ConfigOppositesWordsByFt
---@return swap.ConfigOppositesWordsByFt
function M.cleanup_opposite_words_by_ft(words)
  for ft, opposites in pairs(words) do
    -- opposites = M.cleanup_opposite_words(opposites)
    words[ft] = M.cleanup_opposite_words(opposites)
  end
  return words
end

---Cleans up unsupported or redundant words.
---@param words any[]
---@return string[]
local function cleanup_words(words)
  local cleaned_words = {}
  for _, word in ipairs(words) do
    if type(word) == 'string' and word ~= '' and not vim.list_contains(cleaned_words, word) then
      table.insert(cleaned_words, word)
    end
  end
  return cleaned_words
end

---Cleans up unsupported or redundant word chains.
---@param chains swap.ConfigChainsWords
---@return swap.ConfigChainsWords
function M.cleanup_word_chains(chains)
  local cleaned_chains = {}
  for _, words in ipairs(chains) do
    local cleaned_words = cleanup_words(words)
    if
      #cleaned_words > 1
      and not vim.tbl_contains(
        cleaned_chains,
        function(v) return vim.deep_equal(v, cleaned_words) end,
        { predicate = true }
      )
    then
      table.insert(cleaned_chains, cleaned_words)
    end
  end
  return cleaned_chains
end

---Cleans up unsupported or redundant word chains by ft.
---@param chains_by_ft swap.ConfigChainsWordsByFt
---@return swap.ConfigChainsWordsByFt
function M.cleanup_word_chains_by_ft(chains_by_ft)
  for ft, chains in pairs(chains_by_ft) do
    chains_by_ft[ft] = M.cleanup_word_chains(chains)
  end
  return chains_by_ft
end

---Cleans up unsupported or redundant case types.
---@param types swap.ConfigCasesTypes
---@return swap.ConfigCasesTypes
function M.cleanup_case_types(types)
  ---@type swap.ConfigCasesTypes
  local supported_types = { 'snake', 'screaming_snake', 'kebab', 'screaming_kebab', 'camel', 'pascal' }
  local cleaned_types = {}
  for _, type in ipairs(types) do
    if vim.list_contains(supported_types, type) and not vim.list_contains(cleaned_types, type) then
      table.insert(cleaned_types, type)
    end
  end
  return cleaned_types
end

---Test interface for local functions.
---@param func_name string
---@param ... any
---@return any
function M.test(func_name, ...)
  local gateway = {
    cleanup_words = cleanup_words,
  }
  if type(gateway[func_name]) ~= 'function' then
    error("Test interface gateway for function name not found: '" .. func_name .. "'")
  end
  return gateway[func_name](...)
end

return M
