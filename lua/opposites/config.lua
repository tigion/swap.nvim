---@class opposites.config
local M = {}

---@alias opposites.ConfigOppositesWords table<string, string>
---@alias opposites.ConfigOppositesWordsByFt table<string, opposites.ConfigOppositesWords>

---@class opposites.ConfigOpposites
---@field enabled? boolean Whether to enable the opposites module.
---@field use_case_sensitive_mask? boolean Whether to use a case sensitive mask.
---@field use_default_words? boolean Whether to use the default opposites.
---@field use_default_words_by_ft? boolean Whether to use the default opposites.
---@field words? opposites.ConfigOppositesWords The words with their opposite words.
---@field words_by_ft? opposites.ConfigOppositesWordsByFt The file type specific words with their opposite words.

---@alias opposites.ConfigCasesId
--- | 'snake' snake_case
--- | 'screaming_snake' SCREAMING_SNAKE_CASE
--- | 'kebab' kebab-case
--- | 'screaming_kebab' SCREAMING-KEBAB-CASE
--- | 'camel' camelCase
--- | 'pascal' PascalCase
---@alias opposites.ConfigCasesTypes table<opposites.ConfigCasesId>

---@class opposites.ConfigCases
---@field enabled? boolean Whether to enable the cases module.
---@field types? opposites.ConfigCasesTypes The allowed case types to parse.

---@class opposites.ConfigNotify
---@field found? boolean Whether to notify when a word is found.
---@field not_found? boolean Whether to notify when no word is found.

---@class opposites.Config -- opposites.config.config
---@field max_line_length? integer The maximum line length to search.
---@field opposites? opposites.ConfigOpposites The options for the opposites.
---@field cases? opposites.ConfigCases The options for the cases.
---@field notify? opposites.ConfigNotify The notifications to show.

---@type opposites.Config
local defaults = {
  max_line_length = 1000,
  opposites = {
    enabled = true,
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
  cases = {
    enabled = true,
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

---@type opposites.Config
M.options = defaults -- vim.deepcopy(defaults)

---Cleans up redundant opposite words.
---@param words opposites.ConfigOppositesWords
---@return opposites.ConfigOppositesWords
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
---@param words opposites.ConfigOppositesWordsByFt
---@return opposites.ConfigOppositesWordsByFt
local function cleanup_opposite_words_by_ft(words)
  for _, opposites in pairs(words) do
    opposites = cleanup_opposite_words(opposites)
  end
  return words
end

---Setups the plugin.
---@param opts? opposites.Config
function M.setup(opts)
  opts = opts or {}

  -- Clears the default opposites if the user doesn't want to use them.
  if opts.opposites.use_default_words == false then M.options.opposites.words = {} end
  if opts.opposites.use_default_words_by_ft == false then M.options.opposites.words_by_ft = {} end

  -- Merges the user config with the default config.
  M.options = vim.tbl_deep_extend('force', defaults, opts or {})

  -- Cleans up redundant opposite words.
  M.options.opposites.words = cleanup_opposite_words(M.options.opposites.words)
  M.options.opposites.words_by_ft = cleanup_opposite_words_by_ft(M.options.opposites.words_by_ft)

  -- TODO: check all config values
end

---Returns the merged opposites words from the default and
---the current file type specific ones.
---@return opposites.ConfigOppositesWords
function M.merge_opposite_words()
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

return M
