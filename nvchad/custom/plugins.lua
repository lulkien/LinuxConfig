return {
  {
    "nvimtools/none-ls.nvim",
    event = "VeryLazy",
    opts = function()
      return require "custom.configs.none-ls"
    end,
  },
  -- {
  --   "williamboman/mason.nvim",
  --   config = function()
  --     require("mason").setup {
  --       ui = {
  --         icons = {
  --           package_installed = "✓",
  --           package_pending = "➜",
  --           package_uninstalled = "✗",
  --         },
  --       },
  --     }
  --   end,
  -- },
  -- {
  --   "williamboman/mason-lspconfig.nvim",
  --   config = function()
  --     require("mason-lspconfig").setup {
  --       ensure_installed = {
  --         "bashls",
  --         "clangd",
  --         "cmake",
  --         "cssls",
  --         "jsonls",
  --         "tsserver",
  --         "lua_ls",
  --         "pyright",
  --         "rust_analyzer",
  --         "slint_lsp",
  --       },
  --     }
  --   end,
  -- },
  {
    "williamboman/mason.nvim",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
      ensure_installed = {
        "lua-language-server",
        "bash-language-server",
        "cmake-language-server",
        "pyright",
        "rust-analyzer",
        "slint-lsp",
        "css-lsp",
        "json-lsp",
        "clangd",
        "clang-format",
        "typescript-language-server",
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "plugins.configs.lspconfig"
      require "custom.configs.lspconfig"
    end,
  },
  {
    "rust-lang/rust.vim",
    ft = "rust",
    init = function()
      vim.g.rustfmt_autosave = 1
    end,
  },
  {
    "simrat39/rust-tools.nvim",
    ft = "rust",
    dependencies = "neovim/nvim-lspconfig",
    opts = function()
      return require "custom.configs.rust"
    end,
    config = function(_, opts)
      require("rust-tools").setup(opts)
    end,
  },
  -- {
  --     "mfussenegger/nvim-dap", -- For debugging
  -- },
  {
    "saecki/crates.nvim",
    ft = { "rust", "toml" },
    config = function(_, opts)
      local crates = require "crates"
      crates.setup(opts)
      crates.show()
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    opts = function()
      local M = require "plugins.configs.cmp"
      table.insert(M.sources, { name = "crates" })
      return M
    end,
  },
}
