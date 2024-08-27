return {
  "folke/noice.nvim",
  opts = {
    presets = {
      lsp_doc_border = true,
    },
    lsp = {
      hover = {
        enabled = true,
        silent = false,
      },
      signature = {
        opts = {
          size = {
            height = 10,
          },
        },
      },
    },
  },
}
