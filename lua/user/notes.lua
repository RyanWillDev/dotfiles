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

-- Helper function to normalize heading text to anchor format
-- "My Heading!" -> "my-heading"
local function normalize_to_anchor(text)
  local normalized = text:lower()
  -- Replace spaces with hyphens
  normalized = normalized:gsub("%s+", "-")
  -- Remove special characters except hyphens
  normalized = normalized:gsub("[^%w%-]", "")
  -- Remove multiple consecutive hyphens
  normalized = normalized:gsub("%-+", "-")
  -- Remove leading/trailing hyphens
  normalized = normalized:gsub("^%-+", ""):gsub("%-+$", "")
  return normalized
end

-- Helper function to extract heading text from a markdown heading line
-- "## My Heading" -> "My Heading", 2
-- Returns: heading_text, heading_level (or nil if not a heading)
local function extract_heading(line)
  -- Match markdown headings: one or more # at start, followed by space, then text
  local hashes, text = line:match("^(#+)%s+(.+)$")
  if hashes then
    return text, #hashes
  end
  return nil, nil
end

-- Goto Heading considered helpful
local function goto_heading_from_anchor()
  local line = vim.api.nvim_get_current_line()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line_num, col = unpack(cursor)

  -- Updated pattern to capture everything after # (including multiple # separators)
  local link_start, link_end, link_match = string.find(line, "%[[^%]]*%]%(#([^%)]+)%)")

  if not link_match then
    return
  end

  local cursor_in_link = col >= link_start - 1 and col <= link_end - 1

  if not cursor_in_link then
    return
  end

  -- Split anchor by # to handle nested headings like "first#second"
  local anchors = {}
  for anchor in link_match:gmatch("[^#]+") do
    table.insert(anchors, anchor)
  end

  if #anchors == 0 then
    return
  end

  -- Save current position to jump list using 's' flag in search
  -- Start searching from the beginning of the file for the first anchor
  local search_start_line = 1
  local last_found_line = nil
  local last_found_level = 0

  -- Search for each anchor in the path
  for i, anchor in ipairs(anchors) do
    local found = false

    -- Search from search_start_line to end of file
    for lnum = search_start_line, vim.fn.line('$') do
      local target_line = vim.fn.getline(lnum)
      local heading_text, heading_level = extract_heading(target_line)

      if heading_text then
        local normalized = normalize_to_anchor(heading_text)

        -- Check if normalized heading starts with the anchor (prefix matching)
        local matches = normalized:sub(1, #anchor) == anchor

        -- For nested anchors, ensure we're going deeper in the hierarchy
        if i == 1 then
          -- First anchor: match any level
          if matches then
            last_found_line = lnum
            last_found_level = heading_level
            search_start_line = lnum + 1
            found = true
            break
          end
        else
          -- Nested anchor: must be at a deeper level than the previous
          if matches and heading_level > last_found_level then
            last_found_line = lnum
            last_found_level = heading_level
            search_start_line = lnum + 1
            found = true
            break
          end
        end
      end
    end

    -- If we didn't find this anchor in the chain, abort
    if not found then
      vim.notify("Heading not found: #" .. table.concat(anchors, "#"), vim.log.levels.WARN)
      return
    end
  end

  -- Jump to the final heading found
  if last_found_line and last_found_line ~= line_num then
    -- Add current position to jump list (enables <C-o> and <C-i> navigation)
    vim.cmd("normal! m'")
    vim.api.nvim_win_set_cursor(0, { last_found_line, 0 })
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

local company_name = os.getenv("COMPANY_NAME")

local search_presets = {
  {
    name = "Follow Up",
    description = "Show followup Tags",
    -- Sorts least recently modified first
    args = "-t followup --sort modified+",
  },
  {
    name = "Open Tickets",
    description = "Show all open tickets",
    -- Sorts least recently modified first
    args = company_name .. "/tickets -t ' -done' --sort modified+",
  },
  {
    name = "Tickets In Review",
    description = "Show all open tickets",
    -- Sorts least recently modified first
    args = company_name .. "/tickets -t 'review' --sort modified+",
  },
  {
    name = "Last Week's Tickets",
    description = "Show all tickets updated this week",
    -- Sorts most recently modified first
    args = company_name .. "/tickets --modified-after 'last monday' --sort modified",
  },
  {
    name = "Daily Review",
    description = "Show all notes updated today",
    -- Sorts most recently modified first
    args = "--modified-after '8am' --sort modified",
  },
  {
    name = "Weekly Review",
    description = "Show all notes updated this week",
    -- Sorts most recently modified first
    args = "--modified-after 'last monday' --sort modified",
  },
  {
    name = "Done Tickets",
    description = "Show all completed tickets",
    -- Sorts most recently modified first
    args = company_name .. "/tickets -t 'done' --sort modified",
  },
  {
    name = "Daily Notes",
    description = "Show daily journal entries",
    -- Sorts most recently created first
    args = company_name .. "/daily --sort created"
  },
  {
    name = "Meeting Notes",
    description = "Show meeting notes",
    args = "-t meeting --sort modified",
  },
  {
    name = "Custom Query",
    description = "Enter custom zk list arguments",
    args = nil, -- Will prompt for input
  },
}

local function zk_picker(args, prompt_title)
  local fzf = require('fzf-lua')

  local cmd = 'zk list -f json ' .. (args or '')
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()

  -- Handle empty result
  if not result or result == "" or result:match("^%s*$") then
    vim.notify("No notes found", vim.log.levels.INFO)
    return
  end

  -- Try to decode JSON, handle errors
  local ok, notes = pcall(vim.json.decode, result)
  if not ok then
    vim.notify("Failed to parse zk output: " .. tostring(notes), vim.log.levels.ERROR)
    return
  end

  if not notes or #notes == 0 then
    vim.notify("No notes found", vim.log.levels.INFO)
    return
  end

  -- Rest of the function remains the same...
  local entries = {}
  local note_map = {}

  for _, note in ipairs(notes) do
    local tags = ""
    if note.tags and #note.tags > 0 then
      tags = " [" .. table.concat(note.tags, ", ") .. "]"
    end

    local display = string.format("%-50s %-30s%s",
      note.title or note.path,
      vim.fn.fnamemodify(note.path, ':~:.'),
      tags
    )
    table.insert(entries, display)
    note_map[display] = note
  end

  -- Define default action separately so ctrl-a can reuse it
  local default_action = function(selected)
    if #selected == 0 then return end

    -- We have at least one note we'll open it
    local note = note_map[selected[1]]
    vim.cmd('edit ' .. vim.fn.fnameescape(note.absPath))

    if #selected > 1 then
      -- Build quickfix list from all selected items
      local qf_list = {}
      for _, sel in ipairs(selected) do
        local note = note_map[sel]
        if note then
          table.insert(qf_list, {
            filename = note.absPath,
            text = note.title or note.path,
          })
        end
      end

      -- Populate quickfix and open
      vim.fn.setqflist(qf_list, 'r')
      vim.cmd('copen')

      vim.notify(string.format("Opened %d notes in quickfix", #qf_list), vim.log.levels.INFO)
    end
  end

  fzf.fzf_exec(entries, {
    fzf_opts = {
      ['--multi'] = ''
    },
    prompt = (prompt_title or "Notes") .. "> ",
    preview = function(selected)
      if not selected or #selected == 0 then return "" end
      local note = note_map[selected[1]]
      if note and note.absPath then
        return vim.fn.system(
          string.format('bat --style=plain --color=always "%s" 2>/dev/null || cat "%s"',
            note.absPath, note.absPath)
        )
      end
      return ""
    end,
    actions = {
      ['default'] = default_action,
      ['ctrl-v'] = function(selected)
        if #selected > 0 then
          local note = note_map[selected[1]]
          if note then
            vim.cmd('vsplit ' .. vim.fn.fnameescape(note.absPath))
          end
        end
      end,
      ['ctrl-s'] = function(selected)
        if #selected > 0 then
          local note = note_map[selected[1]]
          if note then
            vim.cmd('split ' .. vim.fn.fnameescape(note.absPath))
          end
        end
      end,
      ['ctrl-t'] = function(selected)
        if #selected > 0 then
          local note = note_map[selected[1]]
          if note then
            vim.cmd('tabnew ' .. vim.fn.fnameescape(note.absPath))
          end
        end
      end,
      ['ctrl-a'] = function()
        -- Pass all entries to the default action
        default_action(entries)
      end,
    },
    winopts = {
      height = 0.85,
      width = 0.90,
      preview = {
        layout = 'vertical',
        vertical = 'down:50%',
      }
    }
  })
end

local function note_search_menu()
  local fzf = require('fzf-lua')

  local entries = {}
  local preset_map = {} -- Add this map

  for _, preset in ipairs(search_presets) do
    local entry = string.format("%-20s %s", preset.name, preset.description)
    table.insert(entries, entry)
    preset_map[entry] = preset -- Map the full entry to the preset
  end

  fzf.fzf_exec(entries, {
    prompt = 'Search Type> ',
    winopts = {
      height = 0.4,
      width = 0.6,
    },
    actions = {
      ['default'] = function(selected)
        if not selected or #selected == 0 then return end

        local preset = preset_map[selected[1]] -- Direct lookup
        if not preset then return end

        -- Handle custom query
        if preset.args == nil then
          require('fzf-lua').fzf_exec({}, {
            prompt = 'Custom Query> ',
            fzf_opts = {
              ['--print-query'] = '', -- Print the query even if no selection
            },
            winopts = {
              height = 0.4,
              width = 0.7,
            },
            actions = {
              ['default'] = function(selected, opts)
                -- If user typed something, it's in opts.last_query
                local query = opts.last_query or (selected and selected[1]) or ""
                if query ~= "" then
                  zk_picker(query, "Custom")
                end
              end,
            },
          })
        else
          zk_picker(preset.args, preset.name)
        end
      end,
    },
  })
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

  vim.keymap.set('n', '<leader>ns', note_search_menu, { desc = 'Note Search Menu' })
  vim.keymap.set('n', '<leader>ni', function()
    vim.notify("Indexing notes...", vim.log.levels.INFO)
    vim.fn.jobstart('zk index', {
      on_exit = function(_, exit_code)
        if exit_code == 0 then
          vim.notify("zk index complete", vim.log.levels.INFO)
        else
          vim.notify("zk index failed", vim.log.levels.ERROR)
        end
      end
    })
  end, { desc = 'Run zk index' })
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
