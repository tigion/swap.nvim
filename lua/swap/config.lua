---@class swap.config
local M = {}

---@alias swap.ConfigModule
--- | 'opposites'
--- | 'cases'
--- | 'chains'
--- | 'todos'
---@alias swap.ConfigOppositesWords table<string, string>
---@alias swap.ConfigOppositesWordsByFt table<string, swap.ConfigOppositesWords>
---@alias swap.ConfigChainsWords string[][]
---@alias swap.ConfigChainsWordsByFt table<string, swap.ConfigChainsWords>
---@alias swap.ConfigCasesId
--- | 'snake' snake_case
--- | 'screaming_snake' SCREAMING_SNAKE_CASE
--- | 'kebab' kebab-case
--- | 'screaming_kebab' SCREAMING-KEBAB-CASE
--- | 'camel' camelCase
--- | 'pascal' PascalCase
---@alias swap.ConfigCasesTypes swap.ConfigCasesId[]

---@class swap.ConfigAll
---@field modules? swap.ConfigModule[] The default modules to use.

---@class swap.ConfigOpposites
---@field use_case_sensitive_mask? boolean Whether to use a case sensitive mask.
---@field use_default_words? boolean Whether to use the default opposites.
---@field use_default_words_by_ft? boolean Whether to use the default opposites by file type.
---@field words? swap.ConfigOppositesWords The words with their opposite words.
---@field words_by_ft? swap.ConfigOppositesWordsByFt The file type specific words with their opposite words.

---@class swap.ConfigChains
---@field use_case_sensitive_mask? boolean Whether to use a case sensitive mask.
---@field words? swap.ConfigChainsWords The word chains to search for.
---@field words_by_ft? swap.ConfigChainsWordsByFt The file type specific word chains to search for.

---@class swap.ConfigCases
---@field types? swap.ConfigCasesTypes The allowed case types to parse.

---@class swap.ConfigNotify
---@field found? boolean Whether to notify when a word is found.
---@field not_found? boolean Whether to notify when no word is found.

---@class swap.Config
---@field max_line_length? integer The maximum line length to search.
---@field ignore_overlapping_matches? boolean Whether to ignore overlapping matches.
---@field all? swap.ConfigAll The options for all modules.
---@field opposites? swap.ConfigOpposites The options for the opposites.
---@field cases? swap.ConfigCases The options for the cases.
---@field chains? swap.ConfigChains The options for the chains.
---@field notify? swap.ConfigNotify The notifications to show.

---@type swap.Config
local defaults = {
  max_line_length = 1000,
  ignore_overlapping_matches = true,
  all = {
    modules = { 'opposites', 'todos' },
  },
  opposites = {
    use_case_sensitive_mask = true,
    use_default_words = true,
    use_default_words_by_ft = true,
    words = {
      ['enable'] = 'disable',
      ['true'] = 'false',
      ['yes'] = 'no',
      ['on'] = 'off',
      ['and'] = 'or',
      ['left'] = 'right',
      ['up'] = 'down',
      ['min'] = 'max',
      ['=='] = '!=',
      ['<='] = '>=',
      ['<'] = '>',
    },
    words_by_ft = {
      ['lua'] = {
        ['=='] = '~=',
      },
      ['sql'] = {
        ['asc'] = 'desc',
      },
    },
  },
  chains = {
    use_case_sensitive_mask = true,
    words = {}, -- Empty by default. Will be overwritten by the user configuration.
    words_by_ft = {}, -- Empty by default. Will be overwritten by the user configuration.
  },
  cases = {
    types = {
      'snake',
      'screaming_snake',
      'kebab',
      'screaming_kebab',
      'camel',
      'pascal',
    },
  },
  notify = {
    found = false,
    not_found = true,
  },
}

---Sets the default config
---@type swap.Config
M.options = vim.deepcopy(defaults) -- Preserves the original defaults.

---Cleans up redundant opposite words.
---@param words swap.ConfigOppositesWords
---@return swap.ConfigOppositesWords
local function cleanup_opposite_words(words)
  for w, ow in pairs(words) do
    if w == words[w] then
      words[w] = nil
    elseif words[ow] and words[ow] == w then
      words[ow] = nil
    end
  end
  return words
end

---Cleans up redundant opposite words by ft.
---@param words swap.ConfigOppositesWordsByFt
---@return swap.ConfigOppositesWordsByFt
local function cleanup_opposite_words_by_ft(words)
  for _, opposites in pairs(words) do
    opposites = cleanup_opposite_words(opposites)
  end
  return words
end

---Setups the plugin.
---@param opts? swap.Config
function M.setup(opts)
  opts = opts or {}

  -- Clears the default opposite words if the user doesn't want to use them.
  if opts.opposites.use_default_words == false then defaults.opposites.words = {} end
  if opts.opposites.use_default_words_by_ft == false then defaults.opposites.words_by_ft = {} end

  -- Merges the user config with the default config.
  M.options = vim.tbl_deep_extend('force', defaults, opts or {})

  -- Cleans up redundant opposite words.
  M.options.opposites.words = cleanup_opposite_words(M.options.opposites.words)
  M.options.opposites.words_by_ft = cleanup_opposite_words_by_ft(M.options.opposites.words_by_ft)

  -- TODO: check all config values
end

---Returns the merged opposites words from the default and
---the current file type specific ones.
---@return swap.ConfigOppositesWords
function M.get_opposite_words_by_ft()
  local words = M.options.opposites.words or {}
  local words_by_ft = M.options.opposites.words_by_ft or {}
  local filetype = vim.bo.filetype
  if words_by_ft[filetype] then
    -- Adds or replaces file type-dependent opposites.
    words = vim.tbl_deep_extend('force', words, words_by_ft[filetype])
    -- Cleans up redundant opposite words.
    words = cleanup_opposite_words(words)
  end
  return words
end

---Returns the combined word chains of the default and
---the current file type specific ones.
---@return swap.ConfigChainsWords
function M.get_word_chains_by_ft()
  local word_chains = vim.deepcopy(M.options.chains.words) or {}
  local word_chains_by_ft = M.options.chains.words_by_ft[vim.bo.filetype]
  if word_chains_by_ft then vim.list_extend(word_chains, word_chains_by_ft) end
  return word_chains
end

return M
