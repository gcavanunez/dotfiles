return {
  'michaelrommel/nvim-silicon',
  lazy = true,
  cmd = 'Silicon',
  main = 'nvim-silicon',
  opts = {
    theme = 'Nord',
    line_pad = 2,
    no_line_number = true,
    background = '#989898',
    -- the paddings to either side
    pad_horiz = 40,
    pad_vert = 40,

    to_clipboard = true,
    -- with which language the syntax highlighting shall be done, should be
    -- a function that returns either a language name or an extension like "js"
    -- it is set to nil, so you can override it, if you do not set it, we try the
    -- filetype first, and if that fails, the extension
    -- language = nil
    language = function()
      vim.notify('Silicon: ' .. vim.bo.filetype)
      if vim.bo.filetype == 'php' then
        return 'PHP Source'
      end
      return vim.bo.filetype
    end,
    -- language = function()
    -- 	return vim.fn.fnamemodify(
    -- 		vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf()),
    -- 		":e"
    -- 	)
    -- end,
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
