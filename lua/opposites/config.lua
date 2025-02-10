---@class opposites.config
local M = {}

---@class opposites.Config -- opposites.config.config
---@field max_line_length? integer The maximum line length to search.
---@field use_default_opposites? boolean Whether to use the default opposites.
---@field use_default_opposites_by_ft? boolean Whether to use the default opposites.
---@field opposites? opposites.Config.opposites The words with their opposite.
---@field opposites_by_ft? opposites.Config.opposites_by_ft The file type specific words with their opposite.
---@field notify? opposites.Config.notify The notifications to show.

---@alias opposites.Config.opposites table<string, string>
---@alias opposites.Config.opposites_by_ft table<string, opposites.Config.opposites>

---@class opposites.Config.notify
---@field found? boolean Whether to notify when a word is found.
---@field not_found? boolean Whether to notify when no word is found.

---@type opposites.Config
local defaults = {
  max_line_length = 1000,
  use_default_opposites = true,
  use_default_opposites_by_ft = true,
  opposites = {
    ['enable'] = 'disable',
    ['true'] = 'false',
    ['True'] = 'False',
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
  opposites_by_ft = {
    ['lua'] = {
      ['=='] = '~=',
    },
    ['sql'] = {
      ['AND'] = 'OR',
      ['ASC'] = 'DESC',
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
---
---@param opposites opposites.Config.opposites
---@return opposites.Config.opposites
local function cleanup_redundant_opposites(opposites)
  for w, ow in pairs(opposites) do
    if w == opposites[w] then
      opposites[w] = nil
    elseif opposites[ow] and opposites[ow] == w then
      opposites[ow] = nil
    end
  end
  return opposites
end

---Cleans up redundant opposite words by ft.
---
---@param opposites_by_ft opposites.Config.opposites_by_ft
---@return opposites.Config.opposites_by_ft
local function cleanup_redundant_opposites_by_ft(opposites_by_ft)
  for _, opposites in pairs(opposites_by_ft) do
    opposites = cleanup_redundant_opposites(opposites)
  end
  return opposites_by_ft
end

---Setups the plugin.
---
---@param opts? opposites.Config
function M.setup(opts)
  opts = opts or {}

  -- Clears the default opposites if the user doesn't want to use them.
  if opts.use_default_opposites == false then M.options.opposites = {} end
  if opts.use_default_opposites_by_ft == false then M.options.opposites_by_ft = {} end

  -- Merges the user config with the default config.
  M.options = vim.tbl_deep_extend('force', defaults, opts or {})

  -- Cleans up redundant opposite words.
  M.options.opposites = cleanup_redundant_opposites(M.options.opposites)
  M.options.opposites_by_ft = cleanup_redundant_opposites_by_ft(M.options.opposites_by_ft)

  -- TODO: check all config values
end

---Returns the merged opposites words from the default and
---current file type specific ones.
---
---@return opposites.Config.opposites
function M.get_opposites()
  local opposites = M.options.opposites or {}
  local opposites_by_ft = M.options.opposites_by_ft or {}
  local filetype = vim.bo.filetype
  if opposites_by_ft[filetype] then
    -- Adds or replaces file type-dependent opposites.
    opposites = vim.tbl_deep_extend('force', opposites, opposites_by_ft[filetype])
    -- Cleans up redundant opposite words.
    opposites = cleanup_redundant_opposites(opposites)
  end
  return opposites
end

return M
