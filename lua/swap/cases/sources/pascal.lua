---@type swap.ConfigCasesId
local id = 'pascal'

---@type swap.CasesSource
local M = {
  id = id,
  name = 'PascalCase',

  -- Parses PascalCase.
  --
  -- Each part:
  -- - Starts with an uppercase letter (%u)
  -- - Followed by one or more lowercase letters (%l+)
  -- - Optionally followed by digits (%d*)
  --
  parser = function(word)
    local parts, initial_idx = {}, 1
    while initial_idx <= #word do
      local start_idx, end_idx = word:find('^%u%l+%d*', initial_idx)
      if not start_idx then return false end
      table.insert(parts, word:sub(start_idx, end_idx))
      initial_idx = end_idx + 1
    end
    return { parts = parts, case_type_id = id }
  end,

  -- NOTE: Alternative implementation of the parser with `match()` in `while`-loop.
  --       Remove later, if it is not needed anymore.
  --
  -- parser = function(word)
  --   local parts = {}
  --   local part, tail = nil, word
  --   while tail ~= nil and tail ~= '' do
  --     part, tail = tail:match('^(%u%l*%d*)(.*)')
  --     if part == nil then return false end
  --     table.insert(parts, part)
  --   end
  --   if #parts == 0 then return false end
  --   return { parts = parts, case_type_id = id }
  -- end,

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
