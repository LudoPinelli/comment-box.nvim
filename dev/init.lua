package.loaded["comment-box"] = nil
package.loaded["dev"] = nil

vim.keymap.set("n", ",r", "<Cmd>luafile dev/init.lua<CR>", {})
vim.keymap.set({ "n", "v" }, "<Leader>bb", "<Cmd>lua require('comment-box').lbox()<CR>", {})
vim.keymap.set({ "n", "v" }, "<Leader>bc", "<Cmd>lua require('comment-box').cbox()<CR>", {})
vim.keymap.set("n", "<Leader>bl", "<Cmd>lua require('comment-box').line()<CR>", {})
