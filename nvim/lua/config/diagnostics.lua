-- Disable default real-time diagnostics
vim.diagnostic.config({
  virtual_text = false,
  signs = false,
  underline = false,
})

-- Handle standard LSP rendering on save (C, Rust, Go, LaTeX, SystemVerilog)
local diagnostic_group = vim.api.nvim_create_augroup("OnSaveDiagnostics", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
  group = diagnostic_group,
  callback = function()
    vim.diagnostic.config({
      virtual_text = true,
      signs = true,
      underline = true,
    })
  end,
})

-- Severity filter: Intercept and drop SystemVerilog warnings
local native_publish_handler = vim.lsp.handlers["textDocument/publishDiagnostics"]
vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
  local bufnr = vim.uri_to_bufnr(result.uri)
  if vim.api.nvim_buf_is_valid(bufnr) then
    local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
    if filetype == "verilog" or filetype == "systemverilog" then
      local filtered_diagnostics = {}
      for _, diagnostic in ipairs(result.diagnostics) do
        if diagnostic.severity == 1 then -- 1 is Error
          table.insert(filtered_diagnostics, diagnostic)
        end
      end
      result.diagnostics = filtered_diagnostics
    end
  end
  native_publish_handler(err, result, ctx, config)
end

-- :C Command -> Hide highlights and shut the bottom error panel
vim.api.nvim_create_user_command("C", function()
  -- 1. Hide on-screen code markings
  vim.diagnostic.config({
    virtual_text = false,
    signs = false,
    underline = false,
  })
  -- 2. Close the bottom location list window layout
  vim.cmd("lclose")
end, { desc = "Hide error highlights and close the bottom diagnostic panel" })

-- :E Command -> Open all current file errors in a bottom list panel
vim.api.nvim_create_user_command("E", function()
  -- 1. Silently send the buffer diagnostics directly into the location list data structure
  vim.diagnostic.setloclist({ open = false, title = "Buffer Errors" })

  -- 2. Check if the list contains errors before opening it
  local loc_list = vim.fn.getloclist(0)
  if #loc_list > 0 then
    -- Open the location list at the bottom of the screen with a fixed height of 8 lines
    vim.cmd("botright lopen 8")
  else
    print("No errors found in the current buffer!")
  end
end, { desc = "Show all buffer errors in a bottom panel layout" })


-- Remove the background color from the selected line in the panel
vim.api.nvim_set_hl(0, "QuickFixLine", { bg = "NONE", ctermbg = "NONE" })

local hl_fix_group = vim.api.nvim_create_augroup("FixQuickFixHighlight", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  group = hl_fix_group,
  callback = function()
    vim.api.nvim_set_hl(0, "QuickFixLine", { bg = "NONE", ctermbg = "NONE" })
  end,
})
