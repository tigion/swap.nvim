---@type swap.ConfigCasesId
local id = 'camel'

---@type swap.CasesSource
local M = {
  id = id,
  name = 'camelCase',

  -- Parses camelCase.
  --
  -- First part:
  -- - Starts with one lowercase letters (%l)
  -- - Optionally followed by one or more lowercase letters or digits ([%l%d]*)
  --
  -- Each following part:
  -- - Default case:
  --   - Starts with an uppercase letter (%u)
  --   - Followed by one or more lowercase letters or digits ([%l%d]+)
  -- - Special case for acronyms:
  --   - Has two or more uppercase letters (%u%u+)
  --   - Optionally followed by one or more digits (%d*)
  -- - Special case for last part:
  --   - Has only one uppercase letter (%u)
  --
  parser = function(word)
    -- Handles first part.
    local part = word:match('^(%l[%l%d]*).+')
    if not part then return false end

    local parts = { part }
    local initial_idx = #part + 1
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
          -- Handles an acronym followed by digits (variant 2).
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
