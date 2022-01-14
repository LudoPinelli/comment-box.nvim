package.loaded["comment-box"] = nil
package.loaded["dev"] = nil

vim.keymap.set("n", ",r", "<Cmd>luafile dev/init.lua<CR>", {})
cbox = require("comment-box")
vim.keymap.set("n", ",b", "<Cmd>lua cbox.lbox()<CR>", {})
vim.keymap.set("v", ",c", "<Cmd>lua cbox.cbox()<CR>", {})
