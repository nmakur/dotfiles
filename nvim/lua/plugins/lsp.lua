return {
  -- 1. Installs binaries and manages language servers
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },

  -- 2. Bridges mason tool paths with lspconfig automatic hooks
  {
    "williamboman/mason-lspconfig.nvim",
    -- CRITICAL NVIM 0.10 FIX: Pins the bridge plugin to version 1 to stop the 0.11 crash
    version = "v1.*",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "rust_analyzer", "svls", "gopls" , "texlab" , "millet" }
      })
    end,
  },

  -- 3. Configuration engine locked to Neovim 0.10 supported release
  {
    "neovim/nvim-lspconfig",
    -- CRITICAL NVIM 0.10 FIX: Pins lspconfig to the v1.x branch targeting Nvim 0.10 stability
    version = "v1.*",
    dependencies = { "williamboman/mason-lspconfig.nvim" },
    config = function()
      local lspconfig = require("lspconfig")

      -- Connect configurations for each language server using classic 0.10 setup
      lspconfig.clangd.setup({})         -- C / C++
      lspconfig.rust_analyzer.setup({})  -- Rust
      lspconfig.svls.setup({})           -- SystemVerilog
      lspconfig.gopls.setup({
  settings = {
    gopls = {
      -- Enables gopls to send semantic tokens to Neovim
      semanticTokens = true,
    },
  },
})
      lspconfig.texlab.setup({})
      lspconfig.millet.setup({})

    end,
  }
}
