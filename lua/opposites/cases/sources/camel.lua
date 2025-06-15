---@type opposites.ConfigCasesIDs
local id = 'camel'

---@type opposites.CasesSource
local M = {
  id = id,
  name = 'camelCase',

  -- Parses camelCase.
  parser = function(word)
    local parts = {}
    local part, tail = word:match('^(%l+%d*)(.+)')
    if part then
      table.insert(parts, part)
      while tail ~= nil and tail ~= '' do
        part, tail = tail:match('^(%u%l+%d*)(.*)')
        if part == nil then return false end
        table.insert(parts, part)
      end
      return { parts = parts, case_type_id = id }
    end
    return false
  end,

  -- Converts to camelCase.
  converter = function(parts)
    parts = parts or {}
    for i, part in ipairs(parts) do
      if i == 1 then
        parts[i] = part:lower()
      else
        parts[i] = part:sub(1, 1):upper() .. part:sub(2):lower()
      end
    end
    return table.concat(parts, '')
  end,
}

return M
