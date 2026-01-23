return {
  "EmranMR/tree-sitter-blade",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    -- Set up blade filetype detection
    vim.filetype.add({
      pattern = {
        [".*%.blade%.php"] = "blade",
      },
    })

    -- Enable treesitter for blade files
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "blade",
      callback = function()
        pcall(vim.treesitter.start)
      end,
    })
  end,
}
