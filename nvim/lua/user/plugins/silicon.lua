return {
  'michaelrommel/nvim-silicon',
  lazy = true,
  cmd = 'Silicon',
  main = 'nvim-silicon',
  opts = {
    theme = 'Nord',
    line_pad = 2,
    no_line_number = true,
    to_clipboard = true,
    -- Configuration here, or leave empty to use defaults
    line_offset = function(args)
      return args.line1
    end,
    output = function()
      return '~/_code-screenshots/' .. os.date('!%Y-%m-%dT%H-%M-%SZ') .. '.png'
    end,
  },
  init = function()
    -- local wk = require('which-key')
    -- wk.add({
    --   { '<leader>sc', ':Silicon<CR>', desc = 'Snapshot Code', mode = 'v' },
    -- })
  end,
}
