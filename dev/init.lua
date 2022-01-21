package.loaded["comment-box"] = nil
package.loaded["dev"] = nil
package.loaded["comment-box.catalog"] = nil

vim.keymap.set("n", ",r", "<Cmd>luafile dev/init.lua<CR>", {})
vim.keymap.set({ "n", "v" }, "<Leader>bb", "<Cmd>lua require('comment-box').lbox(20)<CR>", {})
vim.keymap.set({ "n", "v" }, "<Leader>bc", "<Cmd>lua require('comment-box').cbox(13)<CR>", {})
vim.keymap.set("n", "<Leader>bl", "<Cmd>lua require('comment-box').line(9)<CR>", {})
