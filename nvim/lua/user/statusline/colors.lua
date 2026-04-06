-- ============================================================================
-- Colour palette and highlight group management
-- ============================================================================

local config = require('user.statusline.config')
local MODE_BASE_COLOR = config.MODE_BASE_COLOR

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- HSL color utilities (replaces wlanimation.utils)
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local function hex_to_rgb(hex)
  hex = hex:gsub('#', '')
  return
      tonumber(hex:sub(1, 2), 16) / 255,
      tonumber(hex:sub(3, 4), 16) / 255,
      tonumber(hex:sub(5, 6), 16) / 255
end

local function clamp01(v)
  return math.min(1, math.max(0, v))
end

local function rgb_to_hex(r, g, b)
  return string.format(
    '#%02x%02x%02x',
    math.floor(clamp01(r) * 255 + 0.5),
    math.floor(clamp01(g) * 255 + 0.5),
    math.floor(clamp01(b) * 255 + 0.5)
  )
end

local function rgb_to_hsl(r, g, b)
  local mx, mn = math.max(r, g, b), math.min(r, g, b)
  local h, s, l = 0, 0, (mx + mn) / 2

  if mx ~= mn then
    local d = mx - mn
    s = l > 0.5 and d / (2 - mx - mn) or d / (mx + mn)
    if mx == r then
      h = (g - b) / d + (g < b and 6 or 0)
    elseif mx == g then
      h = (b - r) / d + 2
    else
      h = (r - g) / d + 4
    end
    h = h / 6
  end
  return h, s, l
end

local function hsl_to_rgb(h, s, l)
  if s == 0 then return l, l, l end
  local function f(p, q, t)
    if t < 0 then t = t + 1 end
    if t > 1 then t = t - 1 end
    if t < 1 / 6 then return p + (q - p) * 6 * t end
    if t < 1 / 2 then return q end
    if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
    return p
  end
  local q = l < 0.5 and l * (1 + s) or l + s - l * s
  local p = 2 * l - q
  return f(p, q, h + 1 / 3), f(p, q, h), f(p, q, h - 1 / 3)
end

--- Shade (darken) or tint (lighten) a hex color.
--- Matches windline's `HSL.shade(value)` / `HSL.tint(value)` behaviour:
---   dark bg  -> shade (darken by `amount`)
---   light bg -> tint  (lighten by `amount`)
local function shade_hex(hex, amount)
  local r, g, b = hex_to_rgb(hex)
  local h, s, l = rgb_to_hsl(r, g, b)
  if vim.o.background == 'light' then
    l = l + (1 - l) * amount -- tint toward white
  else
    l = l * (1 - amount)     -- shade toward black
  end
  return rgb_to_hex(hsl_to_rgb(h, s, l))
end

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Color palette & highlight management
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local C = {} -- cached palette

local function hl_color(group)
  local h = vim.api.nvim_get_hl(0, { name = group, link = false })
  return h.fg and string.format('#%06x', h.fg),
      h.bg and string.format('#%06x', h.bg)
end

local function refresh_colors()
  local tc         = function(n) return vim.g['terminal_color_' .. n] end

  C.black          = tc(0) or '#000000'
  C.red            = tc(1) or '#ff5555'
  C.green          = tc(2) or '#50fa7b'
  C.yellow         = tc(3) or '#f1fa8c'
  C.blue           = tc(4) or '#bd93f9'
  C.magenta        = tc(5) or '#ff79c6'
  C.cyan           = tc(6) or '#8be9fd'
  C.white          = tc(7) or '#f8f8f2'
  C.black_light    = tc(8) or '#444444'

  local nfg, nbg   = hl_color('Normal')
  local sfg, sbg   = hl_color('StatusLine')
  local ncfg, ncbg = hl_color('StatusLineNC')

  C.NormalFg       = nfg or C.white
  C.NormalBg       = nbg or '#1a1b26'
  C.ActiveFg       = sfg or C.black
  C.ActiveBg       = sbg or C.white
  C.InactiveFg     = ncfg or C.white
  C.InactiveBg     = ncbg or C.black

  -- Three shade levels per mode color: _a (full), _b (50%), _c (70%)
  for _, name in ipairs { 'magenta', 'green', 'yellow', 'blue', 'red' } do
    C[name .. '_a'] = C[name]
    C[name .. '_b'] = shade_hex(C[name], 0.5)
    C[name .. '_c'] = shade_hex(C[name], 0.7)
  end
end

local function hi(name, fg, bg)
  vim.api.nvim_set_hl(0, name, { fg = fg, bg = bg })
end

local function refresh_highlights()
  -- Base
  hi('Stl_Normal', C.NormalFg, C.NormalBg)
  hi('Stl_Inactive', C.InactiveFg, C.InactiveBg)

  -- Diagnostics on NormalBg
  hi('Stl_DiagError', C.red, C.NormalBg)
  hi('Stl_DiagWarn', C.yellow, C.NormalBg)
  hi('Stl_DiagHint', C.blue, C.NormalBg)
  hi('Stl_Search', C.cyan, C.NormalBg)

  -- Git diff on NormalBg
  hi('Stl_GitAdd', C.green, C.NormalBg)
  hi('Stl_GitDel', C.red, C.NormalBg)
  hi('Stl_GitChg', C.blue, C.NormalBg)

  -- Quickfix / Trouble
  hi('Stl_QF', C.white, C.black)
  hi('Stl_QFSep1', C.black, C.black_light)
  hi('Stl_QFTitle', C.cyan, C.black_light)
  hi('Stl_QFSep2', C.black_light, C.InactiveBg)
  hi('Stl_QFMid', C.InactiveFg, C.InactiveBg)
  hi('Stl_QFSep3', C.InactiveBg, C.black)
  hi('Stl_QFEnd', C.white, C.black)

  -- Explorer
  hi('Stl_Explorer', C.white, C.magenta_b)
  hi('Stl_ExplorerSep', C.magenta_b, C.NormalBg)
  hi('Stl_ExplorerFn', C.NormalFg, C.NormalBg)

  -- Per-mode airline sections  (A / B / C) + separator transitions
  for mk, base in pairs(MODE_BASE_COLOR) do
    local a  = C[base .. '_a']
    local b  = C[base .. '_b']
    local mc = C[base .. '_c']

    -- Section backgrounds
    hi('Stl_A_' .. mk, C.black, a)
    hi('Stl_B_' .. mk, C.white, b)
    hi('Stl_C_' .. mk, C.white, mc)

    -- Left-side separators ( right-pointing slant)
    hi('Stl_AB_' .. mk, a, b)           -- A -> B
    hi('Stl_BC_' .. mk, b, mc)          -- B -> C
    hi('Stl_CN_' .. mk, mc, C.NormalBg) -- C -> NormalBg

    -- Right-side separators ( left-pointing slant)
    hi('Stl_NC_' .. mk, mc, C.NormalBg) -- NormalBg -> C
    hi('Stl_CB_' .. mk, b, mc)          -- C -> B
    hi('Stl_BA_' .. mk, a, b)           -- B -> A
  end
end

return {
  C                  = C,
  refresh_colors     = refresh_colors,
  refresh_highlights = refresh_highlights,
}
