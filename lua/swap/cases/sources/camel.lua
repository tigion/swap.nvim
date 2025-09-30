---@type swap.ConfigCasesId
local id = 'camel'

---@type swap.CasesSource
local M = {
  id = id,
  name = 'camelCase',

  -- Parses camelCase.
  --
  -- First part:
  -- - Starts with one or more lowercase letters (%l+)
  -- - Followed by one or more digits (%d*)
  --
  -- Each following part:
  -- - Starts with an uppercase letter (%u)
  -- - Followed by one or more lowercase letters (%l+)
  -- - Optionally followed by digits (%d*)
  --
  parser = function(word)
    local part = word:match('^(%l+%d*).+')
    if not part then return false end
    local parts = { part }
    local initial_idx = #part + 1
    while initial_idx <= #word do
      local start_idx, end_idx = word:find('^%u%l+%d*', initial_idx)
      if not start_idx then return false end
      parts[#parts + 1] = word:sub(start_idx, end_idx)
      initial_idx = end_idx + 1
    end
    return { parts = parts, case_type_id = id }
  end,

  -- NOTE: Alternative implementation of the parser with `match()` in `while`-loop.
  --       Remove later, if it is not needed anymore.
  --
  -- parser = function(word)
  --   local part, tail = word:match('^(%l+%d*)(.+)')
  --   if not part then return false end
  --   local parts = { part }
  --   while tail and tail ~= '' do
  --     part, tail = tail:match('^(%u%l+%d*)(.*)')
  --     if not part then return false end
  --     table.insert(parts, part)
  --   end
  --   return { parts = parts, case_type_id = id }
  -- end,

  -- Converts to camelCase.
  converter = function(parts)
    parts = parts or {}
    if #parts == 0 then return '' end
    parts[1] = parts[1]:lower()
    for i = 2, #parts do
      local part = parts[i]
      parts[i] = part:sub(1, 1):upper() .. part:sub(2):lower()
    end
    return table.concat(parts, '')
  end,
}

return M
