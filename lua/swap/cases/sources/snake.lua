---Parses snake_case or SCREAMING_SNAKE_CASE.
---
---Each part:
---- Starts with one or more lowercase letters `%l+`
---- Followed by one or more digits `%d*`
---
---Each part (SCREAMING):
---- Starts with one or more uppercase letters `%u+`
---- Followed by one or more digits `%d*`
---
---Parts are separated by one underscore `_`.
---
---@param word string
---@param ct_id swap.ConfigCasesId
---@param scream boolean
local function parse(word, ct_id, scream)
  local part_pattern = scream and '%u+%d*' or '%l+%d*'
  local parts, last_after = {}, nil
  for before, part, after in word:gmatch('(_*)([^_]+)(_*)') do
    if #before > 0 or not part:match('^' .. part_pattern .. '$') or #after > 1 then return false end
    parts[#parts + 1] = part
    last_after = after
  end
  if #last_after > 0 then return false end
  return { parts = parts, case_type_id = ct_id }
end

-- NOTE: Alternative implementation of the parser with `match()` in `while`-loop.
--       Remove later, if it is not needed anymore.
--
-- local function parse_old(word, ct_id, scream)
--   local part_pattern = scream == true and '%u+%d*' or '%l+%d*'
--   local part, tail = word:match('^(' .. part_pattern .. ')(.+)')
--   if not part then return false end
--   local parts = { part }
--   while tail and tail ~= '' do
--     part, tail = tail:match('^_(' .. part_pattern .. ')(.*)')
--     if not part then return false end
--     table.insert(parts, part)
--   end
--   return { parts = parts, case_type_id = ct_id }
-- end

---Converts to snake_case or SCREAMING_SNAKE_CASE.
---@param parts string[]
---@param scream boolean
local function convert(parts, scream)
  local result = table.concat(parts or {}, '_')
  result = scream == true and result:upper() or result:lower()
  return result
end

---@type swap.ConfigCasesId
local id = 'snake'

---@type swap.CasesSource
local M = {
  id = id,
  name = 'snake_case',

  -- Parses snake_case.
  parser = function(word) return parse(word, id, false) end,

  -- Converts to snake_case.
  converter = function(parts) return convert(parts, false) end,
}

---@type swap.ConfigCasesId
local id_screaming = 'screaming_' .. id

M.screaming = {
  id = id_screaming,
  name = 'SCREAMING_SNAKE_CASE',

  -- Parses SCREAMING_SNAKE_CASE.
  parser = function(word) return parse(word, id_screaming, true) end,

  -- Converts to SCREAMING_SNAKE_CASE.
  converter = function(parts) return convert(parts, true) end,
}

return M
