-- ============================================================================
-- Statusline renderers
-- ============================================================================
--
-- Each component is a function:
--   (ctx) -> { { hl_group, text } }[] | nil
--
-- ctx = { bufnr, width, mode_key (mk), mode_label (ml) }
--
-- Components return a list of { highlight_group, text } pairs including
-- their own trailing separator.  Returning nil skips the component.
-- The engine flattens all segments into a single statusline string.
-- ============================================================================

local config        = require('user.statusline.config')
local comp          = require('user.statusline.components')

local SEP_RIGHT     = config.SEP_RIGHT
local SEP_LEFT      = config.SEP_LEFT
local BREAKPOINT    = config.BREAKPOINT
local ICON          = config.ICON

local esc           = comp.esc
local get_mode      = comp.get_mode
local is_git        = comp.is_git
local git_branch    = comp.git_branch
local git_diff      = comp.git_diff
local has_lsp       = comp.has_lsp
local diagnostics   = comp.diagnostics
local modified_icon = comp.modified_icon
local filename      = comp.filename
local file_encoding = comp.file_encoding
local file_format   = comp.file_format
local filetype_icon = comp.filetype_icon
local search_count  = comp.search_count

-- engine
-- Walks a layout (list of component functions), calls each with ctx,
-- flattens the returned { hl, text } pairs into a statusline string.

local function render_layout(layout, ctx)
  local parts = {}
  local n = 0
  for _, component in ipairs(layout) do
    local segments = component(ctx)
    if segments then
      for _, seg in ipairs(segments) do
        n = n + 1
        parts[n] = '%#' .. seg[1] .. '#' .. seg[2]
      end
    end
  end
  return table.concat(parts)
end

-- components
-- Each returns { { hl_group, text }, ... } or nil to skip.

local function section_a(ctx)
  local mk = ctx.mode_key
  local label = ctx.width > BREAKPOINT and ctx.mode_label or ctx.mode_label:sub(1, 1)
  return {
    { 'Stl_A_' .. mk,  ' ' .. label .. ' ' },
    { 'Stl_AB_' .. mk, SEP_RIGHT },
  }
end

local function section_b(ctx)
  local mk = ctx.mode_key
  if ctx.width > BREAKPOINT and is_git(ctx.bufnr) then
    return {
      { 'Stl_B_' .. mk,  ' ' .. ICON.branch .. ' ' .. esc(git_branch(ctx.bufnr)) .. ' ' },
      { 'Stl_BC_' .. mk, SEP_RIGHT },
    }
  end
  return {
    { 'Stl_BC_' .. mk, SEP_RIGHT },
  }
end

local function section_c(ctx)
  local mk = ctx.mode_key
  return {
    { 'Stl_C_' .. mk,  ' ' .. modified_icon(ctx.bufnr) .. esc(filename(ctx.bufnr)) },
    { 'Stl_CN_' .. mk, SEP_RIGHT },
  }
end

local function lsp_diagnostics(ctx)
  if not has_lsp(ctx.bufnr) then return nil end
  local d = diagnostics(ctx.bufnr)
  return {
    { 'Stl_DiagError', ' ' .. ICON.error .. ' ' .. d.e },
    { 'Stl_DiagWarn',  ' ' .. ICON.warn .. ' ' .. d.w },
    { 'Stl_DiagHint',  ' ' .. ICON.hint .. ' ' .. d.h },
  }
end

local function search(ctx)
  local sc = search_count()
  if sc == '' then return nil end
  return {
    { 'Stl_Search', esc(sc) },
  }
end

local function divider()
  return {
    { 'Stl_Normal', '%=' },
  }
end

local function git_diff_section(ctx)
  if ctx.width <= BREAKPOINT or not is_git(ctx.bufnr) then return nil end
  local gd = git_diff(ctx.bufnr)
  if not gd then return nil end

  local segs = {}
  local n = 0
  if gd.added > 0 then
    n = n + 1; segs[n] = { 'Stl_GitAdd', ' ' .. ICON.added .. ' ' .. gd.added }
  end
  if gd.removed > 0 then
    n = n + 1; segs[n] = { 'Stl_GitDel', ' ' .. ICON.removed .. ' ' .. gd.removed }
  end
  if gd.changed > 0 then
    n = n + 1; segs[n] = { 'Stl_GitChg', ' ' .. ICON.changed .. ' ' .. gd.changed }
  end

  if n == 0 then return nil end
  return segs
end

local function section_x(ctx)
  local mk = ctx.mode_key
  if ctx.width > BREAKPOINT then
    return {
      { 'Stl_NC_' .. mk, SEP_LEFT },
      { 'Stl_C_' .. mk,  ' ' .. file_encoding() .. ' ' .. file_format() .. ' ' },
    }
  end
  return {
    { 'Stl_NC_' .. mk, SEP_LEFT },
  }
end

local function section_y(ctx)
  local mk = ctx.mode_key
  if ctx.width > BREAKPOINT then
    return {
      { 'Stl_CB_' .. mk, SEP_LEFT },
      { 'Stl_B_' .. mk,  esc(filetype_icon(ctx.bufnr)) .. ' ' },
    }
  end
  return {
    { 'Stl_CB_' .. mk, SEP_LEFT },
  }
end

local function section_z(ctx)
  local mk = ctx.mode_key
  if ctx.width > BREAKPOINT then
    return {
      { 'Stl_BA_' .. mk, SEP_LEFT },
      { 'Stl_A_' .. mk, '%3p%%%   %3l:%-2c ' },
    }
  end
  return {
    { 'Stl_BA_' .. mk, SEP_LEFT },
    { 'Stl_A_' .. mk,  ' %3l:%-2c ' },
  }
end

-- layout

local active_layout = {
  section_a,
  section_b,
  section_c,
  lsp_diagnostics,
  search,
  divider,
  git_diff_section,
  section_x,
  section_y,
  section_z,
}

-- public renderers

local function render_active(bufnr, width)
  local m = get_mode()
  return render_layout(active_layout, {
    bufnr      = bufnr,
    width      = width,
    mode_key   = m[2],
    mode_label = m[1],
  })
end

local function render_inactive(bufnr)
  return table.concat {
    '%#Stl_Inactive#',
    ' %f %=',
    '%3l:%-2c ',
    '%P ',
  }
end

local QUICKFIX_FTS = { qf = true, Trouble = true }
local EXPLORER_FTS = { fern = true, NvimTree = true, lir = true }

local function render_quickfix()
  local title = ''
  local ok, qf = pcall(vim.fn.getqflist, { title = 0 })
  if ok and qf then title = qf.title or '' end

  return table.concat {
    '%#Stl_QF#', ' 🚦 Quickfix ',
    '%#Stl_QFSep1#', SEP_RIGHT,
    '%#Stl_QFTitle#', esc(title),
    ' Total : %L ',
    '%#Stl_QFSep2#', SEP_RIGHT,
    '%#Stl_QFMid#', ' ',
    '%#Stl_Normal#', '%=',
    '%#Stl_QFSep3#', SEP_LEFT,
    '%#Stl_QFEnd#', ' 🧛 ',
  }
end

local function render_explorer(bufnr)
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name ~= '' then name = vim.fn.fnamemodify(name, ':t') end

  return table.concat {
    '%#Stl_Explorer#', ' ' .. ICON.folder .. ' ',
    '%#Stl_ExplorerSep#', SEP_RIGHT,
    '%#Stl_Normal#', '%=',
    '%#Stl_ExplorerFn#', esc(name),
  }
end

return {
  active       = render_active,
  inactive     = render_inactive,
  quickfix     = render_quickfix,
  explorer     = render_explorer,
  QUICKFIX_FTS = QUICKFIX_FTS,
  EXPLORER_FTS = EXPLORER_FTS,
}
