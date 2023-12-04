local base = require("plugins.configs.lspconfig")
local on_attach = base.on_attach
local capabilities = base.capabilities
local lspconfig = require("lspconfig")

-- Table of LSP servers
local servers = { "pylsp" }

-- Default configs for lsp
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup {
        on_attach = on_attach,
        capabilities = capabilities,
    }
end

-- Config for clangd --
lspconfig.clangd.setup {
    on_attach = function (client, bufnr)
        client.server_capabilities.signatureHelpProvider = false
        on_attach(client, bufnr)
    end,
    capabilities = capabilities,
}


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
