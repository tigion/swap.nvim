---@type swap.ConfigCasesId
local id = 'pascal'

---@type swap.CasesSource
local M = {
  id = id,
  name = 'PascalCase',

  -- Parses PascalCase.
  --
  -- Each part:
  -- - Default case:
  --   - Starts with one uppercase letter (%u)
  --   - Followed by one or more lowercase letters or digits ([%l%d]+)
  -- - Special case for acronyms:
  --   - Has two or more uppercase letters (%u%u+)
  --   - Optionally followed by one or more digits (%d*)
  -- - Special case for last part:
  --   - Has only one uppercase letter (%u)
  --
  parser = function(word)
    local parts, initial_idx = {}, 1
    while initial_idx <= #word do
      -- Handles default case.
      local part_start, part_end = word:find('^%u[%l%d]+', initial_idx)
      if part_start then
        -- Adds the found part to the parts list.
        parts[#parts + 1] = word:sub(part_start, part_end)
        initial_idx = part_end + 1
      else
        -- Handles special case for acronyms and last part.
        local acronym_start, acronym_end = word:find('^%u+', initial_idx)
        if acronym_start then
          -- If the acronym is not only one letter and not at the end of the word,
          -- the last character of the current part is the beginning of the next part.
          if acronym_end ~= acronym_start and acronym_end ~= #word then acronym_end = acronym_end - 1 end
          -- Handles an acronym followed by digits.
          local start_idx, end_idx = word:find('^%u%u+%d+', initial_idx)
          if start_idx then acronym_end = end_idx end
          -- Adds the found part to the parts list.
          parts[#parts + 1] = word:sub(acronym_start, acronym_end)
          initial_idx = acronym_end + 1
        else
          return false
        end
      end
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
