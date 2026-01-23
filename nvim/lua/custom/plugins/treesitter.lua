return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
      require('nvim-treesitter').setup({
        ensure_installed = {
          'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'javascript', 'typescript',
          'vimdoc', 'vim', 'bash', 'php', 'html', 'css', 'json', 'yaml', 'markdown',
          'regex', 'vue'
        },
      })
    end,
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    branch = 'main',
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    config = function()
      local ts_textobjects = require('nvim-treesitter-textobjects')
      ts_textobjects.setup({
        select = { lookahead = true },
      })

      local select = require('nvim-treesitter-textobjects.select')
      local move = require('nvim-treesitter-textobjects.move')
      local swap = require('nvim-treesitter-textobjects.swap')

      -- Select keymaps
      vim.keymap.set({ 'x', 'o' }, 'aa', function() select.select_textobject('@parameter.outer', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'ia', function() select.select_textobject('@parameter.inner', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'af', function() select.select_textobject('@function.outer', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'if', function() select.select_textobject('@function.inner', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'ac', function() select.select_textobject('@class.outer', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'ic', function() select.select_textobject('@class.inner', 'textobjects') end)

      -- Move keymaps
      vim.keymap.set({ 'n', 'x', 'o' }, ']m', function() move.goto_next_start('@function.outer', 'textobjects') end)
      vim.keymap.set({ 'n', 'x', 'o' }, ']]', function() move.goto_next_start('@class.outer', 'textobjects') end)
      vim.keymap.set({ 'n', 'x', 'o' }, ']M', function() move.goto_next_end('@function.outer', 'textobjects') end)
      vim.keymap.set({ 'n', 'x', 'o' }, '][', function() move.goto_next_end('@class.outer', 'textobjects') end)
      vim.keymap.set({ 'n', 'x', 'o' }, '[m', function() move.goto_previous_start('@function.outer', 'textobjects') end)
      vim.keymap.set({ 'n', 'x', 'o' }, '[[', function() move.goto_previous_start('@class.outer', 'textobjects') end)
      vim.keymap.set({ 'n', 'x', 'o' }, '[M', function() move.goto_previous_end('@function.outer', 'textobjects') end)
      vim.keymap.set({ 'n', 'x', 'o' }, '[]', function() move.goto_previous_end('@class.outer', 'textobjects') end)

      -- Swap keymaps
      vim.keymap.set('n', '<leader>a', function() swap.swap_next('@parameter.inner', 'textobjects') end)
      vim.keymap.set('n', '<leader>A', function() swap.swap_previous('@parameter.inner', 'textobjects') end)
    end,
  },
}
