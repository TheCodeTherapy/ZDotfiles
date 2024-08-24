return {
  "zaldih/themery.nvim",
  config = function()
    require("themery").setup({
      themes = { "tokyonight", "habamax", "catppuccin", "bamboo", "cyberdream", "rose-pine", "sonokai" },
      livePreview = true,
    })
  end,
}
