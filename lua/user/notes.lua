local vim = _G.vim -- Let lua lsp know that vim is global

local M = {}

local function toggle_checkbox()
  local line = vim.fn.getline('.')
  local states = { ' ', 'x', '-' }
  local checkbox_pattern = '%[.%]'

  if string.find(line, checkbox_pattern) then
    -- table.insert(states, states[1])
    local pattern

    for i, state in ipairs(states) do
      if state == '-' then
        -- Need to escape the `-` state since that has meaning in the pattern
        pattern = '%[%' .. state .. '%]'
      else
        pattern = '%[' .. state .. '%]'
      end

      if string.find(line, pattern) then
        local next_i = math.fmod(i, 3) + 1 -- lua starts at 1
        local next_state = states[next_i]
        line = string.gsub(line, checkbox_pattern, '[' .. next_state .. ']', 1)
        break
      end
    end
  else
    -- Capture the leading whitespace
    local leading_space = string.match(line, "^(%s*)") or ""
    -- Remove the leading hyphens and any subsequent whitespace
    line = string.gsub(line, "^%s*-%s*", "", 1)
    -- Preserve leading whitespace
    line = leading_space .. '- [ ] ' .. line
  end

  vim.fn.setline('.', line)
end


-- Goto Heading considered helpful
local function goto_heading_from_anchor()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line_num, col = unpack(cursor)
  local link_start, link_end, link_match = string.find(line, "%[[^%]]*%](%(#[%w_-]*)%)")
  print('link_start: ', link_start, 'link_end: ', link_end, 'link_match: ', link_match)

  local cursor_in_link = col >= link_start - 1 and col <= link_end - 1 -- handle lua's 1-based indexing

  if link_match and cursor_in_link then
    local heading_reference = link_match:match("#(.*)")
    -- print('heading_reference: &', heading_reference)

    local heading_pattern = "#*\\s*" .. heading_reference:gsub("[ %-]", "[ \\-]")
    -- print('heading_pattern: ', heading_pattern)

    -- prevent matches on the current line
    local skip_pattern = "line('.') == " .. line_num

    -- flags:
    -- - s: set cursor jump position
    -- - c: case insensitive
    local search_result = vim.fn.search(heading_pattern, "sc", nil, nil, skip_pattern)
    -- print('search_result: ', search_result)

    if search_result == line_num then
      -- print('jump to anchor failed to find heading')
      return
    end

    if search_result ~= 0 then
      local buffer = vim.api.nvim_get_current_buf()
      vim.api.nvim_win_set_cursor(0, { search_result, 0 })
    end
  end
end


local function MakeNote(type, title)
  local file_name = title -- Use the title argument directly

  local cmd
  if type == 'work' then
    cmd = 'zk work_note "' .. file_name .. '"'
  elseif type == 'ticket' then
    cmd = 'zk ticket "' .. file_name .. '"'
  elseif type == 'personal' then
    cmd = 'zk new -p -t "' .. file_name .. '"'
  end

  local path = vim.fn.system(cmd)
  path = path:gsub("^%s+", ""):gsub("%s+$", "") -- Trim whitespace

  local escaped_path = vim.fn.fnameescape(path)
  vim.cmd('e ' .. escaped_path)
end

function M.keymaps()
  vim.keymap.set("n", "<leader>ge", goto_heading_from_anchor, { desc = "Go to Heading from Anchor" })
  vim.keymap.set('n', '<leader>tt', toggle_checkbox, { noremap = true, silent = true })

  vim.keymap.set('n', '<leader>nn', function()
    local title = vim.fn.input('Note title: ')
    if title ~= '' then MakeNote('personal', title) end
  end, { desc = "New Note" })

  vim.keymap.set('n', '<leader>nwn', function()
    local title = vim.fn.input('Work note title: ')
    if title ~= '' then MakeNote('work', title) end
  end, { desc = "New Work Note" })

  vim.keymap.set('n', '<leader>nwt', function()
    local title = vim.fn.input('Ticket ID: ')
    if title ~= '' then MakeNote('ticket', title) end
  end, { desc = "New Ticket Note" })
end

return M

-- Notes related searches
--vim.keymap.set('n', '<leader>fn', function()
--    require("fzf-lua").fzf_live(
--      function(q)
--        local tags = ''
--
--        for t in string.gmatch(q, "%S+") do
--          tags = tags .. '-t ' .. t .. ' '
--        end
--        return "zk list -q " .. tags
--      end, { prompt = 'Tags>' }
--    )
--  end,
--  { desc = "Keymaps", noremap = true }
--)
