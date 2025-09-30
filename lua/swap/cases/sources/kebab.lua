---Parses kebab_case or SCREAMING_KEBAB_CASE.
---
---Each part:
---- Starts with one or more lowercase letters `%l+`
---- Followed by one or more digits `%d*`
---
---Each part (SCREAMING):
---- Starts with one or more uppercase letters `%u+`
---- Followed by one or more digits `%d*`
---
---Parts are separated by one hyphen `-`.
---
---@param word string
---@param case_id swap.ConfigCasesId
---@param scream boolean
local function parse(word, case_id, scream)
  local part_pattern = scream and '%u+%d*' or '%l+%d*'
  local parts, last_after = {}, nil
  for before, part, after in word:gmatch('(%-*)([^%-]+)(%-*)') do
    if #before > 0 or not part:match('^' .. part_pattern .. '$') or #after > 1 then return false end
    parts[#parts + 1] = part
    last_after = after
  end
  if #last_after > 0 then return false end
  return { parts = parts, case_type_id = case_id }
end

---Converts to kebab_case or SCREAMING_KEBAB_CASE.
---@param parts string[]
---@param scream boolean
local function convert(parts, scream)
  local result = table.concat(parts or {}, '-')
  result = scream == true and result:upper() or result:lower()
  return result
end

---@type swap.ConfigCasesId
local id = 'kebab'

---@type swap.CasesSource
local M = {
  id = id,
  name = 'kebab-case',
  parser = function(word) return parse(word, id, false) end,
  converter = function(parts) return convert(parts, false) end,
}

---@type swap.ConfigCasesId
local id_screaming = 'screaming_' .. id

M.screaming = {
  id = id_screaming,
  name = 'SCREAMING-KEBAB-CASE',
  parser = function(word) return parse(word, id_screaming, true) end,
  converter = function(parts) return convert(parts, true) end,
}

return M
