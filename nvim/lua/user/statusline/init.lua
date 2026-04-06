-- ============================================================================
-- Custom statusline  (replaces windline.nvim)
-- ============================================================================
--
-- LAYOUT (airline-style, 7 sections + centre info)
-- ============================================================================
--
--  LEFT                           CENTRE                              RIGHT
--  A    B       C                  diagnostics / search     git   X       Y     Z
-- [MODE][BRANCH][FILE            ][ 0  0  0 [n/m]  ====  +1 -2][ENC FMT][TYPE][POS ]
--       |       |                 |                    %=       |       |     |
--       |       |                 |                             |       |     |
--       |       +- filename       +- on NormalBg                |       |     +- progress + line:col
--       +- git branch (gitsigns)     (LSP diag, search count,  |       +- filetype + devicon
--                                     git diff +/-/~)          +- file encoding + format icon
--
-- Each section (A/B/C and X/Y/Z) has a mode-specific background colour
-- derived from three shade levels of the mode's base colour:
--
--   A / Z  = full colour       (_a)
--   B / Y  = 50 % shade/tint   (_b)
--   C / X  = 70 % shade/tint   (_c)
--
-- Separators sit BETWEEN sections.  SEP_RIGHT () points left-to-right
-- and is used on the left side.  SEP_LEFT () points right-to-left and
-- is used on the right side.  The separator's fg = outgoing section bg,
-- bg = incoming section bg -- this is what creates the coloured arrow.
--
-- WIDTH RESPONSIVENESS
-- ============================================================================
-- When window width <= BREAKPOINT (100 cols):
--   - Section A shows only the first letter of the mode
--   - Section B (branch) is hidden
--   - Section X (encoding/format) is hidden
--   - Section Y (filetype) is hidden
--   - Section Z shows only line:col (no progress %)
--   - Git diff is hidden
--
-- SPECIAL FILETYPES
-- ============================================================================
-- quickfix / Trouble  -> render_quickfix()   (always-active)
-- NvimTree / fern / lir -> render_explorer() (always-active)
--
-- COLOURS
-- ============================================================================
-- Terminal colours (g:terminal_color_0..15) + Normal/StatusLine highlight
-- groups are read on setup and on every ColorScheme event.  HSL shade/tint
-- functions generate the _b and _c variants automatically.
--
-- HOW TO CUSTOMISE
-- ============================================================================
-- Separators : change SEP_RIGHT / SEP_LEFT refs below (line ~53)
-- Icons      : edit the ICON table (line ~100)
-- Sections   : edit render_active() (line ~400)
-- Colours    : edit MODE_BASE_COLOR or the shade amounts in refresh_colors()
-- Breakpoint : change BREAKPOINT (line ~57)
-- ============================================================================

local colors = require('user.statusline.colors')
local render = require('user.statusline.render')

local M = {}

--- Called by the statusline expression  `%!v:lua.require'user.statusline'.render()`
function M.render()
  local winid = vim.g.statusline_winid
  if not winid or not vim.api.nvim_win_is_valid(winid) then return '' end

  local bufnr = vim.api.nvim_win_get_buf(winid)
  local ft    = vim.bo[bufnr].filetype
  local width = vim.api.nvim_win_get_width(winid)

  -- Special filetypes (always show active variant)
  if render.QUICKFIX_FTS[ft] then return render.quickfix() end
  if render.EXPLORER_FTS[ft] then return render.explorer(bufnr) end

  -- Default
  local active = (winid == vim.api.nvim_get_current_win())
  if active then
    return render.active(bufnr, width)
  end
  return render.inactive(bufnr)
end

function M.setup()
  colors.refresh_colors()
  colors.refresh_highlights()

  -- Global statusline expression
  vim.o.statusline = "%!v:lua.require'user.statusline'.render()"

  -- Refresh palette + highlights whenever the colorscheme changes
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('UserStatusline', { clear = true }),
    callback = function()
      colors.refresh_colors()
      colors.refresh_highlights()
    end,
  })
end

return M
