local on_attach = require("plugins.configs.lspconfig").on_attach
local capabilities = require("plugins.configs.lspconfig").capabilities
local lspconfig = require("lspconfig")
local util = require("lspconfig/util")

-- Table of LSP servers
local servers = { "pylsp" }

-- Default configs for lsp
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

-- Manual additional configs
-- Example:
-- lspconfig.rust_analyzer.setup({
--     filetypes = { "rust" },
--     root_dir = util.root_pattern("Cargo.toml"),
--     settings = {
--         ['rust-analyzer'] = {
--             cmd = { "rust-analyzer" },
--             cargo = {
--                 allFeatures = true;
--             },
--             diagnostics = {
--                 enable = false;
--             },
--         }
--     }
-- })
-- It's just an example, DO NOT uncomment the code
