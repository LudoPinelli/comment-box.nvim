<h1 align="center">comment-box.nvim</h1>

![comment-box](./imgs/bc-title.jpg?raw=true)

You have this long config file and you want to clearly (and beautifully) separate each part. So you put lines of symbols as separators. Boxes would have been better but too tedious to make, not to mention if you want to center your text in it.

This plugin tries to remedy this by giving you easy boxes and lines the way you want them to be.

## Overview

_comment-box_ allows you to:

- draw a box around the selected text or actual line with a simple keyboard shortcut. The box can be left aligned or centered, with the text left aligned or centered,
- create your own type of box by choosing its width and the characters used to draw the top, bottom, left, right and corners of it.
- draw a line with a simple keyboard shortcut. The line can be left aligned or centered.
- create your own type of line by choosing its width and the characters used to draw its start, end and body.
- choose from a catalog of 22 predefined boxes and 10 predefined lines and use it by simply pass its number to the function call.

Mainly designed for code comments, _comment-box_ can also be used to brighten up the dull _.txt_ files! You can also use it in _markdown_ and _orgmode_ files, however, if it makes sense if you use those formats "as is" (for note taking for example), it's not a good idea if you plan to convert them to other formats.

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

### Commands

#### Boxes

| Command | Description | function |
|--- | --- | --- |
|`CBlbox[num]` | **Left aligned box** with **Left aligned text** | `require("comment-box").lbox([num])` |
|`CBclbox[num]` | **Centered box** with **Left aligned text** | `require("comment-box").clbox([num])` |
|`CBcbox[num]` | **Left aligned box** with **centered text** | `require("comment-box").clbox([num])` |
|`CBccbox[num]` | **Centered box** with **centered text** | `require("comment-box").clbox([num])` |

The `[num]` parameter is optional. It's the number of a predefined style from the catalog (see [Catalog](#the-catalog)). By leaving it empty, the box or line will be drawn with the style you defined or if you didn't define one, with the default style.

To draw a box, place your cursor on the line of text you want in a box, or select multiple lines in _visual mode_, then use one of the command/function above.

**Note**: if a line is too long to fit in the box, _comment-box_ will automatically wrap it for you.

**Note2**: a box is centered relatively to the width of your document (set to the standard 80 by default, you can change it with the `setup()` function - see [Configuration](#configuration-and-creating-your-own-type-of-box))

Examples:
```lua
-- A left aligned box with the text left justified:
:CBlbox
-- or
:lua require("comment-box").lbox()

-- A centered box with the text centered:
:CBccbox
-- or
:lua require("comment-box").ccbox()

-- A left aligned box with the text left justified, using the syle 17 from the catalog:
:CBlbox17
-- or
:lua require("comment-box").lbox(17)
```

#### Lines

| Command | Description | function |
|--- | --- | --- |
|`CBline[num]` | **Left aligned line** | `require("comment-box").line([num])` |
|`CBcline[num]` | **Centered line** | `require("comment-box").cline([num])` |

To draw a line, place your cursor where you want it and in _normal_ or _insert_ mode, use one of the command/function above.

**Note**: a line is centered relatively to the width of your document (set to the standard 80 by default, you can change it with the `setup()` function - see [Configuration](#configuration-and-creating-your-own-type-of-box))

Examples:
```lua
-- A left aligned line:
:CBline
- or
:lua require("comment-box").line()

-- A centered line:
:CBcline
-- or
:lua require("comment-box").cline()

-- A centered line using the style 6 from the catalog:
:CBcline6
-- or
:lua require("comment-box").cline(4)
```

### Keybindings examples

#### Vim script:

```shell
# left aligned box with left aligned text
nnoremap <Leader>bb <Cmd>lua require('comment-box').lbox()<CR>
vnoremap <Leader>bb <Cmd>lua require('comment-box').lbox()<CR>

# centered box with centered text
nnoremap <Leader>bc <Cmd>lua require('comment-box').ccbox()<CR>
vnoremap <Leader>bc <Cmd>lua require('comment-box').ccbox()<CR>

# centered line
nnoremap <Leader>bl <Cmd>lua require('comment-box').cline()<CR>
inoremap <M-l> <Cmd>lua require('comment-box').cline()<CR>
```

#### Lua

```lua
local keymap = vim.api.nvim_set_keymap

-- left aligned box with left aligned text
keymap("n", "<Leader>bb", "<Cmd>lua require('comment-box').lbox()<CR>", {})
keymap("v", "<Leader>bb", "<Cmd>lua require('comment-box').lbox()<CR>", {})

-- centered box with centered text
keymap("n", "<Leader>bc", "<Cmd>lua require('comment-box').ccbox()<CR>", {})
keymap("v", "<Leader>bc", "<Cmd>lua require('comment-box').ccbox()<CR>", {})

-- centered line
keymap("n", "<Leader>bl", "<Cmd>lua require('comment-box').cline()<CR>", {})
keymap("i", "<M-l>", "<Cmd>lua require('comment-box').cline()<CR>", {})
```

Or if you use _Neovim-nightly_:

```lua
local keymap = vim.keymap.set
local cb = require("comment-box")

-- left aligned box with left aligned text
keymap({ "n", "v"}, "<Leader>bb", cb.lbox, {})
-- centered box with centered text
keymap({ "n", "v"}, "<Leader>bc", cb.ccbox, {})

-- centered line
keymap("n", "<Leader>bl", cb.cline, {})
keymap("i", "<M-l>", cb.cline, {})
```

## The catalog

![The catalog](./imgs/bc-catalog.jpg?raw=true)

The catalog is a collection of 22 predefined types of boxes and 10 types of lines.
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
-- or
:lua require("comment-box").cbox(10)

-- A line with the predefined type of line n°4:
:CBline4
-- or
:lua require("comment-box").line(4)
```

Or if you found one (or more) you will frequently use, you may want to include it in you keybindings.

**Note**: in addition to the usual way of closing windows, you can simply use `q` to close the catalog.

The type n°1 for the box and line is the default one, so, if you didn't change the default settings via the `setup()` function (see [Configuration](#configuration-and-creating-your-own-type-of-box)), passing nothing or _1_ (or even _0_) will lead to the same result.

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

### `borders`

The symbols used to draw the boxes. Let your creativity go wild! Or just use the default or choose from the predefined ones (see [Catalog](#the-catalog)).

If you want an element of the box to be invisible, you can use either `" "`(space) or `""`(empty string).

You can even create very ugly ones, no judgement!

![ASCII box](./imgs/ugly.jpg?raw=true)

### `line_width`

Width of the lines.

### `line`

The symbols used to draw the lines. Let your creativity go wild! Or just use the default or choose from the predefined ones (see [Catalog](#the-catalog)).

### `outer_blank_lines` and `inner_blank_lines`

![blank lines](./imgs/bc-blanklines.jpg?raw=true)

### `line_blank_line_above` and `line_blank_line_below`

Self explanatory!

## Acknowledgement

I learned and borrow from those plugins' code:

- [better-escape](https://github.com/max397574/better-escape.nvim)
- [nvim-comment](https://github.com/terrortylor/nvim-comment/blob/main/lua/nvim_comment.lua)

@HiPhish for his excellent advice to make the code a bit better (I'm still working on it...).
