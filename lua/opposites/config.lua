---@class opposites.config
local M = {}

---@class opposites.Config -- opposites.config.config
---@field max_line_length? integer The maximum line length to search.
---@field use_default_opposites? boolean Whether to use the default opposites.
---@field opposites? table<string, string> The words with their opposite.
---@field notify? opposites.Config.notify The notifications to show.

---@class opposites.Config.notify
---@field found? boolean Whether to notify when a word is found.
---@field not_found? boolean Whether to notify when no word is found.

---@type opposites.Config
M.options = {
  max_line_length = 1000,
  use_default_opposites = true,
  opposites = {
    -- stylua: ignore start
    ['enable'] = 'disable',
      ['true'] = 'false',
      ['True'] = 'False',
       ['yes'] = 'no',
        ['on'] = 'off',
      ['left'] = 'right',
        ['up'] = 'down',
       ['min'] = 'max',
        ['=='] = '!=',
        ['<='] = '>=',
         ['<'] = '>',
    -- stylua: ignore end
  },
  notify = {
    found = false,
    not_found = true,
  },
}

---@param opts? opposites.Config
function M.setup(opts)
  opts = opts or {}

  -- Clears the default opposites if the user doesn't want to use them.
  if opts.use_default_opposites == false then M.options.opposites = {} end

  -- Merges the user config with the default config.
  M.options = vim.tbl_deep_extend('force', M.options, opts or {})

  -- TODO: check config values
end

return M
