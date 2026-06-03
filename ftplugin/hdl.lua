-- NAND2Tetris HDL buffer-local settings.
-- commentstring/comments let Comment.nvim and gc-mappings work with //.
vim.bo.commentstring = "// %s"
vim.bo.comments = "s1:/*,mb:*,ex:*/,://"

-- Treat dotted bus ranges (a[0..7]) sensibly for word motions.
vim.opt_local.matchpairs:append "{:}"
