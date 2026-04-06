-- ============================================================================
-- Statusline configuration: separators, icons, modes, colours
-- ============================================================================

-- Available separators (swap SEP_RIGHT / SEP_LEFT below to change style)
local sep             = {
  vertical_bar       = '┃',
  vertical_bar_thin  = '│',
  left               = '',
  right              = '',
  block              = '█',
  block_thin         = '▌',
  left_filled        = '',
  right_filled       = '',
  slant_left         = '',
  slant_left_thin    = '',
  slant_right        = '',
  slant_right_thin   = '',
  slant_left_2       = '',
  slant_left_2_thin  = '',
  slant_right_2      = '',
  slant_right_2_thin = '',
  left_rounded       = '',
  left_rounded_thin  = '',
  right_rounded      = '',
  right_rounded_thin = '',
  circle             = '●',
}

-- Pick your style here:
local SEP_RIGHT       = sep.slant_right_2
local SEP_LEFT        = sep.slant_left_2

-- Width below which components collapse
local BREAKPOINT      = 100

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Mode definitions
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

---@type table<string, {[1]:string, [2]:string}>
local MODES           = {
  ['n']     = { 'NORMAL', 'Normal' },
  ['no']    = { 'O-PENDING', 'Normal' },
  ['nov']   = { 'O-PENDING', 'Normal' },
  ['noV']   = { 'O-PENDING', 'Normal' },
  ['no\22'] = { 'O-PENDING', 'Normal' },
  ['niI']   = { 'NORMAL', 'Normal' },
  ['niR']   = { 'NORMAL', 'Normal' },
  ['niV']   = { 'NORMAL', 'Normal' },
  ['nt']    = { 'NORMAL', 'Normal' },
  ['ntT']   = { 'NORMAL', 'Normal' },
  ['v']     = { 'VISUAL', 'Visual' },
  ['vs']    = { 'VISUAL', 'Visual' },
  ['V']     = { 'V-LINE', 'Visual' },
  ['Vs']    = { 'V-LINE', 'Visual' },
  ['\22']   = { 'V-BLOCK', 'Visual' },
  ['\22s']  = { 'V-BLOCK', 'Visual' },
  ['s']     = { 'SELECT', 'Visual' },
  ['S']     = { 'S-LINE', 'Visual' },
  ['\19']   = { 'S-BLOCK', 'Visual' },
  ['i']     = { 'INSERT', 'Insert' },
  ['ic']    = { 'INSERT', 'Insert' },
  ['ix']    = { 'INSERT', 'Insert' },
  ['R']     = { 'REPLACE', 'Replace' },
  ['Rc']    = { 'REPLACE', 'Replace' },
  ['Rx']    = { 'REPLACE', 'Replace' },
  ['Rv']    = { 'V-REPLACE', 'Replace' },
  ['Rvc']   = { 'V-REPLACE', 'Replace' },
  ['Rvx']   = { 'V-REPLACE', 'Replace' },
  ['c']     = { 'COMMAND', 'Command' },
  ['cv']    = { 'EX', 'Command' },
  ['ce']    = { 'EX', 'Command' },
  ['r']     = { 'REPLACE', 'Replace' },
  ['rm']    = { 'MORE', 'Normal' },
  ['r?']    = { 'CONFIRM', 'Normal' },
  ['!']     = { 'SHELL', 'Command' },
  ['t']     = { 'TERMINAL', 'Command' },
}

-- Maps mode-key to base terminal color name
local MODE_BASE_COLOR = {
  Normal  = 'magenta',
  Insert  = 'green',
  Visual  = 'yellow',
  Replace = 'blue',
  Command = 'red',
}

local FORMAT_ICONS    = {
  unix = '', -- nf-fa-linux
  dos  = '', -- nf-fa-windows
  mac  = '', -- nf-fa-apple
}

-- Nerd Font icons (escape sequences survive file I/O)
local ICON            = {
  error   = '', -- nf-fa-times_circle
  warn    = '', -- nf-fa-exclamation_triangle
  hint    = '', -- nf-fa-info_circle
  added   = '', -- nf-fa-plus_square
  removed = '', -- nf-fa-minus_square
  changed = '', -- nf-oct-diff_modified
  folder  = '', -- nf-oct-file_directory
  branch  = '', -- nf-dev-git_branch
}

return {
  sep             = sep,
  SEP_RIGHT       = SEP_RIGHT,
  SEP_LEFT        = SEP_LEFT,
  BREAKPOINT      = BREAKPOINT,
  MODES           = MODES,
  MODE_BASE_COLOR = MODE_BASE_COLOR,
  FORMAT_ICONS    = FORMAT_ICONS,
  ICON            = ICON,
}
