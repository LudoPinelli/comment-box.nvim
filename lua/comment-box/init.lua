local width = 80
local hor_symbol = "─"
local vert_symbol = "│"
local top_left_symbol = "╭"
local top_right_symbol = "╮"
local bottom_left_symbol = "╰"
local bottom_right_symbol = "╯"
local centered = true
local outer_blank_lines = true
local inner_blank_lines = true

local function get_pad(line)
	local pad = (width - string.len(line) - 2) / 2
	local odd
	if string.len(line) % 2 == 0 then
		odd = false
	else
		odd = true
	end
	return pad, odd
end

local function get_range()
	local line_start_pos, line_end_pos
	local mode = vim.api.nvim_get_mode()["mode"]
	if mode:match("[vV]") then
		line_start_pos = vim.fn.line("v")
		line_end_pos = vim.fn.line(".")
	else
		line_start_pos = vim.fn.line(".")
		line_end_pos = line_start_pos
	end

	return line_start_pos, line_end_pos
end

local function get_text()
	local line_start_pos, line_end_pos = get_range()
	return vim.api.nvim_buf_get_lines(0, line_start_pos - 1, line_end_pos, false)
end

local function create_box()
	local comment_string = vim.api.nvim_buf_get_option(0, "commentstring")
	comment_string = comment_string:match("^(.*)%%s(.*)")
	local ext_top_row = comment_string
		.. " "
		.. top_left_symbol
		.. string.rep(hor_symbol, width - 2)
		.. top_right_symbol
	local ext_bottom_row = comment_string
		.. " "
		.. bottom_left_symbol
		.. string.rep(hor_symbol, width - 2)
		.. bottom_right_symbol
	local inner_blank_line = comment_string .. " " .. vert_symbol .. string.rep(" ", width - 2) .. vert_symbol
	local int_row = ""
	local lines = {}
	local text = get_text()

	print(vim.inspect(text))
	if text == { "" } then
		return
	end

	if outer_blank_lines then
		table.insert(lines, "")
	end
	table.insert(lines, ext_top_row)
	if inner_blank_lines then
		table.insert(lines, inner_blank_line)
	end
	if centered then
		for _, line in pairs(text) do
			line = line:gsub(vim.pesc(comment_string), "", 1)
			local pad, odd = get_pad(line)
			local parity_pad
			if odd then
				parity_pad = pad + 1
			else
				parity_pad = pad
			end
			int_row = comment_string
				.. " "
				.. vert_symbol
				.. string.rep(" ", parity_pad)
				.. line
				.. string.rep(" ", pad)
				.. vert_symbol
			table.insert(lines, int_row)
		end
	else
		for _, line in pairs(text) do
			local pad = width - string.len(line) - 3
			line = line:gsub(vim.pesc(comment_string), "", 1)
			int_row = comment_string .. " " .. vert_symbol .. line .. string.rep(" ", pad) .. vert_symbol
			table.insert(lines, int_row)
		end
	end

	if inner_blank_lines then
		table.insert(lines, inner_blank_line)
	end
	table.insert(lines, ext_bottom_row)
	if outer_blank_lines then
		table.insert(lines, "")
	end

	return lines
end

function print_box()
	local line_start_pos, line_end_pos = get_range()
	vim.api.nvim_buf_set_lines(0, line_start_pos - 1, line_end_pos, false, create_box())
end

return {
	print_box = print_box,
}
