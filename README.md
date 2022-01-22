<h1 align="center">comment-box.nvim</h1>

![comment-box](./imgs/bc-title.png?raw=true)

You have this long config file and you want to clearly (and beautifully) separate each part. So you put lines of symbols as separators. Boxes would have been better but too tedious to make, not to mention if you want to center your text in it.

This plugin tries to remedy this by giving you easy boxes and lines the way you want them to be.

### :fire: Breaking changes

If you installed this plugin before the 01/21/22 and customized the box and/or line, you will experience somme errors.

- The `horizontal` parameter for the box is now now divided in `top` and `bottom`,
- the `vertical` parameter for the box is now divided in `left` and `right`,
- the `line` parameter is now a table containing `line`, `line_start`, `line_end`,
- the `width` parameter is now divided in `box_width` and `line_width`.

Just make the appropriate changes in your `setup({})` function and everything will fall in place. :)

## Overview

_comment-box_ allows you to:

- draw a box around the selected text or actual line with a simple keyboard shortcut, the text is automatically wrap to fit the width of the box and can be centered or not,
- create your own type of box by choosing its width and the characters used to draw the top, bottom, left, right and corners of it
- draw a line with a simple keyboard shortcut,
- create your own type of line by choosing its width and the characters used to draw its start, end and body,
- choose from a catalog of 21 predefined boxes and 9 predefined lines and use it by simply pass its number to the function call.

Mainly designed for code comments, _comment-box_ can also be used to brighten up the dull _.txt_ files!

## Prerequisite

_Neovim_ 0.5+

## Installation

Install like any other plugin with your favorite package manager.

For example with packer:

```lua
use("LudoPinelli/comment-box.nvim")
```

If you're fine with the default settings (see [Configuration](#configuration-and-creating-your-own-type-of-box)), it's all you have to do, however, _comment-box_ does not come with any keybinding, see [Keybindings examples](#keybindings-examples) to make your own.

## Usage

### To put some text in a box

Put your cursor on the line you want in a box, or select multiple lines, then use one of the two functions provided:

```lua
-- To draw a box with the text left justified:
:lua require("comment-box").lbox()

-- To draw a box with the text centered:
:lua require("comment-box").cbox()
```

But you will probably want to use their syntactic sugar equivalent:

```lua
-- To draw a box with the text left justified:
:CBlbox

-- To draw a box with the text centered:
:CBcbox
```

Optionally, you can pass an argument to use one of the predefined boxes of the catalog (see [Catalog](#the-catalog)), for example:

```lua
-- Use the box 17 of the catalog with the text left justified:
:lua require("comment-box").lbox(17)
-- or
:CBlbox17
```

**Note**: if a line is too long to fit in the box, _comment-box_ will automatically wrap it for you.

### To draw a line

In _normal_ or _insert_ mode, use:

```lua
:lua require("comment-box").line()
```

Its syntactic sugar equivalent:

```lua
:CBline
```

Optionally, you can pass an argument to use one of the predefined lines of the catalog (see Catalog), for example:

```lua
-- Use the line 6 of the catalog:
:lua require("comment-box").line(6)
-- or
:CBline6
```

### Keybindings examples

#### Vim script:

```shell
nnoremap <Leader>bb <Cmd>lua require('comment-box').lbox()<CR>
vnoremap <Leader>bb <Cmd>lua require('comment-box').lbox()<CR>

nnoremap <Leader>bc <Cmd>lua require('comment-box').cbox()<CR>
vnoremap <Leader>bc <Cmd>lua require('comment-box').cbox()<CR>

nnoremap <Leader>bl <Cmd>lua require('comment-box').line()<CR>
inoremap <M-l> <Cmd>lua require('comment-box').line()<CR>
```

#### Lua

```lua
local keymap = vim.api.nvim_set_keymap

keymap("n", "<Leader>bb", "<Cmd>lua require('comment-box').lbox()<CR>", {})
keymap("v", "<Leader>bb", "<Cmd>lua require('comment-box').lbox()<CR>", {})

keymap("n", "<Leader>bc", "<Cmd>lua require('comment-box').cbox()<CR>", {})
keymap("v", "<Leader>bc", "<Cmd>lua require('comment-box').cbox()<CR>", {})

keymap("n", "<Leader>bl", "<Cmd>lua require('comment-box').line()<CR>", {})
keymap("i", "<M-l>", "<Cmd>lua require('comment-box').line()<CR>", {})
```

Or if you use _Neovim-nightly_:

```lua
local keymap = vim.keymap.set
local cb = require("comment-box")

keymap({ "n", "v"}, "<Leader>bb", cb.lbox, {})
keymap({ "n", "v"}, "<Leader>bc", cb.cbox, {})

keymap("n", "<Leader>bl", cb.line, {})
keymap("i", "<M-l>", cb.line, {})
```

## The catalog

The catalog is a collection of 21 predefined types of boxes and 9 types of lines.
You can easily access the catalog in _Neovim_ (it will appear in a popup window so it won't mess with what you're doing) using:

```lua
:CBcatalog
-- or
:lua require("comment-box").catalog()
```

Just take note of the number of the type of box or line you want to use, close the catalog and pass the number to the function. For example:

```lua
-- A box with the text centered and the predefined type of box n°10:
:CBcbox10
or
:lua require("comment-box").cbox(10)

-- A line with the predefined type of line n°4:
:CBline4
or
:lua require("comment-box").line(4)
```

Or if you found one (or more) you will frequently use, you may want to include it in you keybindings.

The type n°1 for the box and line is the default one, so, if you didn't change the default settings via the `setup()` function (see [configuration](#configuration-and-creating-your-own-type-of-box)), passing nothing or 1 (or even 0) is the same thing.

## Configuration and creating your own type of box

You can call the `setup()` function in your _init.lua(.vim)_ to configure the way _comment-box_ does its things. This is also where you can create your own type of box. Here is the list of the options with their default value:

```lua
require('comment-box').setup({
	box_width = 70, -- width of the boxex
	borders = { -- symbols used to draw a box
		top = "─",
		bottom = "─",
		left = "│",
		right = "│",
		top_left = "╭",
		top_right = "╮",
		bottom_left = "╰",
		bottom_right = "╯",
	},
  line_width = 70, -- width of the lines
  line = { -- symbols used to draw a line
		line = "─",
		line_start = "─",
		line_end = "─",
    }
  outer_blank_lines = false, -- insert a blank line above and below the box
  inner_blank_lines = false, -- insert a blank line above and below the text
  line_blank_line_above = false, -- insert a blank line above the line
  line_blank_line_below = false, -- insert a blank line below the line
})
```

### `box_width`

Width of the boxes.

### `border`

The symbols used to draw the boxes. Let your creativity go wild! Or just use the default or choose from the predefined ones (see [Catalog](#the-catalog)):

![ASCII box](./imgs/bc-options01.png?raw=true)

### `line_width`

Width of the lines.

### `line`

The symbols used to draw the lines. Let your creativity go wild! Or just use the default or choose from the predefined ones (see [Catalog](#the-catalog)):

TODO

### `outer_blank_line` and `inner_blank_lines`

![blank lines](./imgs/bc-options02.png?raw=true)

### `line_blank_line_above` and `line_blank_line_below`

TODO

## Acknowledgement

I learned and borrow from those plugins' code:

- [better-escape](https://github.com/max397574/better-escape.nvim)
- [nvim-comment](https://github.com/terrortylor/nvim-comment/blob/main/lua/nvim_comment.lua)

@HiPhish for his excellent advice to make the code a bit better (I'm still working on it...).
