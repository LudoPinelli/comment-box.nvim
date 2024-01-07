---@diagnostic disable: cast-local-type
--         ╭──────────────────────────────────────────────────────────╮
--         │                         SETTINGS                         │
--         ╰──────────────────────────────────────────────────────────╯

---@class CommentBoxConfig
local settings = {
  comment_style = "line", -- "line"|"block"|"auto"
  doc_width = 80,
  box_width = 60,
  borders = {
    top = "─",
    bottom = "─",
    left = "│",
    right = "│",
    top_left = "╭",
    top_right = "╮",
    bottom_left = "╰",
    bottom_right = "╯",
  },
  line_width = 70,
  lines = {
    line = "─",
    line_start = "─",
    line_end = "─",
    title_left = "─",
    title_right = "─",
  },
  outer_blank_lines_above = false,
  outer_blank_lines_below = false,
  inner_blank_lines = false,
  line_blank_line_above = false,
  line_blank_line_below = false,
}

--         ╭──────────────────────────────────────────────────────────╮
--         │                     LOCAL VARIABLES                      │
--         ╰──────────────────────────────────────────────────────────╯
local cat = require("comment-box.catalog")
local catalog = require("comment-box.catalog_view")
local utils = require("comment-box.utils")
local fn = vim.fn

---@type boolean
local centered_text = false
---@type boolean
local centered_box = false
---@type boolean
local centered_line = false
---@type boolean
local right_aligned_text = false
---@type boolean
local right_aligned_box = false
---@type boolean
local right_aligned_line = false
---@type boolean
local adapted = false

---@type boolean
local is_box = false

---@type number
local final_width = 0

---@type string, string
local lead_space_ab, lead_space_bb = "", ""

--         ╭──────────────────────────────────────────────────────────╮
--         │                          UTILS                           │
--         ╰──────────────────────────────────────────────────────────╯

-- Return the correct cursor position after a box has been created
---@param end_pos number
---@return number
local function set_cur_pos(end_pos)
  local cur_pos = end_pos + 2

  if settings.inner_blank_lines then
    cur_pos = cur_pos + 2
  end
  if settings.outer_blank_lines_above then
    cur_pos = cur_pos + 1
  end
  if settings.outer_blank_lines_below then
    cur_pos = cur_pos + 1
  end
  return cur_pos
end

-- prepare each line and rewrote the table in case of wrapping lines
---@param text string[]
---@return table
local function format_lines(text)
  final_width = 0
  local url_width = 0

  for _, str in ipairs(text) do
    local url_start, url_end = utils.is_url(str)
    if url_start then
      url_width = math.max(url_width, url_end - url_start + 1)
    end
  end

  local comment_string_l, comment_string_b_start, comment_string_b_end =
    utils.get_comment_string(vim.bo.filetype)
  local comment_string = ""
  if comment_string_l ~= "" then
    comment_string = comment_string_l
  elseif comment_string_b_start ~= "" then
    comment_string = comment_string_b_start
  end
  local offset

  for pos, str in ipairs(text) do
    table.remove(text, pos)
    if comment_string ~= "" then
      str = utils.skip_cs(
        str,
        comment_string_l,
        comment_string_b_start,
        comment_string_b_end
      )
      offset = fn.strdisplaywidth(comment_string) + 1
    else
      offset = 1
    end
    str = vim.trim(str)
    table.insert(text, pos, str)
    local str_width = fn.strdisplaywidth(str)
    if str_width == nil then
      str_width = 0
    end

    if is_box then
      if adapted then
        if str_width >= math.max(url_width, settings.doc_width - offset) then
          final_width = math.max(url_width, settings.box_width - offset)
        elseif
          str_width > final_width
          and final_width < math.max(url_width, settings.box_width - offset)
        then
          final_width = str_width + 2
        end
      else
        final_width = math.max(url_width, settings.box_width - offset)
      end
    else
      final_width = math.max(url_width, settings.line_width - offset)
    end

    if str_width > final_width then
      local to_insert = utils.wrap(str, final_width)
      for ipos, st in ipairs(to_insert) do
        table.insert(text, pos + ipos, st)
      end
      table.remove(text, pos)
    end
  end
  return text
end

-- Set the symbols used to draw the box
---@param choice number?
---@return table
local function set_borders(choice)
  choice = tonumber(choice) or 0
  local borders
  if choice == 0 then
    borders = settings.borders
  else
    borders = cat.boxes[choice] or settings.borders
  end
  return borders
end

-- Set the symbols used to draw the line
---@param choice number?
---@return table
local function set_line(choice)
  choice = tonumber(choice) or 0
  local symbols
  if choice == 0 then
    symbols = settings.lines
  else
    symbols = cat.lines[choice] or settings.lines
  end
  return symbols
end

---@param comment_style string
---@return string
---@return string
local function set_lead_space(comment_style)
  lead_space_ab = " "
  lead_space_bb = " "
  local comment_string_l, comment_string_b_start, _ =
    utils.get_comment_string(vim.bo.filetype)

  local comment_string
  if comment_style == "block" then
    comment_string = comment_string_b_start
  else
    comment_string = comment_string_l
  end
  if centered_box then
    lead_space_bb = string.rep(
      " ",
      math.floor(
        (settings.doc_width - final_width) / 2
          - fn.strdisplaywidth(comment_string)
          + 0.5
      )
    )
  end
  if right_aligned_box then
    lead_space_bb = string.rep(
      " ",
      settings.doc_width - final_width - fn.strdisplaywidth(comment_string) - 2
    )
  end

  return lead_space_ab, lead_space_bb
end

--         ╭──────────────────────────────────────────────────────────╮
--         │                           CORE                           │
--         ╰──────────────────────────────────────────────────────────╯

-- Return the selected text formated
---@return string[]
local function get_formated_text(lstart, lend)
  local line_start_pos, line_end_pos = utils.get_range(lstart, lend)
  local text =
    vim.api.nvim_buf_get_lines(0, line_start_pos - 1, line_end_pos, false)
  return format_lines(text)
end

-- Return the raw text
---@param lstart number
---@param lend number
---@return string[]
local function get_text(lstart, lend)
  local line_start_pos, line_end_pos = utils.get_range(lstart, lend)
  local text =
    vim.api.nvim_buf_get_lines(0, line_start_pos - 1, line_end_pos, false)
  local result = {}

  for i, str in ipairs(text) do
    -- Remove every spaces, non alphanumeric and | characters at the beginning of the string
    str = str:gsub("^[^%w|]+", "")
    -- Remove every spaces, non alphanumeric and | characters at the end of the string
    str = str:gsub("[^%w|]+$", "")
    if str ~= "" then
      table.insert(result, str)
    else
      if i > 1 and i < #text then
        table.insert(result, " ")
      end
    end
  end
  return result
end

-- Build the box
---@param choice number?
local function create_box(choice, lstart, lend)
  is_box = true
  local text = get_formated_text(lstart, lend)

  local filetype = vim.bo.filetype
  local comment_string_l, comment_string_b_start, comment_string_b_end =
    utils.get_comment_string(filetype)

  local comment_string_int_row
  local comment_style = settings.comment_style
  -- If the language has no single line comment:
  if comment_string_l == "" and comment_string_b_start ~= "" then
    comment_style = "block"
  end

  if comment_style == "line" and comment_string_l ~= "" then
    comment_string_int_row = comment_string_l
  else
    local cs_len = fn.strdisplaywidth(comment_string_b_start)
    if cs_len > 1 then
      comment_string_int_row = " " .. comment_string_b_start:sub(2, 2)
      if cs_len > 2 then
        comment_string_int_row = comment_string_int_row
          .. string.rep(" ", cs_len - 2)
      end
    end
  end
  if not comment_string_int_row then
    comment_string_int_row = ""
  end

  -- ╓                                                       ╖
  -- ║ Deal with the two ways to declare transparent borders ║
  -- ╙                                                       ╜

  local borders = set_borders(choice)
  local trail = " "

  if borders.top_left == "" then
    borders.top_left = " "
  end
  if borders.bottom_left == "" then
    borders.bottom_left = " "
  end
  if borders.top_right == " " then
    borders.top_right = ""
  end
  if borders.bottom_right == " " then
    borders.top_right = ""
  end
  if borders.top == "" then
    borders.top = " "
  end
  if borders.bottom == "" then
    borders.bottom = " "
  end
  if borders.right == " " or borders.right == "" then
    borders.right = ""
    trail = ""
  end
  if borders.left == "" then
    borders.left = " "
  end
  if borders.top == " " and borders.top_right == "" then
    borders.top = ""
  end
  if borders.bottom == " " and borders.bottom_right == "" then
    borders.bottom = ""
  end

  lead_space_ab, lead_space_bb = set_lead_space(comment_style)
  if borders.top_right == "" and borders.top == "" then
    lead_space_ab = ""
    if borders.top_left == " " then
      borders.top_left = ""
      lead_space_bb = ""
    end
  end
  if borders.bottom_right == "" and borders.bottom == "" then
    lead_space_ab = ""
    if borders.bottom_left == " " then
      borders.bottom_left = ""
      lead_space_bb = ""
    end
  end

  local ext_top_row = string.format(
    "%s%s%s%s%s",
    comment_string_int_row,
    lead_space_bb,
    borders.top_left,
    string.rep(borders.top, final_width),
    borders.top_right
  )

  local ext_bottom_row = string.format(
    "%s%s%s%s%s",
    comment_string_int_row,
    lead_space_bb,
    borders.bottom_left,
    string.rep(borders.bottom, final_width),
    borders.bottom_right
  )

  local inner_blank_line = string.format(
    "%s%s%s%s%s",
    comment_string_int_row,
    lead_space_bb,
    borders.left,
    string.rep(trail, final_width),
    borders.right
  )

  local int_row = ""
  local lines = {}

  if settings.outer_blank_lines_above then
    table.insert(lines, "")
  end

  if comment_style == "block" or (comment_style == "auto") then
    table.insert(lines, comment_string_b_start)
  end

  table.insert(lines, ext_top_row)

  if settings.inner_blank_lines then
    table.insert(lines, inner_blank_line)
  end

  if centered_text or right_aligned_text then
    -- ╓                                   ╖
    -- ║ If text centered or right aligned ║
    -- ╙                                   ╜

    for _, line in pairs(text) do
      local start_pad, end_pad =
        utils.get_pad(line, centered_text, right_aligned_text, final_width)

      lead_space_ab, lead_space_bb = set_lead_space(comment_style)
      if borders.right == "" and line == "" then
        lead_space_ab = ""
        if borders.left == " " or borders.left == "" then
          lead_space_bb = ""
          borders.left = ""
        end
      end

      int_row = string.format(
        "%s%s%s%s%s%s%s",
        comment_string_int_row,
        lead_space_bb,
        borders.left,
        string.rep(lead_space_ab, start_pad),
        line,
        string.rep(trail, end_pad),
        borders.right
      )

      table.insert(lines, int_row)
    end
  else
    -- ╓                        ╖
    -- ║ If text left justified ║
    -- ╙                        ╜

    for _, line in pairs(text) do
      local offset = 1

      if not centered_box and line:find("^\t") then
        offset = 0
      end

      local pad = final_width - fn.strdisplaywidth(line) - offset

      lead_space_ab, lead_space_bb = set_lead_space(comment_style)
      trail = " "
      if borders.right == "" and line == "" then
        lead_space_ab = ""
        trail = ""
        pad = 0
        if borders.left == " " or borders.left == "" then
          lead_space_bb = ""
          borders.left = ""
        end
      end

      int_row = string.format(
        "%s%s%s%s%s%s%s",
        comment_string_int_row,
        lead_space_bb,
        borders.left,
        lead_space_ab,
        line,
        string.rep(trail, pad),
        borders.right
      )

      table.insert(lines, int_row)
    end
  end

  if settings.inner_blank_lines then
    table.insert(lines, inner_blank_line)
  end

  table.insert(lines, ext_bottom_row)

  if comment_style == "block" or (comment_style == "auto") then
    table.insert(lines, comment_string_b_end)
  end

  if settings.outer_blank_lines_below then
    table.insert(lines, "")
  end

  return lines
end

-- Remove a box or a titled line
---@param lstart number
---@param lend number
local function remove(lstart, lend)
  local filetype = vim.bo.filetype
  local comment_string_l, comment_string_b_start, comment_string_b_end =
    utils.get_comment_string(filetype)

  local result = get_text(lstart, lend)
  local comment_style = "line"
  -- If the language has no single line comment:
  if comment_string_l == "" and comment_string_b_start ~= "" then
    comment_style = "block"
  end

  local comment_string_int_row
  if comment_style == "line" then
    comment_string_int_row = comment_string_l
  else
    local cs_len = fn.strdisplaywidth(comment_string_b_start)
    if cs_len > 1 then
      comment_string_int_row = " " .. comment_string_b_start:sub(2, 2)
      if cs_len > 2 then
        comment_string_int_row = comment_string_int_row
          .. string.rep(" ", cs_len - 2)
      end
    end
  end

  local lines = {}
  if comment_style == "block" then
    table.insert(lines, comment_string_b_start)
  end

  local row = ""
  for _, line in pairs(result) do
    if line ~= "" then
      row = string.format("%s%s%s", comment_string_int_row, " ", line)
      table.insert(lines, row)
    end
  end

  if comment_style == "block" then
    table.insert(lines, comment_string_b_end)
  end

  local line_start_pos, line_end_pos = utils.get_range(lstart, lend)
  vim.api.nvim_buf_set_lines(0, line_start_pos - 1, line_end_pos, false, lines)
end

-- yank the content of a box or titled line
---@param lstart number
---@param lend number
local function yank(lstart, lend)
  local tab_text = get_text(lstart, lend)
  local tab_text_to_str = table.concat(tab_text, "\n")

  ---@diagnostic disable-next-line: param-type-mismatch
  fn.setreg("+", tab_text_to_str .. "\n", "l")
end

-- Build a line
---@param choice number?
---@return string[]
local function create_line(choice)
  is_box = false

  local filetype = vim.bo.filetype
  local comment_string_l, comment_string_b_start, comment_string_b_end =
    utils.get_comment_string(filetype)

  local offset = 0
  local comment_string_int_row
  local comment_style = settings.comment_style
  if comment_style == "line" or comment_style == "auto" then
    comment_string_int_row = comment_string_l
    offset = fn.strdisplaywidth(comment_string_l)
  else
    local cs_len = fn.strdisplaywidth(comment_string_b_start)
    if cs_len > 1 then
      comment_string_int_row = " " .. comment_string_b_start:sub(2, 2)
      if cs_len > 2 then
        comment_string_int_row = comment_string_int_row
          .. string.rep(" ", cs_len - 2)
      end
    end
    offset = fn.strdisplaywidth(comment_string_b_start)
  end

  if settings.line_width > settings.doc_width + offset then
    settings.line_width = settings.doc_width + offset
  end

  local lead_space = " "
  if centered_line then
    lead_space = string.rep(
      " ",
      math.floor((settings.doc_width - settings.line_width) / 2) - offset
    )
  elseif right_aligned_line then
    lead_space =
      string.rep(" ", settings.doc_width - settings.line_width - offset)
  end

  if lead_space == "" then
    lead_space = " "
  end

  local line = {}
  if settings.line_blank_line_above then
    table.insert(line, "")
  end

  if comment_style == "block" then
    table.insert(line, comment_string_b_start)
  end

  local symbols = set_line(choice)
  table.insert(
    line,
    string.format(
      "%s%s%s%s%s",
      comment_string_int_row,
      lead_space,
      symbols.line_start,
      string.rep(
        symbols.line,
        settings.line_width
          - fn.strdisplaywidth(symbols.line_start)
          - fn.strdisplaywidth(symbols.line_end)
      ),
      symbols.line_end
    )
  )

  if comment_style == "block" then
    table.insert(line, comment_string_b_end)
  end

  if settings.line_blank_line_below then
    table.insert(line, "")
  end
  return line
end

---@param choice number?
---@return string[]
local function create_titled_line(choice, lstart, lend)
  is_box = false
  local filetype = vim.bo.filetype
  local comment_string_l, comment_string_b_start, comment_string_b_end =
    utils.get_comment_string(filetype)
  local offset = fn.strdisplaywidth(comment_string_l)

  if settings.line_width > settings.doc_width + offset then
    settings.line_width = settings.doc_width + offset
  end

  local text = get_formated_text(lstart, lend)
  local start_pad, end_pad =
    utils.get_pad(text[1], centered_text, right_aligned_text, final_width)
  if start_pad > end_pad then
    start_pad = start_pad - offset - 1
  else
    if end_pad > start_pad then
      end_pad = end_pad - offset - 1
    end
  end

  local lead_space = " "
  if centered_line then
    lead_space = string.rep(
      " ",
      math.floor((settings.doc_width - settings.line_width) / 2) - offset
    )
  else
    if right_aligned_line then
      lead_space =
        string.rep(" ", settings.doc_width - settings.line_width - offset)
    end
  end

  if lead_space == "" then
    lead_space = " "
  end

  local is_block
  if math.abs(lend - lstart) > 0 then
    is_block = true
  else
    is_block = false
  end

  local comment_string_int_row
  local comment_style = settings.comment_style
  -- If the language has no single line comment:
  if comment_string_l == "" and comment_string_b_start ~= "" then
    comment_style = "block"
  end

  if comment_style == "line" or (comment_style == "auto" and not is_block) then
    comment_string_int_row = comment_string_l
  else
    local cs_len = fn.strdisplaywidth(comment_string_b_start)
    if cs_len > 1 then
      comment_string_int_row = " " .. comment_string_b_start:sub(2, 2)
      if cs_len > 2 then
        comment_string_int_row = comment_string_int_row
          .. string.rep(" ", cs_len - 2)
      end
    end
  end

  local line = {}
  if settings.line_blank_line_above then
    table.insert(line, "")
  end
  if comment_style == "block" or (comment_style == "auto" and is_block) then
    table.insert(line, comment_string_b_start)
  end

  local symbols = set_line(choice)
  table.insert(
    line,
    string.format(
      "%s%s%s%s%s%s%s%s%s%s%s",
      comment_string_int_row,
      lead_space,
      symbols.line_start,
      string.rep(symbols.line, start_pad),
      symbols.title_left,
      " ",
      text[1],
      " ",
      symbols.title_right,
      string.rep(symbols.line, end_pad),
      symbols.line_end
    )
  )
  if #text > 1 then
    for i, value in ipairs(text) do
      if i > 1 then
        table.insert(
          line,
          string.format("%s%s%s", comment_string_int_row, " ", value)
        )
      end
    end
  end

  if comment_style == "block" or (comment_style == "auto" and is_block) then
    table.insert(line, comment_string_b_end)
  end

  if settings.line_blank_line_below then
    table.insert(line, "")
  end
  return line
end

---@param choice number
---@param lstart number
---@param lend number
local function display_box(choice, lstart, lend)
  local line_start_pos, line_end_pos = utils.get_range(lstart, lend)
  vim.api.nvim_buf_set_lines(
    0,
    line_start_pos - 1,
    line_end_pos,
    false,
    create_box(choice, lstart, lend)
  )
  -- Move the cursor to match the result
  vim.api.nvim_win_set_cursor(0, { set_cur_pos(line_end_pos), 1 })
end

---@param choice number
local function display_line(choice)
  local line = fn.line(".")
  line = tonumber(line) or 1

  vim.api.nvim_buf_set_lines(0, line - 1, line, false, create_line(choice))

  local cur = vim.api.nvim_win_get_cursor(0)
  if settings.line_blank_line_below then
    cur[1] = cur[1] + 1
  end
  if settings.line_blank_line_above then
    cur[1] = cur[1] + 1
  end
  vim.api.nvim_win_set_cursor(0, cur)
end

---@param choice number
---@param lstart number
---@param lend number
local function display_titled_line(choice, lstart, lend)
  local line_start_pos, line_end_pos = utils.get_range(lstart, lend)
  vim.api.nvim_buf_set_lines(
    0,
    line_start_pos - 1,
    line_end_pos,
    false,
    create_titled_line(choice, lstart, lend)
  )

  local cur = vim.api.nvim_win_get_cursor(0)
  if settings.line_blank_line_below then
    cur[1] = cur[1] + 1
  end
  if settings.line_blank_line_above then
    cur[1] = cur[1] + 1
  end
  vim.api.nvim_win_set_cursor(0, cur)
end

--         ╭──────────────────────────────────────────────────────────╮
--         │                     PUBLIC FUNCTIONS                     │
--         ╰──────────────────────────────────────────────────────────╯

-- Print a left aligned box with text left aligned
---@param choice number
---@param lstart number
---@param lend number
local function print_llbox(choice, lstart, lend)
  centered_text = false
  right_aligned_text = false
  centered_box = false
  right_aligned_box = false
  adapted = false
  display_box(choice, lstart, lend)
end

-- Print a left aligned box with text centered
---@param choice number
---@param lstart number
---@param lend number
local function print_lcbox(choice, lstart, lend)
  centered_text = true
  right_aligned_text = false
  centered_box = false
  right_aligned_box = false
  adapted = false
  display_box(choice, lstart, lend)
end

-- Print a left aligned box with text right aligned
---@param choice number
---@param lstart number
---@param lend number
local function print_lrbox(choice, lstart, lend)
  centered_text = false
  right_aligned_text = true
  centered_box = false
  right_aligned_box = false
  adapted = false
  display_box(choice, lstart, lend)
end

-- Print a centered box with text left aligned
---@param choice number
---@param lstart number
---@param lend number
local function print_clbox(choice, lstart, lend)
  centered_text = false
  right_aligned_text = false
  centered_box = true
  right_aligned_box = false
  adapted = false
  display_box(choice, lstart, lend)
end

-- Print a centered box with text centered
---@param choice number
---@param lstart number
---@param lend number
local function print_ccbox(choice, lstart, lend)
  centered_text = true
  right_aligned_text = false
  centered_box = true
  right_aligned_box = false
  adapted = false
  display_box(choice, lstart, lend)
end

-- Print a centered box with text right aligned
---@param choice number
---@param lstart number
---@param lend number
local function print_crbox(choice, lstart, lend)
  centered_text = false
  right_aligned_text = true
  centered_box = true
  right_aligned_box = false
  adapted = false
  display_box(choice, lstart, lend)
end

-- Print a right aligned box with text left aligned
---@param choice number
---@param lstart number
---@param lend number
local function print_rlbox(choice, lstart, lend)
  centered_text = false
  right_aligned_text = false
  centered_box = false
  right_aligned_box = true
  adapted = false
  display_box(choice, lstart, lend)
end

-- Print a right aligned box with text centered
---@param choice number
---@param lstart number
---@param lend number
local function print_rcbox(choice, lstart, lend)
  centered_text = true
  right_aligned_text = false
  centered_box = false
  right_aligned_box = true
  adapted = false
  display_box(choice, lstart, lend)
end

-- Print a right aligned box with text right aligned
---@param choice number
---@param lstart number
---@param lend number
local function print_rrbox(choice, lstart, lend)
  centered_text = false
  right_aligned_text = true
  centered_box = false
  right_aligned_box = true
  adapted = false
  display_box(choice, lstart, lend)
end

-- Print a left aligned adapted box
---@param choice number
---@param lstart number
---@param lend number
local function print_labox(choice, lstart, lend)
  centered_text = false
  right_aligned_text = false
  centered_box = false
  right_aligned_box = false
  adapted = true
  display_box(choice, lstart, lend)
end

-- Print a centered adapted box
---@param choice number
---@param lstart number
---@param lend number
local function print_cabox(choice, lstart, lend)
  centered_text = true
  right_aligned_text = false
  centered_box = true
  right_aligned_box = false
  adapted = true
  display_box(choice, lstart, lend)
end

-- Print a right aligned adapted box
---@param choice number
---@param lstart number
---@param lend number
local function print_rabox(choice, lstart, lend)
  centered_text = false
  right_aligned_text = true
  centered_box = false
  right_aligned_box = true
  adapted = true
  display_box(choice, lstart, lend)
end

-- Remove a box or a titled line
---@param lstart number
---@param lend number
local function del(lstart, lend)
  remove(lstart, lend)
end

-- Yank the content of a box or a titled line
---@param lstart number
---@param lend number
local function yank_in(lstart, lend)
  yank(lstart, lend)
end

-- Print a left aligned line
---@param choice number
local function print_line(choice)
  centered_line = false
  right_aligned_line = false
  display_line(choice)
end

-- Print a centered line
---@param choice number
local function print_cline(choice)
  centered_line = true
  right_aligned_line = false
  display_line(choice)
end

-- Print a right aligned line
---@param choice number
local function print_rline(choice)
  centered_line = false
  right_aligned_line = true
  display_line(choice)
end

-- Print a left aligned titled line with text left aligned
---@param choice number
local function print_llline(choice, lstart, lend)
  centered_text = false
  right_aligned_text = false
  centered_line = false
  right_aligned_line = false
  display_titled_line(choice, lstart, lend)
end

-- Print a left aligned titled line with text centered
---@param choice number
local function print_lcline(choice, lstart, lend)
  centered_text = true
  right_aligned_text = false
  centered_line = false
  right_aligned_line = false
  adapted = false
  display_titled_line(choice, lstart, lend)
end

-- Print a left aligned titled line with text right aligned
---@param choice number
local function print_lrline(choice, lstart, lend)
  centered_text = false
  right_aligned_text = true
  centered_line = false
  right_aligned_line = false
  adapted = false
  display_titled_line(choice, lstart, lend)
end

-- Print a centered titled line with text left aligned
---@param choice number
local function print_clline(choice, lstart, lend)
  centered_text = false
  right_aligned_text = false
  centered_line = true
  right_aligned_line = false
  adapted = false
  display_titled_line(choice, lstart, lend)
end

-- Print a centered titled line with text centered
---@param choice number
local function print_ccline(choice, lstart, lend)
  centered_text = true
  right_aligned_text = false
  centered_line = true
  right_aligned_line = false
  adapted = false
  display_titled_line(choice, lstart, lend)
end

-- Print a centered titled line with text right aligned
---@param choice number
local function print_crline(choice, lstart, lend)
  centered_text = false
  right_aligned_text = true
  centered_line = true
  right_aligned_line = false
  adapted = false
  display_titled_line(choice, lstart, lend)
end

-- Print a right aligned titled line with text left aligned
---@param choice number
local function print_rlline(choice, lstart, lend)
  centered_text = false
  right_aligned_text = false
  centered_line = false
  right_aligned_line = true
  adapted = false
  display_titled_line(choice, lstart, lend)
end

-- Print a right aligned titled line with text centered
---@param choice number
local function print_rcline(choice, lstart, lend)
  centered_text = true
  right_aligned_text = false
  centered_line = false
  right_aligned_line = true
  adapted = false
  display_titled_line(choice, lstart, lend)
end

-- Print a right aligned titled line with text right aligned
---@param choice number
local function print_rrline(choice, lstart, lend)
  centered_text = false
  right_aligned_text = true
  centered_line = false
  right_aligned_line = true
  adapted = false
  display_titled_line(choice, lstart, lend)
end

local function open_catalog()
  catalog.view_cat()
end

-- Config
---@param config? CommentBoxConfig
local function setup(config)
  settings = vim.tbl_deep_extend("force", settings, config or {})
end

-- ── Returns ───────────────────────────────────────────────────────────

return {
  llbox = print_llbox,
  lcbox = print_lcbox,
  lrbox = print_lrbox,
  clbox = print_clbox,
  ccbox = print_ccbox,
  crbox = print_crbox,
  rlbox = print_rlbox,
  rcbox = print_rcbox,
  rrbox = print_rrbox,
  albox = print_labox,
  acbox = print_cabox,
  arbox = print_rabox,
  dbox = del,
  yank = yank_in,
  line = print_line,
  cline = print_cline,
  rline = print_rline,
  llline = print_llline,
  lcline = print_lcline,
  lrline = print_lrline,
  clline = print_clline,
  ccline = print_ccline,
  crline = print_crline,
  rlline = print_rlline,
  rcline = print_rcline,
  rrline = print_rrline,
  catalog = open_catalog,
  setup = setup,
}
