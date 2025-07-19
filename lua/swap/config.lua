local validation = require('swap.validation')

---@class swap.config
local M = {}

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

---Setups the plugin.
---@param opts? swap.Config
function M.setup(opts)
  opts = opts or {}

  -- Clears the default opposite words if the user doesn't want to use them.
  local new_defaults = vim.deepcopy(defaults)
  if opts.opposites then
    if opts.opposites.use_default_words == false then new_defaults.opposites.words = {} end
    if opts.opposites.use_default_words_by_ft == false then new_defaults.opposites.words_by_ft = {} end
  end

  -- Merges the user config with the default config.
  M.options = vim.tbl_deep_extend('force', new_defaults, opts or {})

  -- Validates options types.
  validation.validate_types(M.options)

  -- Cleans up.
  M.options.all.modules = validation.cleanup_modules(M.options.all.modules)
  M.options.opposites.words = validation.cleanup_opposite_words(M.options.opposites.words)
  M.options.opposites.words_by_ft = validation.cleanup_opposite_words_by_ft(M.options.opposites.words_by_ft)
  M.options.chains.words = validation.cleanup_word_chains(M.options.chains.words)
  M.options.chains.words_by_ft = validation.cleanup_word_chains_by_ft(M.options.chains.words_by_ft)
  M.options.cases.types = validation.cleanup_case_types(M.options.cases.types)
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
    -- Cleans up opposite words.
    words = validation.cleanup_opposite_words(words)
  end
  return words
end

---Returns the combined word chains of the default and
---the current file type specific ones.
---@return swap.ConfigChainsWords
function M.get_word_chains_by_ft()
  local word_chains = vim.deepcopy(M.options.chains.words) or {}
  local word_chains_by_ft = M.options.chains.words_by_ft[vim.bo.filetype]
  if word_chains_by_ft then
    -- Adds file type-dependent word chains.
    vim.list_extend(word_chains, word_chains_by_ft)
    -- Cleans up word chains.
    word_chains = validation.cleanup_word_chains(word_chains)
  end
  return word_chains
end

return M
