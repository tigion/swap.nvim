---@type swap.ConfigCasesId
local id = 'pascal'

---@type swap.CasesSource
local M = {
  id = id,
  name = 'PascalCase',

  -- Parses PascalCase.
  parser = function(word)
    local parts = {}
    local part, tail = nil, word
    while tail ~= nil and tail ~= '' do
      part, tail = tail:match('^(%u%l+%d*)(.*)')
      if part == nil then return false end
      table.insert(parts, part)
    end
    if #parts == 0 then return false end
    return { parts = parts, case_type_id = id }
  end,

  -- Converts to PascalCase.
  converter = function(parts)
    parts = parts or {}
    for i, part in ipairs(parts) do
      parts[i] = part:sub(1, 1):upper() .. part:sub(2):lower()
    end
    return table.concat(parts, '')
  end,
}

return M
