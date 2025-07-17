---@class swap.util
local M = {}

M.table = {}

---Returns the index of the given value in the table
---or nil if not found.
---@param table table
---@param value any
---@return integer?
function M.table.find(table, value)
  for i, v in ipairs(table) do
    if v == value then return i end
  end
  return nil
end

return M
