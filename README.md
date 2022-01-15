<h1 align="center">comment-box.nvim</h1>

![comment-box](./imgs/bc-title.png?raw=true)

You have this long config file and you want to clearly (and beautifully) separate each part. So you put lines of symbols as separators. Boxes would have been better but too tedious to make, not to mention if you want to center your text in it.

This plugin tries to remedy this by giving you easy boxes and lines the way you want them to be.

## Prerequisite

_Neovim_ 0.5+

## Installation

Install like any other plugin with your favorite package manager.

For example with packer:

```lua
use("LudoPinelli/comment-box.nvim")
```

Note: _comment-box_ does not come with any keybinding (see [below](#keybindings-examples) below to make your own)

## Usage

Put your cursor on the line you want in a box, or select multiple lines, then use one of the two functions provided:

```lua
-- To draw a box with the text left-aligned:
:lua require("comment-box").lbox()

-- To draw a box with the text centered:
:lua require("comment-box").cbox()
```

### Keybindings examples

#### Vim script:

```shell
nnoremap <Leader>bb <Cmd>lua require('comment-box').lbox()<CR>
vnoremap <Leader>bb <Cmd>lua require('comment-box').lbox()<CR>

nnoremap <Leader>bc <Cmd>lua require('comment-box').cbox()<CR>
vnoremap <Leader>bc <Cmd>lua require('comment-box').cbox()<CR>
```

#### Lua

```lua
local keymap = vim.api.nvim_set_keymap

keymap("n", "<Leader>bb", "<Cmd>lua require('comment-box').lbox()<CR>", {})
keymap("v", "<Leader>bb", "<Cmd>lua require('comment-box').lbox()<CR>", {})

keymap("n", "<Leader>bc", "<Cmd>lua require('comment-box').cbox()<CR>", {})
keymap("v", "<Leader>bc", "<Cmd>lua require('comment-box').cbox()<CR>", {})
```

Or if you use _Neovim-nightly_:

```lua
local keymap = vim.keymap.set

keymap({ "n", "v"}, "<Leader>bb", require('comment-box').lbox, {})
keymap({ "n", "v"}, "<Leader>bc", require('comment-box').cbox, {})
```

## Configuration

You can call the `setup` function in your _init.lua(.vim)_ to configure the way comment-box does its things. Here is the list of the options with their default value:

```lua
require('comment-box').setup({
	width = 70, -- width of the box/line
	border = { -- symbols used to draw a box
		horizontal = "─",
		vertical = "│",
		top_left = "╭",
		top_right = "╮",
		bottom_left = "╰",
		bottom_right = "╯",
	},
	outer_blank_lines = false, -- insert a blank line above and below the box
	inner_blank_lines = false, -- insert a blank line above and below the text
  })
```

### `width`

Width of the boxes and lines

### `border`

To change the look of your boxes:

![ASCII box](./imgs/bc-options01.png?raw=true)

### `outer_blank_line` and `inner_blank_lines`

![blank lines](./imgs/bc-options02.png?raw=true)

## Known issues

_comment-box_ doesn't (yet) wrap texts longer than the width of the box.
