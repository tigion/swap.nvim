---@class opposites.Notify
local M = {}

---Escapes special characters in a string.
---@param escaped_str string
---@return string
local function escape_special_chars(escaped_str)
  escaped_str = string.gsub(escaped_str, '%[', '\\[') -- `[` -> `\[`
  return escaped_str
end

---Displays a notification to the user.
---@param message string
---@param level? number -- vim.log.levels
---@param cursor? opposites.Cursor
local function notify(message, level, cursor)
  level = level or vim.log.levels.INFO
  if cursor ~= nil then
    local row_col_str = '[' .. cursor.row .. ':' .. cursor.col + 1 .. ']'
    message = row_col_str .. ' ' .. escape_special_chars(message)
  end
  vim.notify(message, level, { title = 'Opposites' })
end

---Displays a info notification.
---@param message string
---@param cursor? opposites.Cursor
function M.info(message, cursor) notify(message, vim.log.levels.INFO, cursor) end

---Displays a warning notification.
---@param message string
---@param cursor? opposites.Cursor
function M.warn(message, cursor) notify(message, vim.log.levels.WARN, cursor) end

---Displays a error notification.
---@param message string
---@param cursor? opposites.Cursor
function M.error(message, cursor) notify(message, vim.log.levels.ERROR, cursor) end

return M
