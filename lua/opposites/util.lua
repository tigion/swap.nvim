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

---Returns the index of the given value in the table
---or nil if not found.
---@param table table
---@param value any
---@return integer|nil
function M.table.find(table, value)
  for i, v in ipairs(table) do
    if v == value then return i end
  end
  return nil
end

return M
