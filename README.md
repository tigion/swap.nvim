# nvim-opposites

A Neovim plugin to quickly switch the word under the cursor to its opposite word.

For example, if the cursor is on `enable` and you press `<Leader>i` it will
switch to `disable` and vice versa.

> [!WARNING]
> This plugin is based on my personal needs. Work in progress. 🚀

> [!CAUTION]
> BREAKING CHANGES (2025-06-19): The configuration has changed.
>
> - Options for the opposites are now in the `opposites` table.
> - The `opposites` and `opposites_by_ft` tables are now renamed to `words` and
>   `words_by_ft`.
>
> See the [Configuration](#configuration) section.

Other similar or better plugins are:

- [nguyenvukhang/nvim-toggler](https://github.com/nguyenvukhang/nvim-toggler)
- [AndrewRadev/switch.vim](https://github.com/AndrewRadev/switch.vim)

## Features

- Searches for the configured words and opposite words in the current line
  under the cursor.
- Switches the found word to its opposite word.
- The found word can also be a part of another word.
  - e.g. _enabled_ with the cursor in `enable` becomes _disabled_.
- Adapts the capitalization of the replaced word.
  - e.g. `true`, `True`, `TRUE` -> `false`, `False`, `FALSE`.
- The opposite words can be file type specific.
- Optionally notifies when the word is found or not.
- If several results are found, the user is asked which result to switch to.

Extras:

- [experimental] Switches between naming conventions (case types).
  - e.g. `foo_bar` -> `fooBar` -> `FooBar` -> `foo_bar`

## Requirements

- Neovim >= 0.10

## Installation

### [lazy.nvim]

[lazy.nvim]: https://github.com/folke/lazy.nvim

```lua
return {
  'tigion/nvim-opposites',
  -- event = { 'BufReadPost', 'BufNewFile' },
  keys = {
    { '<Leader>i', function() require('opposites').switch() end, desc = 'Switch to opposite word' },
    -- { '<Leader>I', function() require('opposites').cases.next() end, desc = 'Switch to next case type' },
  },
  ---@type opposites.Config
  opts = {},
}
```

## Usage

### Switch opposites

Call `require('opposites').switch()` to switch to the opposite word under the
cursor.

For more own defined words, add them to the `words` or
`words_by_ft` table in the `opposites` part of the `opposites.Config` table.

> [!NOTE]
> Redundant opposite words are removed automatically.

If `use_default_words` and `use_default_words_by_ft` is set to `false`,
only the user defined words will be used.

```lua
opts = {
  opposites = {
    words = {
      ['angel'] = 'devil', -- Adds a new default.
      ['yes'] = 'ja',      -- Replaces the default `['yes'] = 'no'`.
      ['min'] = nil,       -- Removes a default.
    },
    words_by_ft = {
      ['lua'] = {
        ['=='] = '~=',     -- Replaces the default `['=='] = '!='` for lua files.
      },
      ['sql'] = {
        ['AND'] = 'OR',    -- Adds a new for SQL files.
      },
    },
  },
}
```

> [!TIP]
> It doesn't have to be opposites words that are exchanged.

#### Case sensitive mask

Flexible word recognition can be used to avoid having to configure every
variant of capitalization. Activated by default.
This means that variants with capital letters are also found for lower-case
words and the replaced opposite word adapts the capitalization.

Rules:

- If the word is uppercase, the mask is upper case.
- If the word is lowercase, the mask is lower case.
- If the word is mixed case, the mask is a string to represent the case. Longer
  words are masked at the end with lower case letters.

Deactivate this behavior by setting `use_case_sensitive_mask = false`.

> [!IMPORTANT]
> If a configured word or his opposite word contains capital letters, then for
> this words no mask is used.

Example with `['enable'] = 'disable'`:

- found: `enable`, `Enable`, `EnAbLe` and `ENABLE`
- replaced with: `disable`, `Disable`, `diSAble` and `DISABLE`

Example with `['enable'] = 'Disable'`:

- found: `enable`
- replaced with: `Disable`

### Switch naming conventions (cases)

> [!WARNING]
> This feature is experimental and work in progress.
> The word identification is very limited.

Call `require('opposites').cases.next()` to switch to the next case type of the word under the cursor.

Example:

- `foo_bar` → `FOO_BAR` → `foo-bar` → `FOO-BAR` → `fooBar` → `FooBar` → `foo_bar`

Supported case types are:

- snake_case
- SCREAMING_SNAKE_CASE
- kebab-case
- SCREAMING-KEBAB-CASE
- camelCase
- PascalCase

The allowed case types and the switch order can be configured in the `types`
table in the `cases` part of the `opposites.Config` table.

```lua
opts = {
  cases = {
    types = {
      'snake', -- snake_case
      'screaming_snake', -- SCREAMING_SNAKE_CASE
      'kebab', -- kebab-case
      'screaming_kebab', -- SCREAMING-KEBAB-CASE
      'camel', -- camelCase
      'pascal', -- PascalCase
    },
  },
}
```

#### Limits

- Identifies only words with alphanumeric characters, underscores and dashes (`a-zA-Z0-9_-`).
- Word parts must start with a letter.
- Numbers are only allowed at the end of the word parts.
- Underscores and dashes are only allowed between the word parts.
- Words must be at least 2 parts long.
- No mixed case types.

Examples:

- ✅ `foo_bar`, `foo_bar1`, `foo_bar_baz`
- ❌ `foo`, `foo_1bar`, `_foo_bar`, `foo_bar_`, `foo_bar-baz`, `foo_bar_Baz`

## Configuration

The default options are:

```lua
---@alias opposites.ConfigOppositesWords table<string, string>
---@alias opposites.ConfigOppositesWordsByFt table<string, opposites.ConfigOpposites>

---@class opposites.ConfigOpposites
---@field use_case_sensitive_mask? boolean Whether to use a case sensitive mask.
---@field use_default_words? boolean Whether to use the default opposites.
---@field use_default_words_by_ft? boolean Whether to use the default opposites.
---@field words? opposites.ConfigOppositesWords The words with their opposite words.
---@field words_by_ft? opposites.ConfigOppositesWordsByFt The file type specific words with their opposite words.

---@alias opposites.ConfigCasesId
--- | 'snake' snake_case
--- | 'screaming_snake' SCREAMING_SNAKE_CASE
--- | 'kebab' kebab-case
--- | 'screaming_kebab' SCREAMING-KEBAB-CASE
--- | 'camel' camelCase
--- | 'pascal' PascalCase
---@alias opposites.ConfigCasesTypes table<opposites.ConfigCasesId>

---@class opposites.ConfigCases
---@field types? opposites.ConfigCasesTypes The allowed case types to parse.

---@class opposites.ConfigNotify
---@field found? boolean Whether to notify when a word is found.
---@field not_found? boolean Whether to notify when no word is found.

---@class opposites.Config -- opposites.config.config
---@field max_line_length? integer The maximum line length to search.
---@field opposites? opposites.ConfigOpposites The options for the opposites.
---@field cases? opposites.ConfigCases The options for the cases.
---@field notify? opposites.ConfigNotify The notifications to show.

---@type opposites.Config
local defaults = {
  max_line_length = 1000,
  opposites = {
    use_case_sensitive_mask = true,
    use_default_words = true,
    use_default_words_by_ft = true,
    words = {
      ['enable'] = 'disable',
      ['true'] = 'false',
      ['yes'] = 'no',
      ['on'] = 'off',
      ['and'] = 'or',
      ['left'] = 'right',
      ['up'] = 'down',
      ['min'] = 'max',
      ['=='] = '!=',
      ['<='] = '>=',
      ['<'] = '>',
    },
    words_by_ft = {
      ['lua'] = {
        ['=='] = '~=',
      },
      ['sql'] = {
        ['asc'] = 'desc',
      },
    },
  },
  cases = {
    types = {
      'snake',
      'screaming_snake',
      'kebab',
      'screaming_kebab',
      'camel',
      'pascal',
    },
  },
  notify = {
    found = false,
    not_found = true,
  },
}
```

For other plugin manager, call the setup function
`require('opposites').setup({ ... })` directly.

## TODO

- [ ] Limit and check the user configuration.
- [ ] Switch naming conventions (case types).
- [ ] Add word lists support.
- [x] Use `vim.ui.select` instead of `vim.fn.inputlist`.
- [x] Refactoring of the first quickly written code.
- [x] Adapt the capitalization of the words to reduce words like `true`,
      `True`, `tRUe` and `TRUE`.
- [x] Add file type specific opposites.
