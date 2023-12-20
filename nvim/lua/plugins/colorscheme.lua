return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = false,
      styles = {
        -- sidebars = "transparent",
        -- floats = "transparent",
      },
      config = function()
        vim.cmd("highlight Normal guibg=#1b1d2b")
      end
    },
  },
}
