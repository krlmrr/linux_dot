return {
  'airblade/vim-rooter',
  event = 'BufReadPost',
  config = function()
    vim.g.rooter_patterns = { '.git', 'composer.json', 'package.json', 'Makefile' }
    vim.g.rooter_silent_chdir = 1
    vim.g.rooter_manual_only = 0
  end,
}
