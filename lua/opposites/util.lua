---@class opposites.util
local M = {}

M.mask = {}

---Returns true if the given word has uppercase characters.
---@param word string The word to check.
---@return boolean # True if the word has uppercase characters.
function M.mask.has_uppercase(word)
  for i = 1, #word do
    local c = word:sub(i, i)
    if c:lower() ~= c:upper() and c == c:upper() then return true end
  end
  return false
end

---Returns the case sensitive mask for the given word.
---
---- If the word is lowercase, the mask is false.
---- If the word is uppercase, the mask is true.
---- If the word is mixed case, the mask is a string to represent the case.
---
---@param word string The word to get the mask for.
---@return string|boolean # The case sensitive mask.
function M.mask.get_case_sensitive_mask(word)
  -- Lower or upper case.
  if word == word:lower() then
    return false
  elseif word == word:upper() then
    return true
  end
  -- Mixed case.
  local mask = ''
  for i = 1, #word do
    local c = word:sub(i, i)
    mask = mask .. (c:lower() == c and 'x' or 'X')
  end
  return mask
end

---Returns the word with the applied case sensitive mask.
---@param word string The word to apply the mask to.
---@param mask string|boolean The case sensitive mask.
---@return string # The word with the applied case sensitive mask.
function M.mask.apply_case_sensitive_mask(word, mask)
  -- Apply upper or lower case.
  if mask == true then
    return word:upper()
  elseif mask == false then
    return word:lower()
  end
  -- Apply mixed case.
  local new_word = ''
  for i = 1, #word do
    local c = word:sub(i, i)
    new_word = new_word .. (mask:sub(i, i) == 'X' and c:upper() or c:lower())
  end
  return new_word
end

M.table = {}

---Returns the index of the given value in the table
---or nil if not found.
---@param table table
---@param value any
---@return integer?
function M.table.find(table, value)
  for i, v in ipairs(table) do
    if v == value then return i end
  end
  return nil
end

return M
