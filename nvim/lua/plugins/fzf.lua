return {
  {
    "junegunn/fzf.vim",
    dependencies = { "junegunn/fzf" },
    config = function()
      vim.g.fzf_buffers_jump = 1
      vim.g.fzf_layout = { window = { width = 1.0, height = 0.2, yoffset = 1.0, border = "top" } }
    end,
  }
}
