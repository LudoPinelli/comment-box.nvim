--          ╭─────────────────────────────────────────────────────────╮
--          │                          UTILS                          │
--          ╰─────────────────────────────────────────────────────────╯

local cs = require("comment-box.commentstrings")
local fn = vim.fn

-- return comment strings
---@return string, string, string
local function get_comment_string(filetype)
  local comment_string = cs.get_comment_strings(filetype)

  local comment_string_l, comment_string_b_start, comment_string_b_end =
    "", "", ""

  if comment_string and comment_string[1] and comment_string[1] ~= "" then
    comment_string_l = comment_string[1]:match("^(.-)%%s")
  end

  if comment_string and comment_string[2] and comment_string[2] ~= "" then
    comment_string_b_start = comment_string[2]:match("^(.-)%%s")
    comment_string_b_end = comment_string[2]:match("%%s(.*)$")
  end

  return comment_string_l, comment_string_b_start, comment_string_b_end
end

-- Store the range of the selected text in 'line_start_pos'/'line_end_pos'
---@param lstart number
---@param lend number
---@return number, number
local function get_range(lstart, lend)
  local mode = vim.api.nvim_get_mode().mode
  local line_start_pos, line_end_pos

  if lstart and lend and lend ~= lstart then
    line_start_pos = lstart
    line_end_pos = lend
  else
    if mode:match("[vV]") then
      line_start_pos = fn.line("v")
      line_end_pos = fn.line(".")
      if line_start_pos > line_end_pos then -- if backward selected
        line_start_pos, line_end_pos = line_end_pos, line_start_pos
      end
    else -- if not in visual mode, return the current line
      line_start_pos = fn.line(".")
      line_end_pos = line_start_pos
    end
  end
  ---@diagnostic disable-next-line: return-type-mismatch
  return line_start_pos, line_end_pos
end

-- See if a piece of text contains a url
---@param text string
---@return number|nil, number|nil
local function is_url(text)
  return vim.regex("\\v(https?|ftp|file|ssh|git|mailto)://\\S+"):match_str(text)
end

-- Compute padding
---@param line string
---@param centered_text boolean
---@param right_aligned_text boolean
---@param final_width number
---@return number, number
local function get_pad(line, centered_text, right_aligned_text, final_width)
  local start_pad = 0
  local end_pad = 0
  if centered_text then
    start_pad = math.floor((final_width - fn.strdisplaywidth(line)) / 2)
    end_pad = final_width - (start_pad + fn.strdisplaywidth(line))
  elseif right_aligned_text then
    start_pad = final_width - fn.strdisplaywidth(line) - 1
    end_pad = final_width - (start_pad + fn.strdisplaywidth(line))
  else
    end_pad = final_width - (start_pad + fn.strdisplaywidth(line))
  end
  return start_pad, end_pad
end

local function remove_cs(comment_string, line, start)
  if comment_string ~= "" then
    local comment_string_length = fn.strdisplaywidth(comment_string)
    if start then
      if line:sub(1, comment_string_length) == comment_string then
        line = line:gsub(vim.pesc(comment_string), "", 1) -- remove comment string
      end
    else
      local line_length = fn.strdisplaywidth(line)
      if
        line:sub(line_length - comment_string_length + 1) == comment_string
      then
        line = line:gsub(vim.pesc(comment_string) .. "%s*$", "")
      end
    end
  end
  return line
end

-- Skip comment string if there is one at the beginning of the line
---@param line string
---@return string
local function skip_cs(
  line,
  comment_string_l,
  comment_string_b_start,
  comment_string_b_end
)
  line = vim.trim(line)
  line = remove_cs(comment_string_l, line, true)
  line = remove_cs(comment_string_b_start, line, true)
  line = remove_cs(comment_string_b_end, line, false)

  return vim.trim(line)
end

-- Wrap lines too long to fit in box
---@param text string
---@param final_width number
---@return string[]
local function wrap(text, final_width)
  local str_tab = {}
  local str = text:sub(1, final_width - 2)
  local rstr = str:reverse()
  local f = rstr:find(" ")
  local url_start, _ = is_url(text)

  if f and (not url_start or f < url_start) then
    f = final_width - 2 - f
    table.insert(str_tab, string.sub(text, 1, f))
    table.insert(str_tab, string.sub(text, f + 1))
  else
    table.insert(str_tab, text)
  end
  return str_tab
end

-- ── Returns ───────────────────────────────────────────────────────────

return {
  get_comment_string = get_comment_string,
  get_range = get_range,
  is_url = is_url,
  get_pad = get_pad,
  skip_cs = skip_cs,
  wrap = wrap,
}
