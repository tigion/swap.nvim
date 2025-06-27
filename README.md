# nvim-opposites

A [Neovim](https://neovim.io/) plugin to quickly switch the word under the
cursor to its opposite word or other supported variants.  
For example, if the cursor is on `enable` it will
switch to `disable` and vice versa.

> [!WARNING]
> This plugin is based on my personal needs. Work in progress. 🚀

> [!CAUTION]
> BREAKING CHANGES
>
> - 2025-06-24: The functions have changed.
> - 2025-06-19: The configuration has changed.
>
> See the [Breaking Changes](#️-breaking-changes) section for more information.

Other similar or better plugins are:

- [nguyenvukhang/nvim-toggler](https://github.com/nguyenvukhang/nvim-toggler)
- [AndrewRadev/switch.vim](https://github.com/AndrewRadev/switch.vim)

## ✨ Features

Finds a word or string under the cursor and replaces it
with its opposite word or other supported variants.

- **Switches between opposite words** (see [opposites]).
  - The found string can also be a part of a word.
    - e.g. `enabled` with the cursor in `enable` becomes `disabled`.
  - Adapts the capitalization of the replaced word.
    - e.g. `true`, `True`, `TRUE` -> `false`, `False`, `FALSE`.
  - The opposite words can be file type specific.
- **Switches between naming conventions** (see [cases]).
  - e.g. `foo_bar` -> `fooBar` -> `FooBar` -> `foo_bar`
- **Switches between word chains** (see [chains]).
  - e.g. `foo` -> `bar` -> `baz` -> `foo`

If several results are found, the user is asked which result to switch to.

## ⚡️ Requirements

- Neovim >= 0.10

## 📦 Installation

### [lazy.nvim]

[lazy.nvim]: https://github.com/folke/lazy.nvim

```lua
return {
  'tigion/nvim-opposites',
  -- event = { 'BufReadPost', 'BufNewFile' },
  keys = {
    { '<Leader>i', function() require('opposites').switch() end, desc = 'Switch word' },
    -- { '<Leader>I', function() require('opposites').opposites.switch() end, desc = 'Switch to opposite word' },
    -- { '<Leader>I', function() require('opposites').cases.switch() end, desc = 'Switch to next case type' },
    -- { '<Leader>I', function() require('opposites').chains.switch() end, desc = 'Switch to next word' },
  },
  ---@type opposites.Config
  opts = {},
}
```

## 🚀 Usage

| Function                                  | Description                                 | Submodule   |
| ----------------------------------------- | ------------------------------------------- | ----------- |
| `require('opposites').switch()`           | Uses [all](#switch-all) allowed submodules. |             |
| `require('opposites').opposites.switch()` | Only switches to the opposite word.         | [opposites] |
| `require('opposites').cases.switch()`     | Only switches to the next case type.        | [cases]     |
| `require('opposites').chains.switch()`    | Only switches to the next word chain.       | [chains]    |

Call one of the functions directly or use it in a key mapping.

```lua
vim.keymap.set('n', '<Leader>i', require('opposites').switch, { desc = 'Switch word' })
```

See the [Configuration](#️-configuration) section for the default options.

### Switch All

Call `require('opposites').switch()` to switch to a supported variant of the
word/string under the cursor. Supported variants are all allowed [submodules](#-submodules).

The allowed submodules can be configured in the `all.modules` table in the
`opposites.Config` table.

```lua
opts = {
  all = {
    modules = { 'opposites', 'cases', 'chains' },
  },
}
```

## 🎁 Submodules

| Submodule   | Description                                 |
| ----------- | ------------------------------------------- |
| [opposites] | Switches a word to its opposite word.       |
| [cases]     | Switches the naming convention of a word.   |
| [chains]    | Switches through the words in a word chain. |

### 🧩 opposites

[opposites]: #-opposites

Call `require('opposites').opposites.switch()` to switch to the opposite word
under the cursor.

For more own defined words, add them to the `words` or `words_by_ft` table in
the `opposites` part of the `opposites.Config` table.

> [!NOTE]
> Redundant opposite words are removed automatically.

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

> [!TIP]
> It doesn't have to be opposites words that are exchanged (e.g. `['Vim'] = 'Neovim'`).

#### Case Sensitive Mask

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

### 🧩 cases

[cases]: #-cases

> [!WARNING]
> This feature is experimental and work in progress.
> The word identification is very limited.

Call `require('opposites').cases.switch()` to switch to the next case type of the
word under the cursor.

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

- Identifies only words with alphanumeric characters, underscores and dashes (`a-zA-Z0-9_-`).
- Word parts must start with a letter.
- Numbers are only allowed at the end of the word parts.
- Underscores and dashes are only allowed between the word parts.
- Words must be at least 2 parts long.
- No mixed case types.

Examples:

- ✅ `foo_bar`, `foo_bar1`, `foo_bar_baz`
- ❌ `foo`, `foo_1bar`, `_foo_bar`, `foo_bar_`, `foo_bar-baz`, `foo_bar_Baz`

### 🧩 chains

[chains]: #-chains

Call `require(‘opposites’).chains.switch()` to switch to the next word in
a word chain under the cursor.

Examples:

- `Monday` -> `Tuesday` -> `Wednesday` -> ... -> `Sunday` -> `Monday`
- `foo` -> `bar` -> `baz` -> `qux` -> `foo`

The word chains are defined in the `words` and `words_by_ft` tables in
the `chains` part of the `opposites.Config` table.

Example:

```lua
opts = {
  chains = {
    words = { -- Default word chains.
      { 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday' },
      { 'foo', 'bar', 'baz', 'qux' },
    },
    words_by_ft = { -- File type specific word chains.
      markdown = {
        { '[!NOTE]', '[!TIP]', '[!IMPORTANT]', '[!WARNING]', '[!CAUTION]' }, -- GitHub alerts
      },
    },
  },
}
```

Rules:

- The word chains must be at least 2 words long.
- The word chains should not contain the same word more than once.

## ⚙️ Configuration

The default options are:

<details>
  <summary>Show annotations and descriptions of the configuration</summary>

```lua
---@alias opposites.ConfigModule
--- | 'opposites'
--- | 'cases'
--- | 'chains'
---@alias opposites.ConfigOppositesWords table<string, string>
---@alias opposites.ConfigOppositesWordsByFt table<string, opposites.ConfigOppositesWords>
---@alias opposites.ConfigCasesId
--- | 'snake' snake_case
--- | 'screaming_snake' SCREAMING_SNAKE_CASE
--- | 'kebab' kebab-case
--- | 'screaming_kebab' SCREAMING-KEBAB-CASE
--- | 'camel' camelCase
--- | 'pascal' PascalCase
---@alias opposites.ConfigCasesTypes opposites.ConfigCasesId[]
---@alias opposites.ConfigChainsWords string[][]
---@alias opposites.ConfigChainsWordsByFt table<string, opposites.ConfigChainsWords>

---@class opposites.ConfigAll
---@field modules? opposites.ConfigModule[] The default submodules to use.

---@class opposites.ConfigOpposites
---@field use_case_sensitive_mask? boolean Whether to use a case sensitive mask.
---@field use_default_words? boolean Whether to use the default opposites.
---@field use_default_words_by_ft? boolean Whether to use the default opposites.
---@field words? opposites.ConfigOppositesWords The words with their opposite words.
---@field words_by_ft? opposites.ConfigOppositesWordsByFt The file type specific words with their opposite words.

---@class opposites.ConfigCases
---@field types? opposites.ConfigCasesTypes The allowed case types to parse.

---@class opposites.ConfigChains
---@field words? opposites.ConfigChainsWords The word chains to search for.
---@field words_by_ft? opposites.ConfigChainsWordsByFt The file type specific word chains to search for.

---@class opposites.ConfigNotify
---@field found? boolean Whether to notify when a word is found.
---@field not_found? boolean Whether to notify when no word is found.

---@class opposites.Config
---@field max_line_length? integer The maximum line length to search.
---@field opposites? opposites.ConfigOpposites The options for the opposites.
---@field cases? opposites.ConfigCases The options for the cases.
---@field chains? opposites.ConfigChains The options for the chains.
---@field notify? opposites.ConfigNotify The notifications to show.
```

</details>

```lua
---@type opposites.Config
local defaults = {
  max_line_length = 1000,
  all = {
    modules = { 'opposites', 'cases', 'chains' },
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
  chains = {
    words = {},
    words_by_ft = {},
  },
  notify = {
    found = false,
    not_found = true,
  },
}
```

For other plugin manager, call the setup function `require('opposites').setup({
  ... })` directly.

## ‼️ Breaking Changes

- **2025-06-24**: The functions have changed.
  - The default behavior of `require('opposites').switch()` is now to switch to
    a supported variant.
  - `require('opposites').opposites.switch()` is now only for switching to the
    opposite word.
  - `require('opposites').cases.next()` is now `require('opposites').cases.switch()`
  - See the [Usage](#-usage) section.

- **2025-06-19**: The configuration has changed.
  - Options for the opposites are now in the `opposites` table.
  - The `opposites` and `opposites_by_ft` tables are now renamed to `words` and
    `words_by_ft`.
  - See the [Configuration](#️-configuration) section.

## 📋 TODO

- [ ] Limit and check the user configuration.
- [x] Support word chains like `{ 'foo', 'bar', 'baz' }`.
- [x] Refactoring of the code for separate modules like `opposites` and `cases`.
- [x] Switch naming conventions (case types).
- [x] Use `vim.ui.select` instead of `vim.fn.inputlist`.
- [x] Refactoring of the first quickly written code.
- [x] Adapt the capitalization of the words to reduce words like `true`,
      `True`, `tRUe` and `TRUE`.
- [x] Add file type specific opposites.
