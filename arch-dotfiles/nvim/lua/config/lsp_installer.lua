local installer = require('nvim-lsp-installer')
installer.setup {}

local on_attach = function(client, bufnr)
  local function buf_set_keymap(mode, key, action)
    vim.api.nvim_buf_set_keymap(bufnr, mode, key, action, { noremap = true, silent = true })
  end

  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end

  -- Set option
  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Set some keymaps
  buf_set_keymap("n", "gd",           ":lua vim.lsp.buf.definition()<CR>"            ) --> jumps to the definition of the symbol under the cursor
  buf_set_keymap("n", "gD",           ":lua vim.lsp.buf.declaration()<CR>"           ) --> jumps to the definition of the symbol under the cursor
  buf_set_keymap("n", "<leader>lh",   ":lua vim.lsp.buf.hover()<CR>"                 ) --> information about the symbol under the cursos in a floating window
  buf_set_keymap("n", "<leader>rn",   ":lua vim.lsp.buf.rename()<CR>"                ) --> renaname old_fname to new_fname
  buf_set_keymap("n", "<leader>ca",   ":lua vim.lsp.buf.code_action()<CR>"           ) --> selects a code action available at the current cursor position
  buf_set_keymap("n", "gr",           ":lua vim.lsp.buf.references()<CR>"            ) --> lists all the references to the symbl under the cursor in the quickfix window
  buf_set_keymap("n", "<leader>fm",   ":lua vim.lsp.buf.format { async = true }<CR>" ) --> formats the current buffer
end

local servers = { 'clangd', 'sumneko_lua', 'pyright' }

for _, name in pairs(servers) do
  local server_is_found, server = installer.get_server(name)
  if server_is_found then
    if not server:is_installed() then
      print("Installing " .. name)
      server:install()
    end
  end
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require('lspconfig')
for _, server in pairs(servers) do
  if server == 'sumneko_lua' then
    lspconfig.sumneko_lua.setup {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' },
          }
        }
      }
    }
  else
    lspconfig[server].setup {
      on_attach = on_attach,
      capabilities = capabilities,
    }
  end
end
