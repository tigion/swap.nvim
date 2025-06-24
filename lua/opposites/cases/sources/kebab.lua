---@type opposites.ConfigCasesId
local id = 'kebab'

---@type opposites.CasesSource
local M = {
  id = id,
  name = 'kebab-case',

  -- Parses kebab-case.
  parser = function(word)
    local parts = {}
    local part, tail = word:match('^(%l+%d*)(.+)')
    if part then
      table.insert(parts, part)
      while tail ~= nil and tail ~= '' do
        part, tail = tail:match('^%-(%l+%d*)(.*)')
        if part == nil then return false end
        table.insert(parts, part)
      end
      return { parts = parts, case_type_id = id }
    end
    return false
  end,

  -- Converts to kebab-case or SCREAMING-KEBAB-CASE.
  converter = function(parts, scream)
    parts = parts or {}
    local result = table.concat(parts, '-')
    result = scream == true and result:upper() or result:lower()
    return result
  end,
}

---@type opposites.ConfigCasesId
local id_screaming = 'screaming_' .. id

M.screaming = {
  id = id_screaming,
  name = 'SCREAMING-KEBAB-CASE',

  -- Parses SCREAMING-KEBAB-CASE.
  parser = function(word)
    local parts = {}
    local part, tail = word:match('^(%u+%d*)(.+)')
    if part then
      table.insert(parts, part)
      while tail ~= nil and tail ~= '' do
        part, tail = tail:match('^%-(%u+%d*)(.*)')
        if part == nil then return false end
        table.insert(parts, part)
      end
      return { parts = parts, case_type_id = id_screaming }
    end
    return false
  end,

  -- Converts to SCREAMING-KEBAB-CASE.
  converter = function(parts) return M.converter(parts, true) end,
}

return M
