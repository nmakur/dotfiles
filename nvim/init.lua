-- ~/.config/nvim/init.lua

local opt = vim.opt
local g = vim.g
local keymap = vim.keymap.set
local api = vim.api

----------------------------------------------------------------------------
-- QoL Improvements
----------------------------------------------------------------------------

  -- Enable mouse
  opt.mouse = "a"

  -- Easily view text
  opt.wrap = true
  opt.linebreak = true

  -- Easily switch between & update buffers
  opt.hidden = true
  opt.autoread = true

  -- Undo across sessions
  opt.undofile = true
  opt.undodir = vim.fn.expand("~/.local/nvimundo")

  -- Allow typos
  api.nvim_create_user_command("W", "w", {})
  api.nvim_create_user_command("Q", "q", {})
  api.nvim_create_user_command("Wq", "wq", {})
  keymap("n", "q:", "<Nop>")

  -- Return to last edit position when opening files
  api.nvim_create_autocmd("BufReadPost", {
    pattern = "*",
    callback = function()
      local mark_line = vim.fn.line("'\"")
      if mark_line > 1 and mark_line <= vim.fn.line("$") then
        vim.cmd('normal! g`"')
      end
    end,
  })

  -- System clipboard integration (wl-copy)
  keymap("x", "+y", '"0y:call system(\'wl-copy\', @0)<CR>', { silent = false })

  -- Use bash aliases from within vim
  vim.env.BASH_ENV = "~/.config/bash/bash_aliases"

  -- Use space as the leader
  g.mapleader = " "
  g.maplocalleader = " "

  -- Undo across sessions
  opt.shadafile = vim.fn.expand("~/.config/nvim/nviminfo")

----------------------------------------------------------------------------
-- Source Plugins (Lazy)
----------------------------------------------------------------------------

  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not (vim.uv or vim.loop).fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
    })
  end
  opt.rtp:prepend(lazypath)

  require("lazy").setup({
    spec = {
      { import = "plugins" },
    },
  })

  require("config.diagnostics")

vim.api.nvim_create_autocmd('User', { pattern = 'TSUpdate',
callback = function()
  require('nvim-treesitter.parsers').sml = {
    install_info = {
      url = 'https://github.com/MatthewFluet/tree-sitter-sml/tree/main'
    },
  }
end})

local parser_config = require("nvim-treesitter.parsers").get_parser_configs()

parser_config.sml = {
  install_info = {
    url = "https://github.com/MatthewFluet/tree-sitter-sml", -- The official community parser
    files = { "src/parser.c" },
    location = "tree-sitter-sml",
    -- If the repository lacks pre-generated queries, it might need to compile from scratch
    generate = true,
    branch = "main",
  },
  filetype = "sml",
}


----------------------------------------------------------------------------
-- Navigation
----------------------------------------------------------------------------

  -- Line numbers
  opt.number = true
  opt.relativenumber = true

  -- Search
  opt.incsearch = true
  opt.hlsearch = true
  opt.ignorecase = true
  opt.smartcase = true
  opt.scrolloff = 1


  -- Jump between splits
  keymap("n", "<Leader>h", "<C-w>h")
  keymap("n", "<Leader>j", "<C-w>j")
  keymap("n", "<Leader>k", "<C-w>k")
  keymap("n", "<Leader>l", "<C-w>l")

  -- Visual Line Navigation
  keymap("n", "J", "gj")
  keymap("n", "K", "gk")
  keymap("n", "<C-j>", "J")

  -- FZF
  keymap('n', '<leader>f', ":call fzf#vim#files(v:null, {}, 0)<CR>", { silent = true })

  -- Nice buffer navigation for gaps introduced by fzf
  local function jump_to_active_nth(count)
    local buffers = vim.tbl_filter(function(b)
      return vim.fn.buflisted(b) == 1
    end, vim.fn.range(1, vim.fn.bufnr("$")))

    if count > 0 and count <= #buffers then
      vim.cmd("buffer " .. buffers[count])
    else
      print("Buffer does not exist")
    end
  end

  api.nvim_create_user_command("B", function(opts)
    jump_to_active_nth(tonumber(opts.args))
  end, { nargs = 1 })

  keymap("n", "<leader>b", function()
    jump_to_active_nth(vim.v.count)
  end, { silent = true })

----------------------------------------------------------------------------
-- Code Editing
----------------------------------------------------------------------------

  -- Tabs
  opt.expandtab = true
  opt.tabstop = 2
  opt.shiftwidth = 2
  opt.softtabstop = 2
  opt.autoindent = true
  opt.backspace = { "indent", "eol", "start" }

  -- Auto-extend comments
  api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
      opt.formatoptions:append("r")
      opt.formatoptions:append("o")
    end,
  })

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.tex",
  callback = function()
    local file = vim.fn.expand("%")
    local cmd = string.format("latexmk -pdf %s && latexmk -c %s", file, file)
    vim.fn.jobstart({ "sh", "-c", cmd })
  end,
})

----------------------------------------------------------------------------
-- Theme
----------------------------------------------------------------------------

  -- Highlight code
  vim.cmd("syntax on")

  -- Grab default theme
  opt.termguicolors = false
  opt.background = "dark"
  vim.cmd("colorscheme wildcharm")

  -- Tweaks
  vim.cmd([[
    hi Statement ctermfg=218
    hi Type ctermfg=75
    hi StorageClass ctermfg=4
    hi Structure ctermfg=4
    hi Function ctermfg=177
    hi Constant ctermfg=168
    hi Identifier ctermfg=252
    hi Title ctermfg=75
  ]])


vim.api.nvim_set_hl(0, 'StatusLine', { ctermbg = 22, ctermfg = 7 })
vim.api.nvim_set_hl(0, 'StatusLineNC', { ctermbg = 0, ctermfg = 7 })

  -- C Customization
  api.nvim_set_hl(0, "@type.builtin.c", { link = "Type" })

  -- C++ Customization
  api.nvim_set_hl(0, "@constructor.cpp", { link = "Function" })
  api.nvim_set_hl(0, "@type.builtin.cpp", { link = "Type" })
  api.nvim_set_hl(0, "@lsp.type.class.cpp", { link = "Type" })
  api.nvim_set_hl(0, "@keyword.modifier.cpp", { link = "Structure" })
  api.nvim_set_hl(0, "@module.cpp", { link = "Structure" })

  -- SystemVerilog Customization
  api.nvim_set_hl(0, "@type.builtin.verilog", { link = "Type" })
  api.nvim_set_hl(0, "@constructor.verilog", { link = "Function" })
  api.nvim_set_hl(0, "@function.builtin.verilog", { link = "PreProc" })
  api.nvim_set_hl(0, "@operator.verilog", { link = "Special" })
  api.nvim_set_hl(0, "@keyword.conditional.ternary.verilog", { link = "Special" })
  api.nvim_set_hl(0, "@keyword.modifier.verilog", { link = "Structure" })

  -- GoLang Customization
  vim.highlight.priorities.semantic_tokens = 50
  api.nvim_set_hl(0, "@type.builtin.go", { link = "Type" })
  api.nvim_set_hl(0, "@lsp.mod.readonly.go", { link = "Constant" })
  api.nvim_set_hl(0, "@module.go", { link = "Structure" })


  -- SML Customization
  --api.nvim_set_hl(0, "smlModPath", { link = "Structure" })
  --api.nvim_set_hl(0, "smlKeyChar", { link = "Special" })



  vim.api.nvim_create_autocmd("LspTokenUpdate", {
    callback = function(args)
      -- Only evaluate if the current buffer is a Go file
      if vim.bo[args.buf].filetype ~= "go" then return end

      local token = args.data.token

      -- Check if the semantic token carries the 'readonly' modifier
      if token.modifiers and token.modifiers.readonly then

        -- Force Neovim to highlight this token at priority 110 using your custom group
        vim.lsp.semantic_tokens.highlight_token(
          token,
          args.buf,
          args.data.client_id,
          "@lsp.mod.readonly.go",
          { priority = 110 } -- Overrides Treesitter's 100
        )
      end
    end,
  })

  -- Latex Customization
  api.nvim_create_autocmd("FileType", {
    pattern = "tex",
    callback = function()
      vim.cmd("highlight Statement ctermfg=75")
      vim.cmd("highlight Special ctermfg=75")
    end,
  })

  vim.cmd([[
    hi! texDelimiter ctermfg=99
    hi! texStatement ctermfg=33
    hi! link texSuperScript Special
    hi! link texSubScript Special
  ]])


----------------------------------------------------------------------------
-- Misc
----------------------------------------------------------------------------

  local fzf_group = vim.api.nvim_create_augroup("FzfLockFocus", { clear = true })

  -- When FZF opens, hijack the global left-click mouse button safely
  vim.api.nvim_create_autocmd("FileType", {
    group = fzf_group,
    pattern = "fzf",
    callback = function()
      local fzf_win = vim.api.nvim_get_current_win()
      local fzf_buf = vim.api.nvim_get_current_buf()

      -- Map LeftMouse across normal, insert, visual, and terminal modes
      keymap({"n", "v", "i", "t" }, "<LeftMouse>", function()
        -- Safely defer the window change to avoid E565 error
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(fzf_buf) and vim.api.nvim_win_is_valid(fzf_win) then
            vim.api.nvim_set_current_win(fzf_win)
            vim.cmd("startinsert")
          end
        end)
      end, { silent = true })
    end,
  })

  -- Clear the global override when FZF closes so normal clicking returns
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = fzf_group,
    pattern = "*",
    callback = function()
      if vim.bo.filetype == "fzf" then
        pcall(vim.keymap.del, { "n", "v", "i", "t" }, "<LeftMouse>")
      end
    end,
  })

  -- Clear trailing whitespaces and lines
  vim.api.nvim_create_autocmd("BufWritePre", {
    pattern = "*",
    callback = function()
      -- Save the current cursor position
      local save_cursor = vim.fn.getpos(".")

      -- Remove trailing whitespaces
      vim.cmd([[%s/\s\+$//e]])

      -- Remove trailing blank lines at the end of the file
      vim.cmd([[%s/\n\+\%$//e]])

      -- Restore the cursor position
      vim.fn.setpos(".", save_cursor)
    end,
  })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "go", "sml"},
  callback = function()
    vim.opt_local.expandtab = true
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
    vim.opt_local.softtabstop = 2
  end,
})

vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = "Rename variable" })

-- Map 'gd' to go to definition in Normal mode
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })

-- Open definition in a vertical split
vim.keymap.set('n', 'gD', '<cmd>rightb vsplit | lua vim.lsp.buf.definition()<CR>', { desc = 'Definition in vertical split on the right' })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "latex" },
  callback = function()
    vim.opt_local.indentexpr = ""
    vim.opt_local.autoindent = true
    vim.opt_local.smartindent = false
    vim.opt_local.cindent = false
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})
