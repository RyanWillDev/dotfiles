local vim = _G.vim
local M = {}

local ns = vim.api.nvim_create_namespace('redact')

local function setup_highlights()
  local normal_hl = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  local bg_hex = normal_hl.bg and string.format('#%06x', normal_hl.bg) or '#2e3440'

  -- Make actual text invisible as fallback (fg = bg)
  vim.api.nvim_set_hl(0, 'RedactedText', { fg = bg_hex, bg = bg_hex })
  -- Overlay block characters: solid muted bar
  vim.api.nvim_set_hl(0, 'RedactedBlock', { fg = '#4c566a', bg = '#4c566a' })
end

-- Find all !> ... <! regions in buffer.
-- Returns list of {start_line, start_col, end_line, end_col} (0-indexed).
local function find_regions(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local regions = {}
  local open = nil

  for i, line in ipairs(lines) do
    local pos = 1
    while pos <= #line do
      if open then
        local cs, ce = line:find('<!', pos, true)
        if cs then
          table.insert(regions, { open.line, open.col, i - 1, ce })
          open = nil
          pos = ce + 1
        else
          break
        end
      else
        local os, oe = line:find('!>', pos, true)
        if os then
          open = { line = i - 1, col = os - 1 }
          pos = oe + 1
        else
          break
        end
      end
    end
  end

  return regions
end

-- Per-region reveal state (markers stay, overlay is toggled)
local revealed_regions = {}

local function region_key(r)
  return r[1] .. ':' .. r[2] .. ':' .. r[3] .. ':' .. r[4]
end

local function apply(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  for _, r in ipairs(find_regions(bufnr)) do
    if not revealed_regions[region_key(r)] then
      local sl, sc, el, ec = r[1], r[2], r[3], r[4]

      for lnum = sl, el do
        local line = vim.api.nvim_buf_get_lines(bufnr, lnum, lnum + 1, false)[1] or ''
        local c0 = (lnum == sl) and sc or 0
        local c1 = (lnum == el) and ec or #line

        if c1 > c0 then
          local width = vim.fn.strdisplaywidth(line:sub(c0 + 1, c1))
          vim.api.nvim_buf_set_extmark(bufnr, ns, lnum, c0, {
            end_col = c1,
            hl_group = 'RedactedText',
            virt_text = { { string.rep('▒', width), 'RedactedBlock' } },
            virt_text_pos = 'overlay',
            priority = 10000,
          })
        end
      end
    end
  end
end

-- Reveal/hide the redacted region under the cursor.
local function reveal_at_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  local cl = vim.api.nvim_win_get_cursor(0)[1] - 1
  local cc = vim.api.nvim_win_get_cursor(0)[2]

  for _, r in ipairs(find_regions(bufnr)) do
    local sl, sc, el, ec = r[1], r[2], r[3], r[4]

    local inside = false
    if cl > sl and cl < el then
      inside = true
    elseif cl == sl and cl == el then
      inside = cc >= sc and cc < ec
    elseif cl == sl then
      inside = cc >= sc
    elseif cl == el then
      inside = cc < ec
    end

    if inside then
      local key = region_key(r)
      if revealed_regions[key] then
        revealed_regions[key] = nil
      else
        revealed_regions[key] = true
      end
      apply(bufnr)
      return
    end
  end
end

-- Toggle redaction markers on visual selection.
-- Markers are placed inline: !> at start of first line, <! at end of last line.
local function toggle_selection()
  -- Exit visual mode so '< and '> marks reflect the current selection
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'nx', false)

  local bufnr = vim.api.nvim_get_current_buf()
  local sl = vim.fn.line("'<") - 1
  local el = vim.fn.line("'>") - 1

  local first = vim.api.nvim_buf_get_lines(bufnr, sl, sl + 1, false)[1]
  local last = vim.api.nvim_buf_get_lines(bufnr, el, el + 1, false)[1]

  local has_open = first:find('!>', 1, true)
  local has_close = last:find('<!', 1, true)

  if has_open and has_close then
    -- Remove markers (last line first if same line, order matters)
    local new_last = last:gsub('<!', '', 1)
    vim.api.nvim_buf_set_lines(bufnr, el, el + 1, false, { new_last })
    -- Re-read first line in case sl == el
    first = vim.api.nvim_buf_get_lines(bufnr, sl, sl + 1, false)[1]
    local new_first = first:gsub('!>', '', 1)
    vim.api.nvim_buf_set_lines(bufnr, sl, sl + 1, false, { new_first })
  else
    -- Add markers inline
    vim.api.nvim_buf_set_lines(bufnr, el, el + 1, false, { last .. '<!' })
    -- Re-read first line in case sl == el
    first = vim.api.nvim_buf_get_lines(bufnr, sl, sl + 1, false)[1]
    vim.api.nvim_buf_set_lines(bufnr, sl, sl + 1, false, { '!>' .. first })
  end

  apply(bufnr)
end

setup_highlights()

vim.api.nvim_create_autocmd('ColorScheme', { callback = setup_highlights })

vim.api.nvim_create_autocmd({ 'BufReadPost', 'TextChanged', 'InsertLeave' }, {
  pattern = '*.md',
  callback = function(ev) apply(ev.buf) end,
})

vim.api.nvim_create_autocmd({'BufLeave', 'FocusLost'}, {
  pattern = '*.md',
  callback = function(ev)
    revealed_regions = {}
    apply(ev.buf)
  end,
})

function M.keymaps()
  vim.keymap.set('n', '<leader>R', reveal_at_cursor, { desc = 'Reveal/hide redacted region at cursor' })
  vim.keymap.set('v', '<leader>R', toggle_selection, { desc = 'Toggle redact markers on selection' })
end

return M
