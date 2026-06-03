-- NAND2Tetris HDL detection.
-- Neovim's builtin filetype map sends *.hdl to "vhdl"; the NAND2Tetris course
-- uses its own educational HDL that only shares the extension. Override it.
-- (User vim.filetype.add() entries take precedence over the builtin mapping.)
vim.filetype.add {
  extension = {
    hdl = "hdl",
  },
}
