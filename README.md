# nvim-opposites

A Neovim plugin to quickly switch the word under the cursor to its opposite word.

For example, if the cursor is on `enable` and you press `<Leader>i` it will
switch to `disable` and vice versa.

> [!WARNING]
> This plugin is based on my personal needs. Work in progress. 🚀

Other similar plugins are:

- [nguyenvukhang/nvim-toggler](https://github.com/nguyenvukhang/nvim-toggler)

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
  },
  ---@type opposites.Config
  opts = {},
}
```

## Usage

Call `require('opposites').switch()` to switch to the opposite word under the
cursor.

To add more words to the opposites list, add them to the `opposites` or
`opposites_by_ft` table in the `opposites.Config` table.

> [!NOTE]
> Redundant opposite words are removed automatically.

If `use_default_opposites` and `use_default_opposites_by_ft` is set to `false`,
only the user defined words will be used.

```lua
opts = {
  opposites = {
    ['angel'] = 'devil', -- Adds a new default.
    ['yes'] = 'ja',      -- Replaces the default `['yes'] = 'no'`.
    ['min'] = nil,       -- Removes a default.
  },
  opposites_by_ft = {
    ['lua'] = {
      ['=='] = '~=',     -- Replaces the default `['=='] = '!='` for lua files.
    },
    ['sql'] = {
      ['AND'] = 'OR',  -- Adds a new for SQL files.
    },
  },
}
```

> [!TIP]
> It doesn't have to be opposites words that are exchanged.

### Case sensitive mask

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

## Configuration

The default options are:

```lua
---@class opposites.Config -- opposites.config.config
---@field max_line_length? integer The maximum line length to search.
---@field use_case_sensitive_mask? boolean Whether to use a case sensitive mask.
---@field use_default_opposites? boolean Whether to use the default opposites.
---@field use_default_opposites_by_ft? boolean Whether to use the default opposites.
---@field opposites? opposites.Config.opposites The words with their opposite.
---@field opposites_by_ft? opposites.Config.opposites_by_ft The file type specific words with their opposite.
---@field notify? opposites.Config.notify The notifications to show.

---@alias opposites.Config.opposites table<string, string>
---@alias opposites.Config.opposites_by_ft table<string, opposites.Config.opposites>

---@class opposites.Config.notify
---@field found? boolean Whether to notify when a word is found.
---@field not_found? boolean Whether to notify when no word is found.

---@type opposites.Config
{
  max_line_length = 1000,
  use_case_sensitive_mask = true,
  use_default_opposites = true,
  use_default_opposites_by_ft = true,
  opposites = {
    ['enable'] = 'disable',
    ['true'] = 'false',
    ['yes'] = 'no',
    ['on'] = 'off',
    ['left'] = 'right',
    ['up'] = 'down',
    ['min'] = 'max',
    ['=='] = '!=',
    ['<='] = '>=',
    ['<'] = '>',
  },
  opposites_by_ft = {
    ['lua'] = {
      ['=='] = '~=',
    },
    ['sql'] = {
      ['asc'] = 'desc',
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
- [x] Use `vim.ui.select` instead of `vim.fn.inputlist`.
- [x] Refactoring of the first quickly written code.
- [x] Adapt the capitalization of the words to reduce words like `true`,
      `True`, `tRUe` and `TRUE`.
- [x] Add file type specific opposites.
