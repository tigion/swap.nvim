---@class opposites.cases.util
local M = {}

---Returns the length of a table.
---@param t table
---@return number
function M.table_length(t)
  if type(t) ~= 'table' then return -1 end
  local count = 0
  for _ in pairs(t) do
    count = count + 1
  end
  return count
end

return M
