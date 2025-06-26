local config = require('opposites.config')
local notify = require('opposites.notify')
local core = require('opposites.core')
local util = require('opposites.util')

local opposites = require('opposites.opposites')
local cases = require('opposites.cases')
local chains = require('opposites.chains')

---@class opposites
local M = {}

-- Exports the module.
-- So `Opposites.switch()` can be used instead of `require('opposites').switch()`.
-- This only works after the plugin is loaded/required.
-- _G.Opposites = M

---@class opposites.Cursor
---@field row integer
---@field col integer

---@class opposites.Result
---@field str string The found string.
---@field new_str string The new string.
---@field start_idx integer The start index of the string in the line.
---@field cursor opposites.Cursor The cursor position.
---@field module string The module name.

---@alias opposites.Results opposites.Result[]

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

---Uses the given module to get the results.
---@param module? opposites.ConfigModule The module to use.
---@param line string The current line string.
---@param cursor opposites.Cursor The current cursor position.
---@param quiet? boolean Whether to quiet the notifications.
---@return opposites.Results # The found results.
local function use_module(module, line, cursor, quiet)
  quiet = quiet or false
  local results = {}

  if module == nil then
    -- Uses all allowed modules.
    local allowed_modules = config.options.all.modules or {}
    for _, m in ipairs(allowed_modules) do
      local module_results = use_module(m, line, cursor, true)
      if module_results ~= nil then util.table.append(results, module_results) end
    end
    if #results < 1 then
      -- No results found.
      if config.options.notify.not_found then notify.info('Nothing supported found', cursor) end
    elseif not quiet and config.options.notify.found then
      -- Results found.
      local new_strs = {}
      for _, result in ipairs(results) do
        table.insert(new_strs, result.new_str)
      end
      notify.info(results[1].str .. ' -> ' .. table.concat(new_strs, ', '), cursor)
    end
  elseif module == 'opposites' then
    -- Uses the opposites module.
    results = opposites.get_results(line, cursor, quiet)
  elseif module == 'cases' then
    -- Uses the cases module.
    results = cases.get_results(line, cursor, quiet)
  elseif module == 'chains' then
    -- Uses the chains module.
    results = chains.get_results(line, cursor, quiet)
  end

  return results
end

---Switches string under the cursor with the given module.
---@param module? opposites.ConfigModule The module to use.
local function switch(module)
  -- Gets the current line string and the current cursor position.
  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local cursor = { row = row, col = col } ---@type opposites.Cursor

  -- Checks the max allowed line length.
  local line_length = line:len()
  local max_line_length = config.options.max_line_length
  if line_length ~= 0 and line_length > max_line_length then
    notify.error('Line too long: ' .. line_length .. ' (max: ' .. max_line_length .. ')')
    return
  end

  -- Gets the results of the used module.
  local results = use_module(module, line, cursor)
  -- Handles the results to replace the string in the current line.
  core.handle_results(results)
end

-- All
M.switch = switch

-- Opposites
M.opposites = {
  switch = function() switch('opposites') end,
}

-- Cases
M.cases = {
  switch = function() switch('cases') end,
}

-- Chains
M.chains = {
  switch = function() switch('chains') end,
}

return M
