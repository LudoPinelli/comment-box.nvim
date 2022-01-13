package.loaded["comment-box"] = nil
package.loaded["dev"] = nil

vim.keymap.set("n", ",r", "<Cmd>luafile dev/init.lua<CR>", {})
cbox = require("comment-box")
vim.keymap.set("n", ",t", "<Cmd>lua cbox.print_box()<CR>", {})
vim.keymap.set("v", ",t", "<Cmd>lua cbox.print_box()<CR>", {})
