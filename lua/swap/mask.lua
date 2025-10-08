---@class swap.mask
local M = {}

---Returns true if the given word has uppercase characters.
---@param word string The word to check.
---@return boolean # True if the word has uppercase characters.
function M.has_uppercase(word)
  for i = 1, #word do
    local c = word:sub(i, i)
    if c:lower() ~= c:upper() and c == c:upper() then return true end
  end
  return false
  -- return string.find(word, '%u') ~= nil
end

---Returns true if at least one word in the array of words has uppercase letters.
---@param words string[] The words to check.
---@return boolean # True if at least one word has uppercase letters.
function M.has_uppercase_words(words)
  for _, word in ipairs(words) do
    if M.has_uppercase(word) then return true end
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
function M.get_case_sensitive_mask(word)
  -- Lower or upper case.
  if word == word:lower() then
    return false
  elseif word == word:upper() then
    return true
  end
  -- Mixed case.
  local mask = word:gsub('.', function(c) return c:lower() == c and 'x' or 'X' end)
  return mask
end

---Returns the word with the applied case sensitive mask.
---@param word string The word to apply the mask to.
---@param mask string|boolean The case sensitive mask.
---@return string # The word with the applied case sensitive mask.
function M.apply_case_sensitive_mask(word, mask)
  -- Apply upper or lower case.
  if type(mask) == 'boolean' then return mask and word:upper() or word:lower() end
  -- Apply mixed case.
  local new_word_parts = {}
  for i = 1, #word do
    local c = word:sub(i, i)
    new_word_parts[i] = (mask:sub(i, i) == 'X' and c:upper() or c:lower())
  end
  return table.concat(new_word_parts)
end

return M
