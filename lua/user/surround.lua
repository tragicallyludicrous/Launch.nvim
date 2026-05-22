local M = {
  "kylechui/nvim-surround",
  version = "*",  -- use latest stable release
  event = "VeryLazy",
}

function M.config()
  require("nvim-surround").setup({
    -- defaults are sensible; customize keymaps here if you want
  })
end

return M
