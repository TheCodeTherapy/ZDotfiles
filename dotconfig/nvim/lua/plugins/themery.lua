return {
  "zaldih/themery.nvim",
  config = function()
    require("themery").setup({
      themes = { "tokyonight", "catppuccin", "bamboo", "cyberdream", "rose-pine", "sonokai", "mellow", "everforest" },
      livePreview = true,
    })
  end,
}
