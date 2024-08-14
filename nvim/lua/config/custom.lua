local capabilities = require("cmp_nvim_lsp").default_capabilities()

local servers = {
  "emmet_ls",
  "clangd",
  "jdtls",
  "gopls",
  "jsonls",
  "html",
  "tsserver",
  "rust_analyzer",
  "cmake",
  "bashls",
  "lua_ls",
}

local border = {
  { "┌", "FloatBorder" },
  { "─", "FloatBorder" },
  { "┐", "FloatBorder" },
  { "│", "FloatBorder" },
  { "┘", "FloatBorder" },
  { "─", "FloatBorder" },
  { "└", "FloatBorder" },
  { "│", "FloatBorder" },
}

local handler = {
  ["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = border }),
  ["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = border }),
}

local lspconfig = require("lspconfig")
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup({
    handlers = handler,
    border = border,
    capabilities = capabilities,
    on_attach = function(client, bufnr)
      if client.server_capabilities["documentSymbolProvider"] then
        require("nvim-navic").attach(client, bufnr)
      end
    end,
  })
end
