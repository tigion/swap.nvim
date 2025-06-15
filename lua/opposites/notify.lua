---@class opposites.Notify
local M = {}

---Displays a notification to the user.
---@param message string
---@param level? number -- vim.log.levels
local function notify(message, level)
  level = level or vim.log.levels.INFO
  vim.notify(message, level, { title = 'Opposites' })
end

---Displays a info notification.
---@param message string
function M.info(message) notify(message, vim.log.levels.INFO) end

---Displays a warning notification.
---@param message string
function M.warn(message) notify(message, vim.log.levels.WARN) end

---Displays a error notification.
---@param message string
function M.error(message) notify(message, vim.log.levels.ERROR) end

return M
