# swap.nvim

A [Neovim](https://neovim.io/) plugin to quickly **swap** (_switch_, _change_)
a **word** (_string_) under the cursor or a **pattern** in the current line.
For example, if the cursor is on `enable` it will switch to `disable` and vice
versa (see [Features](#features)).

> [!WARNING]
> This plugin is based on my personal needs. Work in progress. 🚀

> [!CAUTION]
> **BREAKING CHANGES** (2025-07-03): The name has changed.
>
> - The repo name has changed from `nvim-opposites` to `swap.nvim`.
> - The plugin module name has changed from `opposites` to `swap`.
>
> More information and older notes can be found in the
> [Breaking Changes](#️-breaking-changes) section.

Other similar or better plugins are:

- [nguyenvukhang/nvim-toggler](https://github.com/nguyenvukhang/nvim-toggler)
- [AndrewRadev/switch.vim](https://github.com/AndrewRadev/switch.vim)

**Table of Contents**:

- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Usage](#usage)
- [Modules](#modules):
  [opposites](#opposites), [chains](#chains), [cases](#cases), [todos](#todos)
- [Configuration](#configuration):
  [Default Options](#default-options)
- [Notes](#notes)
  - [Case Sensitive Mask](#case-sensitive-mask)
  - [Overlapping Matches](#overlapping-matches)
- ‼️ [Breaking Changes](#️-breaking-changes)
- [Todo](#todo)

&nbsp;

## Features

- **Switches between opposite words** (see [opposites]).
  - e.g. `true` -> `false`
  - Adapts the capitalization of the replaced word.
    - e.g. `true`, `True`, `tRUe`, `TRUE` -> `false`, `False`, `fALse`, `FALSE`.
- **Switches through word chains** (see [chains]).
  - e.g. `foo` -> `bar` -> `baz` -> `foo`
  - Adapts the capitalization of the replaced word.
- ⚠️ **Switches between naming conventions** (see [cases]).
  - e.g. `foo_bar` -> `fooBar` -> `FooBar` -> `foo_bar`
- **Switches through todo states** (see [todos]).
  - e.g. `- [ ] foo` -> `- [x] foo`

If several results are found, the user is asked which result to switch to.

## Requirements

- Neovim >= 0.10

## Installation

### [lazy.nvim]

[lazy.nvim]: https://github.com/folke/lazy.nvim

```lua
return {
  'tigion/swap.nvim',
  -- event = { 'BufReadPost', 'BufNewFile' },
  keys = {
    { '<Leader>i', function() require('swap').switch() end, desc = 'Swap word' },
    -- { '<Leader>I', function() require('swap').opposites.switch() end, desc = 'Swap to opposite word' },
    -- { '<Leader>I', function() require('swap').chains.switch() end, desc = 'Swap to next word' },
    -- { '<Leader>I', function() require('swap').cases.switch() end, desc = 'Swap naming convention' },
    -- { '<Leader>I', function() require('swap').todos.switch() end, desc = 'Swap todo state' },
  },
  ---@type swap.Config
  opts = {},
}
```

&nbsp;

## Usage

| Function                             | Description                                                     | Module      |
| ------------------------------------ | --------------------------------------------------------------- | ----------- |
| `require('swap').switch()`           | Uses all allowed modules ([config](#configure-allowed-modules)) |             |
| `require('swap').opposites.switch()` | Switches between opposite words                                 | [opposites] |
| `require('swap').chains.switch()`    | Switches through word chains                                    | [chains]    |
| `require('swap').cases.switch()`     | Switches between naming conventions                             | [cases]     |
| `require('swap').todos.switch()`     | Switches through todo states                                    | [todos]     |

Call the functions directly or use them in a key mapping.

```lua
vim.keymap.set('n', '<Leader>i', require('swap').switch, { desc = 'Swap word' })
```

See the [configuration](#configuration) section for the available default
options and the [modules](#modules) section for configuration examples.

### Configure allowed modules

Call `require(‘swap’).switch()` to change the word (string) under the cursor or
the pattern in the current line to one of the allowed [modules](#modules) in
the `all.modules` table.

Example:

```lua
opts = {
  all = {
    -- modules = { 'opposites', 'todos' }, -- defaults
    modules = { 'opposites', 'chains', 'cases', 'todos' },
  },
}
```

&nbsp;

## Modules

| Module      | Description                         |
| ----------- | ----------------------------------- |
| [opposites] | Switches between opposite words     |
| [chains]    | Switches through word chains        |
| [cases]     | Switches between naming conventions |
| [todos]     | Switches through todo states        |

&nbsp;

### Opposites

[opposites]: #opposites

Call `require('swap').opposites.switch()` to switch to the opposite word
or string under the cursor. The found string can also be a part of a word.

For more own defined words, add them to the `words` or `words_by_ft` table in
the `opposites` part of the `swap.Config` table.

If `use_default_words` and `use_default_words_by_ft` is set to `false`, only
the user defined words will be used.

Example:

```lua
opts = {
  opposites = {
    words = { -- Default opposite words.
      ['angel'] = 'devil', -- Adds a new one.
      ['yes'] = 'ja',      -- Replaces the default `['yes'] = 'no'`.
      ['min'] = nil,       -- Removes a default.
    },
    words_by_ft = { -- File type specific opposite words.
      ['lua'] = {
        ['=='] = '~=',     -- Replaces the default `['=='] = '!='` for lua files.
      },
      ['sql'] = {
        ['asc'] = 'desc',  -- Adds a new for SQL files.
      },
    },
  },
}
```

> [!NOTE]
> Flexible word recognition can be used to avoid having to configure every
> variant of capitalization. Activated by default.
> See [Case Sensitive Mask](#case-sensitive-mask).

> [!TIP]
> It doesn't have to be opposites words that are exchanged (e.g. `['Vim'] = 'Neovim'`).

&nbsp;

### Chains

[chains]: #chains

Call `require(‘opposites’).chains.switch()` to switch to the next word or
string in a word chain under the cursor. The found string can also be a part of
a word.

Examples:

- `Monday` -> `Tuesday` -> `Wednesday` -> ... -> `Sunday` -> `Monday`
- `foo` -> `bar` -> `baz` -> `qux` -> `foo`

The word chains are defined in the `words` and `words_by_ft` tables in
the `chains` part of the `swap.Config` table.

Example:

```lua
opts = {
  chains = {
    words = { -- Default word chains.
      { 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday' },
      { 'foo', 'bar', 'baz', 'qux' },
    },
    words_by_ft = { -- File type specific word chains.
      asciidoc = {
        { '[NOTE]', '[TIP]', '[IMPORTANT]', '[WARNING]', '[CAUTION]' }, -- AsciiDoc admonitions (block)
        { 'NOTE:', 'TIP:', 'IMPORTANT:', 'WARNING:', 'CAUTION:' }, -- AsciiDoc admonitions (line)
      },
      markdown = {
        { '[!NOTE]', '[!TIP]', '[!IMPORTANT]', '[!WARNING]', '[!CAUTION]' }, -- Markdown (GitHub) alerts
      },
    },
  },
}
```

Rules:

- The word chains must be at least 2 words long.
- The word chains should not contain the same word more than once.

> [!NOTE]
> Flexible word recognition can be used to avoid having to configure every
> variant of capitalization. Activated by default.
> See [Case Sensitive Mask](#case-sensitive-mask).

&nbsp;

### Cases

[cases]: #cases

> [!WARNING]
> This feature is experimental and work in progress.
> The word identification is very limited.

Call `require('swap').cases.switch()` to switch to the next case type of the
word under the cursor.

Example:

- `foo_bar` → `FOO_BAR` → `foo-bar` → `FOO-BAR` → `fooBar` → `FooBar` → `foo_bar`

Supported case types are:

- snake_case, SCREAMING_SNAKE_CASE
- kebab-case, SCREAMING-KEBAB-CASE
- camelCase
- PascalCase

The allowed case types and the switch order can be configured in the `types`
table in the `cases` part of the `swap.Config` table.

Example:

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

- Identifies only words with alphanumeric characters, underscores and dashes
  (`a-zA-Z0-9_-`).
- Word parts must start with a letter.
- Numbers are only allowed at the end of the word parts.
- Underscores and dashes are only allowed between the word parts.
- Words must be at least 2 parts long.
- No mixed case types.
- No support of abbreviations in capital letters for camelCase and PascalCase
  (e.g. ✅ `fooJson`, ❌ `fooJSON`, ✅ `userId`, ❌ `userID`).

Examples:

- ✅ `foo_bar`, `foo_bar1`, `foo_bar_baz`
- ❌ `foo`, `foo_1bar`, `_foo_bar`, `foo_bar_`, `foo_bar-baz`, `foo_bar_Baz`

&nbsp;

### Todos

[todos]: #todos

Call `require('swap').todos.switch()` to switch through the todo states.

Supported default todo syntax:

- `- [ ] foo` with the states `[ ]`, `[x]`

Supported filetype specific todo syntax:

- [Markdown Task-Lists](https://www.markdownguide.org/extended-syntax/#task-lists):
  `- [ ] foo` with the states `[ ]`, `[x]`
- [AsciiDoc Checklist](https://docs.asciidoctor.org/asciidoc/latest/lists/checklist/):
  `* [ ] foo` with the states `[ ]`, `[x]` (`[*]`)
- [Org Mode Checkboxes](https://orgmode.org/manual/Checkboxes.html):
  `- [ ] foo` with the states `[ ]`, `[-]`, `[X]` (`[x]`)

Rules:

- The cursor can be anywhere in the line.
- The first match is used.
- The filetype specific todo syntax have priority over the default todo syntax.

&nbsp;

## Configuration

In [lazy.nvim], use the table `opts = {}` for your own configuration. For other
plugin manager, call the setup function `require('swap').setup({})` with the
provided options in `{}` directly.

### Default Options

<details>
  <summary>Show annotations and descriptions</summary>

```lua
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
```

</details>

```lua
---@type swap.Config
local defaults = {
  max_line_length = 1000,
  ignore_overlapping_matches = true,
  all = {
    modules = { 'opposites', 'todos' },
  },
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
  chains = {
    use_case_sensitive_mask = true,
    words = {},
    words_by_ft = {},
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

&nbsp;

## Notes

### Case Sensitive Mask

Flexible word recognition can be used to avoid having to configure every
variant of capitalization. This means that variants with capital letters are
also found for configured lower-case words and the replaced opposite word
adapts the capitalization.

Rules:

- If the found word is uppercase, the mask is upper case.
- If the found word is lowercase, the mask is lower case.
- If the found word is mixed case, the mask is a string to represent the case.
  Longer words are masked at the end with lower case letters.

Deactivate this behavior by setting `use_case_sensitive_mask = false` in the
module options.

> [!IMPORTANT]
> If a configured word or his opposite word contains capital letters, then for
> this words no mask is used.

Example with `['enable'] = 'disable'`:

- found: `enable`, `Enable`, `EnAbLe` and `ENABLE`
- replaced with: `disable`, `Disable`, `diSAble` and `DISABLE`

Example with `['enable'] = 'Disable'`:

- found: `enable`
- replaced with: `Disable`

### Overlapping Matches

By default, overlapping matches are ignored. This means that for the word
`foofoo`, if the cursor is in the middle `foo` of the word `foofoofoo`, only
the first `foofoo` is found and the second `foofoo` is ignored.

If you want to not ignore overlapping matches, set the option
`opts.ignore_overlapping_matches` to `false` (default is `true`).

&nbsp;

## ‼️ Breaking Changes

- **2025-07-03**: The name has changed.
  - The repo name has changed from `nvim-opposites` to `swap.nvim`.
  - The plugin module name has changed from `opposites` to `swap`.

- **2025-06-24**: The functions have changed.
  - The default behavior of `require('opposites').switch()` is now to switch to
    a supported variant.
  - `require('opposites').opposites.switch()` is now only for switching to the
    opposite word.
  - `require('opposites').cases.next()` is now `require('opposites').cases.switch()`
  - See the [Usage](#usage) section.

- **2025-06-19**: The configuration has changed.
  - Options for the opposites are now in the `opposites` table.
  - The `opposites` and `opposites_by_ft` tables are now renamed to `words` and
    `words_by_ft`.
  - See the [Configuration](#configuration) section.

&nbsp;

## Todo

- [ ] Limit and check the user configuration.
- [x] Change the plugin name to `swap.nvim`.
- [x] Switch todo states.
- [x] Support word chains like `{ 'foo', 'bar', 'baz' }`.
- [x] Refactoring of the code for separate modules like `opposites` and `cases`.
- [x] Switch naming conventions (case types).
- [x] Use `vim.ui.select` instead of `vim.fn.inputlist`.
- [x] Refactoring of the first quickly written code.
- [x] Adapt the capitalization of the words to reduce words like `true`,
      `True`, `tRUe` and `TRUE`.
- [x] Add file type specific opposites.
