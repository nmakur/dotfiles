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

  -- Insert trailing space in /* */ comments
  api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp", "go", "rust", "systemverilog" },
    callback = function()
      opt.comments = "s1:/*,mf:* ,ex:*/"
    end,
  })

  -- Auto-compile on save for latex
  api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.tex",
    callback = function()
      vim.cmd('silent! execute "!texcc % >/dev/null"')
      vim.cmd("redraw!")
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
    hi Identifier ctermfg=7
    hi Function ctermfg=177
    hi Constant ctermfg=168
  ]])

  -- C Customization
  api.nvim_set_hl(0, "@type.builtin.c", { link = "Type" })

  -- C++ Customization
  api.nvim_set_hl(0, "@constructor.cpp", { link = "Function" })
  api.nvim_set_hl(0, "@type.builtin.cpp", { link = "Type" })
  api.nvim_set_hl(0, "@keyword.modifier.cpp", { link = "Structure" })
  api.nvim_set_hl(0, "@module.cpp", { link = "Structure" })

  -- SystemVerilog Customization
  api.nvim_set_hl(0, "@type.builtin.verilog", { link = "Type" })
  api.nvim_set_hl(0, "@constructor.verilog", { link = "Function" })
  api.nvim_set_hl(0, "@function.builtin.verilog", { link = "PreProc" })

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
