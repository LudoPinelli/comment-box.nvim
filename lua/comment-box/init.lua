--         ╭──────────────────────────────────────────────────────────╮
--         │                         SETTINGS                         │
--         ╰──────────────────────────────────────────────────────────╯

---@class CommentBoxConfig
local settings = {
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

---@type string
local comment_string, comment_string_bottom_row, comment_string_int_row, comment_string_end
---@type number, number
local line_start_pos, line_end_pos

---@type boolean
local centered_text
---@type boolean
local centered_box
---@type boolean
local right_aligned_text
---@type boolean
local right_aligned_box
---@type number
local final_box_width
---@type boolean
local adapted

---@type string, string
local lead_space_ab, lead_space_bb

--         ╭──────────────────────────────────────────────────────────╮
--         │                          UTILS                           │
--         ╰──────────────────────────────────────────────────────────╯

-- Compute padding
local function get_pad(line)
  local start_pad = 0
  local end_pad = 0
  if centered_text then
    start_pad = math.floor((final_box_width - vim.fn.strdisplaywidth(line)) / 2)
    end_pad = final_box_width - (start_pad + vim.fn.strdisplaywidth(line))
  elseif right_aligned_text then
    start_pad = final_box_width - vim.fn.strdisplaywidth(line) - 1
    end_pad = final_box_width - (start_pad + vim.fn.strdisplaywidth(line))
  end
  return start_pad, end_pad
end

-- Store the range of the selected text in 'line_start_pos'/'line_end_pos'
---@param lstart? number
---@param lend? number
local function get_range(lstart, lend)
  local mode = vim.api.nvim_get_mode().mode

  if lstart and lend and lend ~= lstart then
    line_start_pos = lstart
    line_end_pos = lend
  else
    if mode:match("[vV]") then
      line_start_pos = vim.fn.line("v")
      line_end_pos = vim.fn.line(".")
      if line_start_pos > line_end_pos then -- if backward selected
        line_start_pos, line_end_pos = line_end_pos, line_start_pos
      end
    else -- if not in visual mode, return the current line
      line_start_pos = vim.fn.line(".")
      line_end_pos = line_start_pos
    end
  end
end

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

-- Skip comment string if there is one at the beginning of the line
---@param line string
---@return string
local function skip_cs(line)
  local trimmed_line = vim.trim(line)
  local cs_len = vim.fn.strdisplaywidth(comment_string)

  if trimmed_line:sub(1, cs_len) == comment_string then
    line = line:gsub("^%s+", "") -- remove whitespace before comment string
    line = line:gsub(vim.pesc(comment_string), "", 1) -- remove comment string
    line = line:gsub("[ \t]+%f[\r\n%z]", "") -- remove trailing spaces
  end
  if centered_text or right_aligned_text then
    return vim.trim(line) -- if centered need to trim both ends for correct padding
  else
    return line
  end
end

-- See if a piece of text contains a url
---@param text string
---@return number|nil, number|nil
local function is_url(text)
  return vim.regex("\\v(https?|ftp|file|ssh|git|mailto)://\\S+"):match_str(text)
end

-- Wrap lines too long to fit in box
---@param text string
---@return string[]
local function wrap(text)
  local str_tab = {}
  local str = text:sub(1, final_box_width - 6)
  local rstr = str:reverse()
  local f = rstr:find(" ")
  local url_start, _ = is_url(text)

  if f and (not url_start or f < url_start) then
    f = final_box_width - 6 - f
    table.insert(str_tab, string.sub(text, 1, f))
    table.insert(str_tab, string.sub(text, f + 1))
  else
    table.insert(str_tab, text)
  end
  return str_tab
end

-- prepare each line and rewrote the table in case of wraping lines
---@param text string[]
local function format_lines(text)
  final_box_width = 0
  local url_width = 0

  for _, str in ipairs(text) do
    local url_start, url_end = is_url(str)
    if url_start then
      url_width = math.max(url_width, url_end - url_start + 1)
    end
  end

  for pos, str in ipairs(text) do
    table.remove(text, pos)
    if comment_string ~= nil then
      str = skip_cs(str)
    end
    str = vim.trim(str)
    table.insert(text, pos, str)

    if adapted then
      if
        vim.fn.strdisplaywidth(str)
        >= math.max(url_width, settings.doc_width - 3)
      then
        final_box_width = math.max(url_width, settings.doc_width - 3)
      elseif
        vim.fn.strdisplaywidth(str) > final_box_width
        and final_box_width < math.max(url_width, settings.doc_width - 3)
      then
        final_box_width = vim.fn.strdisplaywidth(str) + 3
      end
    else
      final_box_width = math.max(url_width, settings.box_width - 3)
    end

    if vim.fn.strdisplaywidth(str) > final_box_width then
      local to_insert = wrap(str)
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
  choice = choice or 0
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
  choice = choice or 0
  local symbols
  if choice == 0 then
    symbols = settings.lines
  else
    symbols = cat.lines[choice] or settings.lines
  end
  return symbols
end

---@return string
---@return string
local function set_lead_space()
  lead_space_ab = " "
  lead_space_bb = " "
  if centered_box then
    lead_space_bb = string.rep(
      " ",
      math.floor(
        (settings.doc_width - final_box_width) / 2
          - vim.fn.strdisplaywidth(comment_string)
          + 0.5
      )
    )
  end
  if right_aligned_box then
    lead_space_bb = string.rep(
      " ",
      settings.doc_width
        - final_box_width
        - vim.fn.strdisplaywidth(comment_string)
        - 2
    )
  end

  return lead_space_ab, lead_space_bb
end

--         ╭──────────────────────────────────────────────────────────╮
--         │                           CORE                           │
--         ╰──────────────────────────────────────────────────────────╯

-- Return the selected text formated
---@return string[]
local function get_formated_text()
  local text =
    vim.api.nvim_buf_get_lines(0, line_start_pos - 1, line_end_pos, false)
  return format_lines(text)
end

-- Return the raw text
---@param lstart number?
---@param lend number?
---@return string[]
local function get_text(lstart, lend)
  get_range(lstart, lend)
  local text =
    vim.api.nvim_buf_get_lines(0, line_start_pos - 1, line_end_pos, false)
  local result = {}

  for _, str in ipairs(text) do
    -- Remove every spaces, non alphanumeric and | characters at the begining of the string
    str = str:gsub("^[^%w|]+", "")
    -- Remove every spaces, non alphanumeric and | characters at the end of the string
    str = str:gsub("[^%w|]+$", "")
    if str ~= nil then
      table.insert(result, str)
    end
  end
  return result
end

-- Build the box
---@param choice number?
local function create_box(choice)
  local borders = set_borders(choice)
  local filetype = vim.bo.filetype
  comment_string = vim.bo.commentstring

  comment_string, comment_string_end = comment_string:match("^(.*)%%s(.*)")
  if comment_string ~= nil then
    comment_string = vim.trim(comment_string)
  end

  if not comment_string or filetype == "markdown" or filetype == "org" then
    comment_string = ""
  end

  -- TODO: Implement below as a style option for multi style commenting.
  if comment_string_end ~= "" then
    comment_string_bottom_row = string.rep(" ", string.len(comment_string))
    comment_string_int_row = comment_string_bottom_row
  else
    comment_string_bottom_row = comment_string
    comment_string_int_row = comment_string
  end

  local text = get_formated_text()
  local trail = " "

  -- ╓                                                       ╖
  -- ║ Deal with the two ways to declare transparent borders ║
  -- ╙                                                       ╜

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

  lead_space_ab, lead_space_bb = set_lead_space()
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
    comment_string,
    lead_space_bb,
    borders.top_left,
    string.rep(borders.top, final_box_width),
    borders.top_right
  )

  local ext_bottom_row = string.format(
    "%s%s%s%s%s",
    comment_string_bottom_row,
    lead_space_bb,
    borders.bottom_left,
    string.rep(borders.bottom, final_box_width),
    borders.bottom_right
  )

  local inner_blank_line = string.format(
    "%s%s%s%s%s",
    comment_string_int_row,
    lead_space_bb,
    borders.left,
    string.rep(trail, final_box_width),
    borders.right
  )

  local int_row = ""
  local lines = {}

  if settings.outer_blank_lines_above then
    table.insert(lines, "")
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
      local start_pad, end_pad = get_pad(line)

      lead_space_ab, lead_space_bb = set_lead_space()
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

      local pad = final_box_width - vim.fn.strdisplaywidth(line) - offset

      lead_space_ab, lead_space_bb = set_lead_space()
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

  if comment_string_end ~= "" then
    table.insert(lines, comment_string_end)
  end

  if settings.outer_blank_lines_below then
    table.insert(lines, "")
  end

  return lines
end

-- Remove a box
---@param lstart number?
---@param lend number?
local function remove_box(lstart, lend)
  local filetype = vim.bo.filetype
  comment_string = vim.bo.commentstring

  comment_string, comment_string_end = comment_string:match("^(.*)%%s(.*)")
  comment_string = vim.trim(comment_string)

  if not comment_string or filetype == "markdown" or filetype == "org" then
    comment_string = ""
  end

  local result = get_text(lstart, lend)
  local row = ""
  local lines = {}

  for _, line in pairs(result) do
    if line ~= "" then
      row = string.format("%s%s%s", comment_string, " ", line)
      table.insert(lines, row)
    end
  end

  vim.api.nvim_buf_set_lines(0, line_start_pos - 1, line_end_pos, false, lines)
end

-- yank the content of a box
local function yank(lstart, lend)
  local tab_text = get_text(lstart, lend)
  local tab_text_to_str = table.concat(tab_text, "\n")

  vim.fn.setreg("+", tab_text_to_str .. "\n", "l")
end

-- Build a line
---@param choice number?
---@param centered_line boolean
local function create_line(choice, centered_line, right_aligned_line)
  local symbols = set_line(choice)
  comment_string = vim.bo.commentstring
  local line = {}
  local lead_space = " "
  local filetype = vim.bo.filetype

  if centered_line then
    lead_space = string.rep(
      " ",
      math.floor(
        (settings.doc_width - settings.line_width) / 2
          - vim.fn.strdisplaywidth(comment_string)
      )
    )
  elseif right_aligned_line then
    lead_space = string.rep(
      " ",
      settings.doc_width
        - settings.line_width
        - vim.fn.strdisplaywidth(comment_string)
        + 2
    )
  end

  if lead_space == "" then
    lead_space = " "
  end

  comment_string, comment_string_end = comment_string:match("^(.*)%%s(.*)")
  comment_string = vim.trim(comment_string)
  comment_string_end = vim.trim(comment_string_end)

  if not comment_string or filetype == "markdown" or filetype == "org" then
    comment_string = ""
  end

  if settings.line_blank_line_above then
    table.insert(line, "")
  end
  table.insert(
    line,
    string.format(
      "%s%s%s%s%s%s",
      comment_string,
      lead_space,
      symbols.line_start,
      string.rep(symbols.line, settings.line_width - 2),
      symbols.line_end,
      comment_string_end
    )
  )
  if settings.line_blank_line_below then
    table.insert(line, "")
  end
  return line
end

---@param choice number?
---@param lstart number?
---@param lend number?
local function display_box(choice, lstart, lend)
  get_range(lstart, lend)
  vim.api.nvim_buf_set_lines(
    0,
    line_start_pos - 1,
    line_end_pos,
    false,
    create_box(choice)
  )
  -- Move the cursor to match the result
  vim.api.nvim_win_set_cursor(0, { set_cur_pos(line_end_pos), 1 })
end

---@param choice number?
---@param centered_line boolean
local function display_line(choice, centered_line, right_aligned_line)
  local line = vim.fn.line(".")
  vim.api.nvim_buf_set_lines(
    0,
    line - 1,
    tonumber(line),
    false,
    create_line(choice, centered_line, right_aligned_line)
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
---@param choice number?
---@param lstart number?
---@param lend number?
local function print_llbox(choice, lstart, lend)
  choice = tonumber(choice)
  lstart = tonumber(lstart)
  lend = tonumber(lend)
  centered_text = false
  right_aligned_text = false
  centered_box = false
  right_aligned_box = false
  adapted = false
  display_box(choice, lstart, lend)
end

-- Print a left aligned box with text centered
---@param choice number?
---@param lstart number?
---@param lend number?
local function print_lcbox(choice, lstart, lend)
  choice = tonumber(choice)
  lstart = tonumber(lstart)
  lend = tonumber(lend)
  centered_text = true
  right_aligned_text = false
  centered_box = false
  right_aligned_box = false
  adapted = false
  display_box(choice, lstart, lend)
end

-- Print a left aligned box with text right aligned
---@param choice number?
---@param lstart number?
---@param lend number?
local function print_lrbox(choice, lstart, lend)
  choice = tonumber(choice)
  lstart = tonumber(lstart)
  lend = tonumber(lend)
  centered_text = false
  right_aligned_text = true
  centered_box = false
  right_aligned_box = false
  adapted = false
  display_box(choice, lstart, lend)
end

-- Print a centered box with text left aligned
---@param choice number?
local function print_clbox(choice, lstart, lend)
  choice = tonumber(choice)
  lstart = tonumber(lstart)
  lend = tonumber(lend)
  centered_text = false
  right_aligned_text = false
  centered_box = true
  right_aligned_box = false
  adapted = false
  display_box(choice, lstart, lend)
end

-- Print a centered box with text centered
---@param choice number?
---@param lstart number?
---@param lend number?
local function print_ccbox(choice, lstart, lend)
  choice = tonumber(choice)
  lstart = tonumber(lstart)
  lend = tonumber(lend)
  centered_text = true
  right_aligned_text = false
  centered_box = true
  right_aligned_box = false
  adapted = false
  display_box(choice, lstart, lend)
end

-- Print a centered box with text right aligned
---@param choice number?
---@param lstart number?
---@param lend number?
local function print_crbox(choice, lstart, lend)
  choice = tonumber(choice)
  lstart = tonumber(lstart)
  lend = tonumber(lend)
  centered_text = false
  right_aligned_text = true
  centered_box = true
  right_aligned_box = false
  adapted = false
  display_box(choice, lstart, lend)
end

-- Print a right aligned box with text left aligned
---@param choice number?
local function print_rlbox(choice, lstart, lend)
  choice = tonumber(choice)
  lstart = tonumber(lstart)
  lend = tonumber(lend)
  centered_text = false
  right_aligned_text = false
  centered_box = false
  right_aligned_box = true
  adapted = false
  display_box(choice, lstart, lend)
end

-- Print a right aligned box with text centered
---@param choice number?
---@param lstart number?
---@param lend number?
local function print_rcbox(choice, lstart, lend)
  choice = tonumber(choice)
  lstart = tonumber(lstart)
  lend = tonumber(lend)
  centered_text = true
  right_aligned_text = false
  centered_box = false
  right_aligned_box = true
  adapted = false
  display_box(choice, lstart, lend)
end

-- Print a right aligned box with text right aligned
---@param choice number?
---@param lstart number?
---@param lend number?
local function print_rrbox(choice, lstart, lend)
  choice = tonumber(choice)
  lstart = tonumber(lstart)
  lend = tonumber(lend)
  centered_text = false
  right_aligned_text = true
  centered_box = false
  right_aligned_box = true
  adapted = false
  display_box(choice, lstart, lend)
end

-- Print a left aligned adapted box
---@param choice number?
---@param lstart number?
---@param lend number?
local function print_albox(choice, lstart, lend)
  choice = tonumber(choice)
  lstart = tonumber(lstart)
  lend = tonumber(lend)
  centered_text = false
  right_aligned_text = false
  centered_box = false
  right_aligned_box = false
  adapted = true
  display_box(choice, lstart, lend)
end

-- Print a centered adapted box
---@param choice number?
---@param lstart number?
---@param lend number?
local function print_acbox(choice, lstart, lend)
  choice = tonumber(choice)
  lstart = tonumber(lstart)
  lend = tonumber(lend)
  centered_text = true
  right_aligned_text = false
  centered_box = true
  right_aligned_box = false
  adapted = true
  display_box(choice, lstart, lend)
end

-- Print a right aligned adapted box
---@param choice number?
---@param lstart number?
---@param lend number?
local function print_arbox(choice, lstart, lend)
  choice = tonumber(choice)
  lstart = tonumber(lstart)
  lend = tonumber(lend)
  centered_text = false
  right_aligned_text = true
  centered_box = false
  right_aligned_box = true
  adapted = true
  display_box(choice, lstart, lend)
end

-- Remove a box
---@param lstart number?
---@param lend number?
local function delete_box(lstart, lend)
  lstart = tonumber(lstart)
  lend = tonumber(lend)
  remove_box(lstart, lend)
end

-- Yank the content of a box
---@param lstart number?
---@param lend number?
local function yank_in_box(lstart, lend)
  lstart = tonumber(lstart)
  lend = tonumber(lend)
  yank(lstart, lend)
end

-- Print a left aligned line
---@param choice number?
local function print_line(choice)
  choice = tonumber(choice)
  local centered_line = false
  local right_aligned_line = false
  display_line(choice, centered_line, right_aligned_line)
end

-- Print a centered line
---@param choice number?
local function print_cline(choice)
  choice = tonumber(choice)
  local centered_line = true
  local right_aligned_line = false
  display_line(choice, centered_line, right_aligned_line)
end

-- Print a right aligned line
---@param choice number?
local function print_rline(choice)
  choice = tonumber(choice)
  local centered_line = false
  local right_aligned_line = true
  display_line(choice, centered_line, right_aligned_line)
end

local function open_catalog()
  catalog.view_cat()
end

-- Config
---@param config? CommentBoxConfig
local function setup(config)
  settings = vim.tbl_deep_extend("force", settings, config or {})
end

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
  albox = print_albox,
  acbox = print_acbox,
  arbox = print_arbox,
  dbox = delete_box,
  yank = yank_in_box,
  line = print_line,
  cline = print_cline,
  rline = print_rline,
  catalog = open_catalog,
  setup = setup,
}
