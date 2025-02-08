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

To add more words to the opposites list, add them to the `opposites` table in
the `opposites.Config` table.

If `use_default_opposites` is set to `false`, only the user defined words will
be used.

```lua
opts = {
  use_default_opposites = true,
  opposites = {
    ['ja'] = 'nein',
    ['angel'] = 'devil',
  },
}
```

> [!TIP]
> It doesn't have to be opposites words that are exchanged.

## Configuration

The default options are:

```lua
---@class opposites.Config
---@field max_line_length? integer The maximum line length to search.
---@field use_default_opposites? boolean Whether to use the default opposites.
---@field opposites? table<string, string> The words with their opposite.
---@field notify? opposites.Config.notify The notifications to show.

---@class opposites.Config.notify
---@field found? boolean Whether to notify when a word is found.
---@field not_found? boolean Whether to notify when no word is found.

---@type opposites.Config
{
  max_line_length = 1000,
  use_default_opposites = true,
  opposites = {
    -- stylua: ignore start
    ['enable'] = 'disable',
      ['true'] = 'false',
      ['True'] = 'False',
       ['yes'] = 'no',
        ['on'] = 'off',
      ['left'] = 'right',
        ['up'] = 'down',
       ['min'] = 'max',
        ['=='] = '!=',
        ['<='] = '>=',
         ['<'] = '>',
    -- stylua: ignore end
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
- [ ] Use `vim.ui.select` instead of `vim.fn.inputlist`.
