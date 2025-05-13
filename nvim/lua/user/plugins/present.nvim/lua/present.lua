local M = {}

M.setup = function()
  -- nothing
end

---@class present.Slides
---@field slides string[]: the slides in the buffer

--- Takes some lines and parses them
---@param lines string[]: the lines in the buffer
---@return present.Slides
local parse_slides = function(lines)
  local slides = { slides = {} }
  local current_slide = {}

  for _, line in ipairs(lines) do
    if line:find('^#') then
      if #current_slide > 0 then
        table.insert(slides.slides, current_slide)
      end

      current_slide = {}
    end

    table.insert(current_slide, line)
  end

  table.insert(slides.slides, current_slide)

  return slides
end

vim.print(parse_slides({
  '# Hello',
  'this is something else',
  '# Hello',
  'this is something else',
}))

return M
