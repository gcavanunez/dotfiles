return {
  'lewis6991/gitsigns.nvim',
  lazy = false,
  keys = {
    { ']h', '<cmd>Gitsigns next_hunk<CR>' },
    { '[h', '<cmd>Gitsigns prev_hunk<CR>' },
    { 'gs', '<cmd>Gitsigns stage_hunk<CR>' },
    { 'gS', '<cmd>Gitsigns undo_stage_hunk<CR>' },
    { 'gp', '<cmd>Gitsigns preview_hunk<CR>' },
    { 'gb', '<cmd>Gitsigns blame_line<CR>' },
  },
  opts = {
    preview_config = {
      border = { '', '', '', ' ' },
    },
    current_line_blame = true,
    current_line_blame_opts = {
      virt_text = true,
      virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
      delay = 1000,
      ignore_whitespace = false,
    },
    signs = {
      add = { text = '│' },
      change = { text = '│' },
      delete = { text = '_' },
      topdelete = { text = '‾' },
      changedelete = { text = '┄' },
      untracked = { text = '┊' },
    },
  },
}
