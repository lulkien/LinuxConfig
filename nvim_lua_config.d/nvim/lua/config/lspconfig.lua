local capabilities = require('cmp_nvim_lsp').default_capabilities()
local _lspconfig = require('lspconfig')

_lspconfig.qmlls.setup {
    cmd = { "qmlls6" },
    filetypes = { "qml" },
    single_file_support = true,
    capabilities = capabilities,
}
