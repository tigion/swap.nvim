---@meta

-- lua/swap/init.lua

---@class swap.Cursor
---@field row integer
---@field col integer

---@class swap.ResultOpts
---@field cursor_outside? boolean The cursor can be outside the new string.
---@field overlapping_match_idx? integer The index of overlapping matches for the same string.

---@class swap.Result
---@field str string The found string.
---@field new_str string The new string.
---@field start_idx integer The start index of the string in the line.
---@field cursor swap.Cursor The cursor position.
---@field module string The module name.
---@field opts? swap.ResultOpts The options for the result.

---@alias swap.Results swap.Result[]

-- lua/swap/config.lua

---@alias swap.ConfigModule
--- | 'opposites'
--- | 'cases'
--- | 'chains'
--- | 'todos'
---@alias swap.ConfigOppositesWords table<string, string>
---@alias swap.ConfigOppositesWordsByFt table<string, swap.ConfigOppositesWords>
---@alias swap.ConfigChainsWords string[][]
---@alias swap.ConfigChainsWordsByFt table<string, swap.ConfigChainsWords>
---@alias swap.ConfigCasesId
--- | 'snake' snake_case
--- | 'screaming_snake' SCREAMING_SNAKE_CASE
--- | 'kebab' kebab-case
--- | 'screaming_kebab' SCREAMING-KEBAB-CASE
--- | 'camel' camelCase
--- | 'pascal' PascalCase
---@alias swap.ConfigCasesTypes swap.ConfigCasesId[]

---@class swap.ConfigAll
---@field modules? swap.ConfigModule[] The default modules to use.

---@class swap.ConfigOpposites
---@field use_case_sensitive_mask? boolean Whether to use a case sensitive mask.
---@field use_default_words? boolean Whether to use the default opposites.
---@field use_default_words_by_ft? boolean Whether to use the default opposites by file type.
---@field words? swap.ConfigOppositesWords The words with their opposite words.
---@field words_by_ft? swap.ConfigOppositesWordsByFt The file type specific words with their opposite words.

---@class swap.ConfigChains
---@field use_case_sensitive_mask? boolean Whether to use a case sensitive mask.
---@field words? swap.ConfigChainsWords The word chains to search for.
---@field words_by_ft? swap.ConfigChainsWordsByFt The file type specific word chains to search for.

---@class swap.ConfigCases
---@field types? swap.ConfigCasesTypes The allowed case types to parse.

---@class swap.ConfigNotify
---@field found? boolean Whether to notify when a word is found.
---@field not_found? boolean Whether to notify when no word is found.

---@class swap.Config
---@field max_line_length? integer The maximum line length to search.
---@field ignore_overlapping_matches? boolean Whether to ignore overlapping matches.
---@field all? swap.ConfigAll The options for all modules.
---@field opposites? swap.ConfigOpposites The options for the opposites.
---@field cases? swap.ConfigCases The options for the cases.
---@field chains? swap.ConfigChains The options for the chains.
---@field notify? swap.ConfigNotify The notifications to show.
