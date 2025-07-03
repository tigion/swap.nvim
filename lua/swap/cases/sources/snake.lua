---@type swap.ConfigCasesId
local id = 'snake'

---@type swap.CasesSource
local M = {
  id = id,
  name = 'snake_case',

  -- Parses snake_case.
  parser = function(word)
    local parts = {}
    local part, tail = word:match('^(%l+%d*)(.+)')
    if part then
      table.insert(parts, part)
      while tail ~= nil and tail ~= '' do
        part, tail = tail:match('^_(%l+%d*)(.*)')
        if part == nil then return false end
        table.insert(parts, part)
      end
      return { parts = parts, case_type_id = id }
    end
    return false
  end,

  -- Converts to snake_case or SCREAMING_SNAKE_CASE.
  converter = function(parts, scream)
    local result = table.concat(parts or {}, '_')
    result = scream == true and result:upper() or result:lower()
    return result
  end,
}

---@type swap.ConfigCasesId
local id_screaming = 'screaming_' .. id

M.screaming = {
  id = id_screaming,
  name = 'SCREAMING_SNAKE_CASE',

  -- Parses SCREAMING_SNAKE_CASE.
  parser = function(word)
    local parts = {}
    local part, tail = word:match('^(%u+%d*)(.+)')
    if part then
      table.insert(parts, part)
      while tail ~= nil and tail ~= '' do
        part, tail = tail:match('^_(%u+%d*)(.*)')
        if part == nil then return false end
        table.insert(parts, part)
      end
      return { parts = parts, case_type_id = id_screaming }
    end
    return false
  end,

  -- Converts to SCREAMING_SNAKE_CASE.
  converter = function(parts) return M.converter(parts, true) end,
}

return M
