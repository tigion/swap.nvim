---@class opposites.util
local M = {}

M.table = {}

---Returns the length of a table.
---@param table table
---@return number
function M.table.length(table)
  local count = 0
  for _ in pairs(table) do
    count = count + 1
  end
  return count
end

---Appends values to a table (array).
---@param table any[] -- table
---@param values any[] -- table
function M.table.append(table, values)
  for _, v in ipairs(values) do
    table[#table + 1] = v
    -- table.insert(table, v)
  end
end

return M
