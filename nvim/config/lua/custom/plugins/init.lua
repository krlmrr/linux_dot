-- Custom plugins
return {
  -- AI inline autocomplete
  {
    'supermaven-inc/supermaven-nvim',
    config = function()
      require('supermaven-nvim').setup({
        keymaps = {
          accept_suggestion = '<Tab>',
          clear_suggestion = '<C-]>',
          accept_word = '<C-j>',
        },
        color = {
          suggestion_color = '#5c6370',
        },
      })
    end,
  },
  -- Floating command line and notifications
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    },
    opts = {
      cmdline = {
        enabled = true,
        view = 'cmdline_popup',
        format = {
          cmdline = { pattern = '^:', icon = '>', lang = '' },
          search_down = { pattern = '^/', icon = '/', lang = '' },
          search_up = { pattern = '^%?', icon = '?', lang = '' },
          filter = { pattern = '^:%s*!', icon = '$', lang = '' },
          lua = { pattern = '^:%s*lua%s+', icon = '>', lang = '' },
          help = { pattern = '^:%s*he?l?p?%s+', icon = '?', lang = '' },
        },
      },
      messages = {
        enabled = true,
        view = 'mini',
      },
      popupmenu = {
        enabled = true,
      },
      -- Required for cmdheight=0
      routes = {
        {
          filter = { event = 'msg_show', kind = '' },
          opts = { skip = true },
        },
      },
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },
      presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
    config = function(_, opts)
      require('noice').setup(opts)
      -- Custom noice highlights (blue borders, white text)
      vim.api.nvim_set_hl(0, 'NoiceCmdlinePopupBorder', { fg = '#61afef' })
      vim.api.nvim_set_hl(0, 'NoiceCmdlineIcon', { fg = '#abb2bf' })
      vim.api.nvim_set_hl(0, 'NoicePopupmenuBorder', { fg = '#61afef' })
      vim.api.nvim_set_hl(0, 'NoiceCmdlinePopupTitle', { fg = '#61afef' })
      -- Fix purple command line text
      vim.api.nvim_set_hl(0, 'NoiceCmdline', { fg = '#abb2bf' })
      vim.api.nvim_set_hl(0, 'NoiceVirtualText', { fg = '#abb2bf' })
    end,
  },

  -- File tree sidebar (on the right)
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    keys = {
      { '<leader>e', '<cmd>Neotree toggle right reveal<cr>', desc = 'Toggle File Tree' },
    },
    opts = {
      close_if_last_window = true,
      source_selector = {
        winbar = false,
        statusline = false,
        show_scrolled_off_parent_node = false,
      },
      default_component_configs = {
        indent = {
          with_expanders = false,
        },
      },
      window = {
        position = 'right',
        width = 35,
        mappings = {},
      },
      event_handlers = {
        {
          event = "neo_tree_buffer_enter",
          handler = function()
            vim.opt_local.statusline = " "
          end,
        },
      },
      filesystem = {
        follow_current_file = {
          enabled = true,
        },
        use_libuv_file_watcher = true,
      },
      enable_git_status = false,
      enable_diagnostics = false,
    },
  },
}
