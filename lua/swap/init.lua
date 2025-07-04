local config = require('swap.config')
local notify = require('swap.notify')
local core = require('swap.core')

local opposites = require('swap.opposites')
local cases = require('swap.cases')
local chains = require('swap.chains')
local todos = require('swap.todos')

---@class opposites
local M = {}

-- Exports the module.
-- So `Swap.switch()` can be used instead of `require('swap').switch()`.
-- This only works after the plugin is loaded/required.
-- _G.Swap = M

---@class swap.Cursor
---@field row integer
---@field col integer

---@class swap.ResultOpts
---@field cursor_outside? boolean The cursor can be outside the new string.
---@field overlapping_match_idx? integer The index of overlapping matches for the same string.

---@class swap.Result
---@field str string The found string.
---@field new_str string The new string.
---@field start_idx integer The start index of the string in the line.
---@field cursor swap.Cursor The cursor position.
---@field module string The module name.
---@field opts? swap.ResultOpts The options for the result.

---@alias swap.Results swap.Result[]

---@param opts? swap.Config
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
---@param module? swap.ConfigModule The module to use.
---@param line string The current line string.
---@param cursor swap.Cursor The current cursor position.
---@param quiet? boolean Whether to quiet the notifications.
---@return swap.Results # The found results.
local function use_module(module, line, cursor, quiet)
  quiet = quiet or false
  local results = {}

  if module == nil then
    -- Uses all allowed modules.
    local allowed_modules = config.options.all.modules or {}
    for _, m in ipairs(allowed_modules) do
      local module_results = use_module(m, line, cursor, true)
      if module_results ~= nil then vim.list_extend(results, module_results) end
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
  elseif module == 'todos' then
    -- Uses the todos module.
    results = todos.get_results(line, cursor, quiet)
  end

  return results
end

---Switches string under the cursor with the given module.
---@param module? swap.ConfigModule The module to use.
local function switch(module)
  -- Gets the current line string and the current cursor position.
  local line = vim.api.nvim_get_current_line()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  local cursor = { row = row, col = col } ---@type swap.Cursor

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

-- Chains
M.chains = {
  switch = function() switch('chains') end,
}

-- Cases
M.cases = {
  switch = function() switch('cases') end,
}

-- Todos
M.todos = {
  switch = function() switch('todos') end,
}

return M
