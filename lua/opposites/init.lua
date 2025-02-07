local notify = require('opposites.notify')
local config = require('opposites.config')
local opposite = require('opposites.opposite')

---@class opposites
local M = {}

---@param opts? opposites.Config
function M.setup(opts)
  -- Checks the supported neovim version.
  if vim.fn.has('nvim-0.10') == 0 then
    notify.error('Requires Neovim >= 0.10')
    return
  end

  -- Setups the plugin.
  config.setup(opts)
end

M.switch = opposite.switch_word_to_opposite_word

return M
