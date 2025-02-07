---@class opposites.config
local M = {}

---@class opposites.Config -- opposites.config.config
---@field max_line_length? integer The maximum line length to search.
---@field opposites? table<string, string> The words with their opposite.
---@field notify? opposites.Config.notify The notifications to show.

---@class opposites.Config.notify
---@field found? boolean Whether to notify when a word is found.
---@field not_found? boolean Whether to notify when no word is found.

---@type opposites.Config
M.config = {
  max_line_length = 1000,
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
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})

  -- TODO: check config values
end

return M
