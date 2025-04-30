-- https://github.com/mg979/vim-visual-multi
return {
  'mg979/vim-visual-multi', -- See https://github.com/mg979/vim-visual-multi/issues/241
  init = function()
    vim.g.VM_default_mappings = 0
    vim.g.VM_maps = {
      ['Find Under'] = '',
      -- ['Find Under'] = '<leader>mf',
    }

    vim.g.VM_theme = 'ocean'
    vim.g.VM_add_cursor_at_pos_no_mappings = 1
  end,
}
-- return {
--   'smoka7/multicursors.nvim',
--   event = 'VeryLazy',
--   dependencies = {
--     'nvimtools/hydra.nvim',
--   },
--   opts = {},
--   cmd = { 'MCstart', 'MCvisual', 'MCclear', 'MCpattern', 'MCvisualPattern', 'MCunderCursor' },
--   keys = {
--     {
--       mode = { 'v', 'n' },
--       '<leader>m',
--       '<cmd>MCstart<cr>',
--       desc = 'Create a selection for selected text or word under the cursor',
--     },
--   },
-- }
