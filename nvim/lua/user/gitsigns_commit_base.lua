-- Mark the lines a commit changed in the sign column, in a single color
-- (GitSignsCommit), while gitsigns keeps showing uncommitted edits as usual.
--
-- The signs sit just below gitsigns' priority, so a line you edit by hand shows
-- the regular gitsigns sign instead. The name matches snacks.statuscolumn's
-- "GitSign" pattern, so both share the git slot.

local M = {}

local ns = vim.api.nvim_create_namespace('user_gitsigns_commit_base')
local priority = require('gitsigns.config').config.sign_priority - 1

local function git(cwd, args)
  local res = vim.system(vim.list_extend({ 'git', '--no-pager' }, args), { cwd = cwd, text = true }):wait()
  return res.code == 0 and res.stdout or nil
end

local function show(cwd, rev, relpath)
  return git(cwd, { 'show', rev .. ':' .. relpath }) or ''
end

-- The file's path in the commit's parent: its old name if the commit renamed it.
local function parent_path(cwd, commit, relpath)
  -- -z output: status, then one path (or old and new paths for a rename), each NUL-terminated.
  local fields = vim.split(git(cwd, { 'diff', '--name-status', '-M', '-z', commit .. '^', commit }) or '', '\0', { plain = true })
  local i = 1
  while i < #fields do
    if fields[i]:match('^R') then
      if fields[i + 2] == relpath then
        return fields[i + 1]
      end
      i = i + 3
    else
      i = i + 2
    end
  end
  return relpath
end

-- Map lines of `old` to lines of `new` (1-based); changed lines are absent.
local function line_map(old, new)
  local map, old_lnum, new_lnum = {}, 1, 1
  local old_count = #vim.split(old, '\n', { plain = true })
  for _, h in ipairs(vim.text.diff(old, new, { result_type = 'indices' })) do
    local start_a, count_a, start_b, count_b = unpack(h)
    local hunk_start = count_a == 0 and start_a + 1 or start_a
    while old_lnum < hunk_start do
      map[old_lnum] = new_lnum
      old_lnum, new_lnum = old_lnum + 1, new_lnum + 1
    end
    old_lnum = hunk_start + count_a
    new_lnum = (count_b == 0 and start_b + 1 or start_b) + count_b
  end
  while old_lnum <= old_count do
    map[old_lnum] = new_lnum
    old_lnum, new_lnum = old_lnum + 1, new_lnum + 1
  end
  return map
end

local function place(bufnr, lnum, text)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  if lnum < 1 or lnum > line_count then
    return
  end
  vim.api.nvim_buf_set_extmark(bufnr, ns, lnum - 1, 0, {
    sign_text = text,
    sign_hl_group = 'GitSignsCommit',
    priority = priority,
  })
end

--- Mark the lines `commit` changed in `bufnr`.
function M.set(bufnr, commit)
  vim.api.nvim_set_hl(0, 'GitSignsCommit', { link = 'DiagnosticWarn', default = true })

  local file = vim.api.nvim_buf_get_name(bufnr)
  local cwd = vim.fs.dirname(file)
  local toplevel = vim.trim(git(cwd, { 'rev-parse', '--show-toplevel' }) or '')
  if toplevel == '' then
    return
  end
  local relpath = file:sub(#toplevel + 2)

  local parent_text = show(toplevel, commit .. '^', parent_path(toplevel, commit, relpath))
  local commit_text = show(toplevel, commit, relpath)
  local buf_text = table.concat(vim.api.nvim_buf_get_lines(bufnr, 0, -1, false), '\n') .. '\n'

  -- Commit lines -> buffer lines, in case the file changed after the commit.
  local to_buf = line_map(commit_text, buf_text)

  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  for _, h in ipairs(vim.text.diff(parent_text, commit_text, { result_type = 'indices' })) do
    local start_b, count_b = h[3], h[4]
    if count_b > 0 then
      for lnum = start_b, start_b + count_b - 1 do
        if to_buf[lnum] then
          place(bufnr, to_buf[lnum], '│')
        end
      end
    elseif start_b == 0 then
      place(bufnr, 1, '‾')
    elseif to_buf[start_b] then
      place(bufnr, to_buf[start_b], '_')
    end
  end
  vim.b[bufnr].gitsigns_commit_base = commit
end

--- Remove the commit signs from `bufnr`.
function M.reset(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  vim.b[bufnr].gitsigns_commit_base = nil
end

return M
