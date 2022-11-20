local status_ok, _= pcall(require, 'lspconfig')
if not status_ok then
    return
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()

local _lspconfig = require'lspconfig'
_lspconfig.qmlls.setup {
    cmd = { "qmlls6" },
    filetypes = { "qml" },
    single_file_support = true,
    capabilities = capabilities
}

_lspconfig.sumneko_lua.setup {
  settings = {
    Lua = {
      diagnostics = {
        globals = {'vim'},
      },
    },
  },
}
