#### - LATEST CHANGES (December 27 2023) -
- **ADD**: `CBdbox` command to remove a box (while keeping the text).
- **ADD**: `CBy` command to yank the content of a box

---
<h1 align="center">comment-box.nvim</h1>

![comment-box](./imgs/bc-title.jpg?raw=true)

You have this long config file and you want to clearly (and beautifully) separate each part. So you put lines of symbols as separators. Boxes would have been better but too tedious to make, not to mention if you want to center your text in it.

This plugin tries to remedy this by giving you easy boxes and lines the way you want them to be in any kind of plain text file.

## Overview

_comment-box_ allows you to:

- draw a box around the selected text or actual line with a simple keyboard shortcut. The box can be left aligned, right aligned or centered, can have a fixed size or be adapted to the text. The text can be left aligned or centered. Too long text are automatically wrapped to fit in the box. The box can be removed at any time while keeping the text.
- create your own type of box by choosing its width and the characters used to draw the top, bottom, left, right and corners of it.
- draw a line with a simple keyboard shortcut. The line can be left aligned, right aligned or centered.
- create your own type of line by choosing its width and the characters used to draw its start, end and body.
- choose from a catalog of 22 predefined boxes and 10 predefined lines and use it by simply pass its number to the function call.

Mainly designed for code comments, _comment-box_ can also be used to brighten up the dull _.txt_ files! You can also use it in _markdown_ and _orgmode_ files, however, if it makes sense if you use those formats "as is" (for note taking for example), it's not a good idea if you plan to convert them to other formats.

**Note**: multi-line commenting as used in C is quite tricky and not fully supported yet.

## Prerequisite

_Neovim_ 0.8+

## Installation

Install like any other plugin with your favorite package manager.

For example with packer:

```lua
use("LudoPinelli/comment-box.nvim")
```
With lazy:
```lua
{ "LudoPinelli/comment-box.nvim", }
```

If you're fine with the default settings (see [Configuration](#configuration-and-creating-your-own-type-of-box)), it's all you have to do, however, _comment-box_ does not come with any keybinding, see [Keybindings examples](#keybindings-examples) to make your own.

## Usage

### Commands

#### Boxes

| Command | Description | function |
|--- | --- | --- |
|`CBllbox[num]` | _Left aligned box of fixed size_ with _Left aligned text_ | `require("comment-box").llbox([num])` |
|`CBlcbox[num]` | _Left aligned box of fixed size_ with _Centered text_ | `require("comment-box").lcbox([num])` |
|`CBlrbox[num]` | _Left aligned box of fixed size_ with _Right aligned text_ | `require("comment-box").lrbox([num])` |
|`CBclbox[num]` | _Centered box of fixed size_ with _Left aligned text_ | `require("comment-box").clbox([num])` |
|`CBccbox[num]` | _Centered box of fixed size_ with _Centered text_ | `require("comment-box").ccbox([num])` |
|`CBcrbox[num]` | _Centered box of fixed size_ with _Right aligned text_ | `require("comment-box").crbox([num])` |
|`CBrlbox[num]` | _Right aligned box of fixed size_ with _Left aligned text_ | `require("comment-box").rlbox([num])` |
|`CBrcbox[num]` | _Right aligned box of fixed size_ with _Centered text_ | `require("comment-box").rcbox([num])` |
|`CBrrbox[num]` | _Right aligned box of fixed size_ with _Right aligned text_ | `require("comment-box").rrbox([num])` |
|`CBalbox[num]` | _Left aligned adapted box_ | `require("comment-box").albox([num])` |
|`CBacbox[num]` | _Centered adapted box_ | `require("comment-box").acbox([num])` |
|`CBarbox[num]` | _Right aligned adapted box_ | `require("comment-box").arbox([num])` |
|`CBdbox` | _Remove a box_ | `require("comment-box")`.dbox() |
|`CBy` | _Yank the content of a box_ | `require("comment-box")`.yank() |

The `[num]` parameter is optional. It's the number of a predefined style from the catalog (see [Catalog](#the-catalog)). By leaving it empty, the box or line will be drawn with the style you defined or if you didn't define one, with the default style.

A 'centered' box is centered relatively to the width of your document (set to the standard 80 by default, you can change it with the `setup()` function - see [Configuration](#configuration-and-creating-your-own-type-of-box)). Same for 'right aligned' boxes.

An 'adapted' box means than the box width will be adapted to the width of the text. However, if the width of the text exceed the width of the document, the box will have the width of the document.
In case of multiple lines with various size, the text is aligned according to the position of the box (left aligned if the box is left aligned, centered if the box is centered, right aligned if the box is right aligned).

To draw a box, place your cursor on the line of text you want in a box, or select multiple lines in _visual mode_, then use one of the command/function above.

**Note**: if a line is too long to fit in the box, _comment-box_ will automatically wrap it for you.

Examples:
```lua
-- A left aligned fixed size box with the text left justified:
:CBllbox
-- or
:lua require("comment-box").llbox()

-- A centered fixed size box with the text centered:
:CBccbox
-- or
:lua require("comment-box").ccbox()

-- A centered adapted box:
:CBacbox
-- or
:lua require("comment-box").acbox()

-- A left aligned fixed size box with the text left justified,
-- using the syle 17 from the catalog:
:CBllbox17
-- or
:lua require("comment-box").llbox(17)
```
##### Removing a box

To remove a box, select it entirely, then use the command `CBdbox` (or create a keybind for it, see [Keybindings examples](#keybindings-examples))

##### Yank the content of a box

Select the box (or at least the part including the text), then use the command `CBy`.
(Note that the text is available in the `+` register, it assumes that you have the `clipboard` option set to `unnamedplus`. If not you will have to specify the register for pasting using `"+p`).

#### Lines

| Command | Description | function |
|--- | --- | --- |
|`CBline[num]` | _Left aligned line_ | `require("comment-box").line([num])` |
|`CBcline[num]` | _Centered line_ | `require("comment-box").cline([num])` |
|`CBrline[num]` | _Right aligned line_ | `require("comment-box").rline([num])` |

To draw a line, place your cursor where you want it and in _normal_ or _insert_ mode, use one of the command/function above.

**Note**: a line is centered or right aligned according to the width of your document (set to the standard 80 by default, you can change it with the `setup()` function - see [Configuration](#configuration-and-creating-your-own-type-of-box))

Examples:
```lua
-- A left aligned line:
:CBline
-- or
:lua require("comment-box").line()

-- A centered line:
:CBcline
-- or
:lua require("comment-box").cline()

-- A right aligned line using the style 6 from the catalog:
:CBrline6
-- or
:lua require("comment-box").rline(6)
```

### Keybindings examples

#### Vim script:

```shell
# left aligned fixed size box with left aligned text
nnoremap <Leader>bb <Cmd>lua require('comment-box').llbox()<CR>
vnoremap <Leader>bb <Cmd>lua require('comment-box').llbox()<CR>

# centered adapted box
nnoremap <Leader>bc <Cmd>lua require('comment-box').acbox()<CR>
vnoremap <Leader>bc <Cmd>lua require('comment-box').acbox()<CR>

# centered line
nnoremap <Leader>bl <Cmd>lua require('comment-box').cline()<CR>
inoremap <M-l> <Cmd>lua require('comment-box').cline()<CR>

# remove a box
vnoremap <Leader>bd <Cmd>lua require('comment-box').dbox()<CR>
```

#### Lua

```lua
local keymap = vim.keymap.set
local cb = require("comment-box")

-- left aligned fixed size box with left aligned text
keymap({ "n", "v"}, "<Leader>bb", cb.llbox, {})
-- centered adapted box
keymap({ "n", "v"}, "<Leader>bc", cb.acbox, {})

-- centered line
keymap("n", "<Leader>bl", cb.cline, {})
keymap("i", "<M-l>", cb.cline, {})

-- remove a box
keymap("v", "<Leader>bd", cb.dbox, {})
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
  doc_width = 80, -- width of the document
  box_width = 60, -- width of the boxes
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
  },
  outer_blank_lines = false, -- insert a blank line above and below the box
  inner_blank_lines = false, -- insert a blank line above and below the text
  line_blank_line_above = false, -- insert a blank line above the line
  line_blank_line_below = false, -- insert a blank line below the line
})
```

### `doc_width`

Width of the document. It is used to center the boxes and lines and determine the max width of the adapted boxes.

### `box_width`

Width of the fixed size boxes (must be <= `doc_width`).

### `borders`

The symbols used to draw the boxes. Let your creativity go wild! Or just use the default or choose from the predefined ones (see [Catalog](#the-catalog)).

If you want an element of the box to be invisible, you can use either `" "`(space) or `""`(empty string).

You can even create very ugly ones, no judgement!

![ASCII box](./imgs/ugly.jpg?raw=true)

### `line_width`

Width of the lines.

### `line`

The symbols used to draw the lines. Let your creativity go wild! Or just use the default or choose from the predefined ones (see [Catalog](#the-catalog)).

### `outer_blank_lines_above` `outer_blank_lines_below` and `inner_blank_lines`

![blank lines](./imgs/bc-blanklines.jpg?raw=true)

### `line_blank_line_above` and `line_blank_line_below`

Self explanatory!

## TODO

- [x] Convert commands creation from vimscript to lua
- [ ] "Titled lines" (issue #10)
- [x] Right alignement
- [ ] Option for displaying comments/docstring as virtual text (issue #5)
- [ ] Full support of multi-line style comments

## Acknowledgement

I learned and borrow from those plugins' code:

- [better-escape](https://github.com/max397574/better-escape.nvim)
- [nvim-comment](https://github.com/terrortylor/nvim-comment/blob/main/lua/nvim_comment.lua)

Thanks to [@HiPhish](https://github.com/HiPhish) for his excellent advice to make the code a bit better (I'm still working on it...) and all the contributors.
