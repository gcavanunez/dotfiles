-- ============================================================================
-- Statusline component helpers
-- ============================================================================

local config = require('user.statusline.config')
local MODES  = config.MODES
local ICON   = config.ICON
local FORMAT_ICONS = config.FORMAT_ICONS

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- Component helpers
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local function get_mode()
  local code = vim.api.nvim_get_mode().mode
  return MODES[code] or MODES[code:sub(1, 1)] or { 'NORMAL', 'Normal' }
end

--- Escape percent signs so they survive statusline evaluation.
local function esc(str)
  return (str:gsub('%%', '%%%%'))
end

local function is_git(bufnr)
  return vim.b[bufnr].gitsigns_head ~= nil
end

local function git_branch(bufnr)
  return vim.b[bufnr].gitsigns_head or ''
end

local function git_diff(bufnr)
  local d = vim.b[bufnr].gitsigns_status_dict
  if not d then return nil end
  return { added = d.added or 0, removed = d.removed or 0, changed = d.changed or 0 }
end

local function has_lsp(bufnr)
  return #vim.lsp.get_clients({ bufnr = bufnr }) > 0
end

local function diagnostics(bufnr)
  local sev = vim.diagnostic.severity
  return {
    e = #vim.diagnostic.get(bufnr, { severity = sev.ERROR }),
    w = #vim.diagnostic.get(bufnr, { severity = sev.WARN }),
    h = #vim.diagnostic.get(bufnr, { severity = sev.HINT }),
  }
end

local function modified_icon(bufnr)
  return vim.bo[bufnr].modified and '● ' or ''
end

local function filename(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == '' then return '[No Name] ' end
  return vim.fn.fnamemodify(name, ':~:.') .. ' '
end

local function file_encoding()
  local enc = vim.bo.fileencoding
  if enc == '' then enc = vim.o.encoding end
  return enc
end

local function file_format()
  local fmt = vim.bo.fileformat
  return FORMAT_ICONS[fmt] or fmt
end

local function filetype_icon(bufnr)
  local ft = vim.bo[bufnr].filetype
  if ft == '' then return '' end
  local ok, icons = pcall(require, 'nvim-web-devicons')
  if ok then
    local icon = icons.get_icon_by_filetype(ft)
    if icon then return icon .. ' ' .. ft end
  end
  return ft
end

local function search_count()
  if vim.v.hlsearch == 0 then return '' end
  local ok, sc = pcall(vim.fn.searchcount, { maxcount = 999, timeout = 250 })
  if not ok or not sc or sc.total == 0 then return '' end
  if sc.incomplete == 1 then return ' [?/?]' end
  return string.format(' [%d/%d]', sc.current, sc.total)
end

return {
  get_mode      = get_mode,
  esc           = esc,
  is_git        = is_git,
  git_branch    = git_branch,
  git_diff      = git_diff,
  has_lsp       = has_lsp,
  diagnostics   = diagnostics,
  modified_icon = modified_icon,
  filename      = filename,
  file_encoding = file_encoding,
  file_format   = file_format,
  filetype_icon = filetype_icon,
  search_count  = search_count,
}
