local vim = _G.vim

local M = {}

local defaults = {
  jar = nil,
  java = "java",
  java_args = { "--enable-native-access=ALL-UNNAMED" },
  exec_args = { "exec", "-f" },
  gui_args = { "gui" },
  viz_launcher = nil, -- defaults to <plugin>/launcher/AlloyViz.java; resolved lazily
  viz_cache_dir = nil, -- defaults to stdpath('cache')/alloy
  open_split = "botright 80vsplit",
  diagnostics = true,
  ns_name = "alloy",
}

M.config = vim.deepcopy(defaults)

local state = {
  job = nil,
  bufnr = nil,
  ns = nil,
}

local function notify(msg, level)
  vim.notify("[alloy] " .. msg, level or vim.log.levels.INFO)
end

local function resolved_jar()
  local jar = M.config.jar or vim.env.ALLOY_JAR
  if not jar or jar == "" then
    notify("no alloy jar configured — set config.jar or $ALLOY_JAR", vim.log.levels.ERROR)
    return nil
  end
  jar = vim.fn.expand(jar)
  if vim.fn.filereadable(jar) == 0 then
    notify("alloy jar not readable: " .. jar, vim.log.levels.ERROR)
    return nil
  end
  return jar
end

local function current_file(arg)
  if arg and arg ~= "" then
    return vim.fn.fnamemodify(vim.fn.expand(arg), ":p")
  end
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    notify("buffer has no file path — save it first", vim.log.levels.ERROR)
    return nil
  end
  if vim.bo.modified then
    vim.cmd("silent! write")
  end
  return name
end

local function ensure_output_buf()
  if state.bufnr and vim.api.nvim_buf_is_valid(state.bufnr) then
    return state.bufnr
  end
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, "alloy://output")
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = false
  vim.bo[buf].filetype = "alloy-output"
  state.bufnr = buf
  return buf
end

local function show_output_window(buf)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      return win
    end
  end
  local prev = vim.api.nvim_get_current_win()
  vim.cmd(M.config.open_split)
  vim.api.nvim_set_current_buf(buf)
  local win = vim.api.nvim_get_current_win()
  vim.wo[win].wrap = false
  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.api.nvim_set_current_win(prev)
  return win
end

local function write_lines(buf, lines)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, -1, -1, false, lines)
  vim.bo[buf].modifiable = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == buf then
      local last = vim.api.nvim_buf_line_count(buf)
      pcall(vim.api.nvim_win_set_cursor, win, { last, 0 })
    end
  end
end

local function reset_output(buf, header)
  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, header)
  vim.bo[buf].modifiable = false
end

local function ns()
  if not state.ns then
    state.ns = vim.api.nvim_create_namespace(M.config.ns_name)
  end
  return state.ns
end

-- Lenient diagnostic extractor. Alloy CLI error formats vary across versions;
-- we try a few common shapes and silently skip lines that don't match.
local function parse_diagnostic(line, file)
  local lnum, col, msg = line:match("^[^:]*:%s*line%s+(%d+)%s+column%s+(%d+):%s*(.*)$")
  if not lnum then
    lnum, col, msg = line:match("line%s+(%d+),%s*column%s+(%d+):%s*(.*)$")
  end
  if not lnum then
    return nil
  end
  local severity = vim.diagnostic.severity.ERROR
  if line:lower():match("warning") then
    severity = vim.diagnostic.severity.WARN
  end
  return {
    bufnr = vim.fn.bufnr(file),
    lnum = tonumber(lnum) - 1,
    col = math.max(0, tonumber(col) - 1),
    message = msg ~= "" and msg or line,
    source = "alloy",
    severity = severity,
  }
end

local function publish_diagnostics(file, lines)
  if not M.config.diagnostics then
    return
  end
  local bufnr = vim.fn.bufnr(file)
  if bufnr < 0 then
    return
  end
  local diags = {}
  for _, line in ipairs(lines) do
    local d = parse_diagnostic(line, file)
    if d then
      table.insert(diags, d)
    end
  end
  vim.diagnostic.set(ns(), bufnr, diags)
end

local noise_patterns = {
  "^WARNING: ",
  "^java%.lang%.System has been called",
}

local function is_noise(line)
  for _, p in ipairs(noise_patterns) do
    if line:match(p) then return true end
  end
  return false
end

local function exec_outdir(file)
  local base = vim.fn.fnamemodify(file, ":t:r")
  local dir = vim.fn.stdpath("cache") .. "/alloy/" .. base
  vim.fn.mkdir(dir, "p")
  return dir
end

local function read_receipt(outdir)
  local path = outdir .. "/receipt.json"
  if vim.fn.filereadable(path) == 0 then return nil end
  local ok_read, content = pcall(vim.fn.readfile, path)
  if not ok_read then return nil end
  local ok_parse, parsed = pcall(vim.json.decode, table.concat(content, "\n"))
  if not ok_parse then return nil end
  return parsed
end

local function cmd_verdict(cmd)
  local ctype = cmd.type or "run"
  local has_instance = false
  for _, sol in ipairs(cmd.solution or {}) do
    if sol.instances and #sol.instances > 0 then
      has_instance = true
      break
    end
  end
  if ctype == "check" then
    if has_instance then return "✘", "counterexample found" end
    return "✔", "holds within scope"
  end
  if has_instance then return "✔", "satisfiable" end
  return "✘", "inconsistent (no instance within scope)"
end

local function receipt_summary_lines(outdir, receipt, elapsed_ms, filter_name)
  local lines = {}
  local commands = receipt.commands or {}
  local names = {}
  for name in pairs(commands) do
    if not filter_name or name == filter_name then
      table.insert(names, name)
    end
  end
  table.sort(names)
  if #names == 0 then
    return { string.format("▾ done (%.0f ms) — no command in receipt", elapsed_ms) }
  end
  for _, name in ipairs(names) do
    local cmd = commands[name]
    local mark, verdict = cmd_verdict(cmd)
    table.insert(lines, string.format("%s %s (%s): %s", mark, name, cmd.type or "run", verdict))
  end
  table.insert(lines, string.format("(%.0f ms total)", elapsed_ms))
  for _, name in ipairs(names) do
    local cmd = commands[name]
    for i, sol in ipairs(cmd.solution or {}) do
      if sol.instances and #sol.instances > 0 then
        local md = string.format("%s/%s-solution-%d.md", outdir, name, i - 1)
        if vim.fn.filereadable(md) == 1 then
          table.insert(lines, "")
          table.insert(lines, string.format("── %s · solution %d ──", name, i - 1))
          vim.list_extend(lines, vim.fn.readfile(md))
        end
      end
    end
  end
  return lines
end

local function summarize_basic(code, collected, elapsed_ms)
  if code ~= 0 then
    return { string.format("✘ exit %d (%.0f ms)", code, elapsed_ms) }
  end
  local sats, unsats = 0, 0
  for _, line in ipairs(collected) do
    if line:match("%f[%w]SAT%f[%W]") then sats = sats + 1
    elseif line:match("UNSAT") then unsats = unsats + 1 end
  end
  if sats + unsats == 0 then
    return { string.format("▾ done (%.0f ms)", elapsed_ms) }
  end
  return { string.format("✔ %d SAT, %d UNSAT (%.0f ms)", sats, unsats, elapsed_ms) }
end

local function start_job(args, file, header, on_done)
  if state.job then
    notify("a job is already running — :AlloyStop to cancel", vim.log.levels.WARN)
    return
  end
  local buf = ensure_output_buf()
  show_output_window(buf)
  reset_output(buf, header)

  local collected = {}
  local prev_blank = true -- header ends on a blank, so skip a leading blank too
  local function on_data(_, data)
    if not data then return end
    local cleaned = {}
    for _, line in ipairs(data) do
      line = line:gsub("\r$", ""):gsub("%s+$", "")
      table.insert(collected, line)
      if is_noise(line) then
        -- drop entirely
      elseif line == "" then
        if not prev_blank then
          table.insert(cleaned, "")
          prev_blank = true
        end
      else
        table.insert(cleaned, line)
        prev_blank = false
      end
    end
    if #cleaned == 0 then return end
    vim.schedule(function()
      if vim.api.nvim_buf_is_valid(buf) then
        write_lines(buf, cleaned)
      end
    end)
  end

  local started = vim.loop.hrtime()
  state.job = vim.fn.jobstart(args, {
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = on_data,
    on_stderr = on_data,
    on_exit = function(_, code)
      state.job = nil
      local elapsed_ms = (vim.loop.hrtime() - started) / 1e6
      vim.schedule(function()
        publish_diagnostics(file, collected)
        local lines = on_done and on_done(code, collected, elapsed_ms)
        if not lines then
          lines = summarize_basic(code, collected, elapsed_ms)
        end
        if lines and #lines > 0 and vim.api.nvim_buf_is_valid(buf) then
          local out = { "" }
          vim.list_extend(out, lines)
          write_lines(buf, out)
        end
      end)
    end,
  })

  if state.job <= 0 then
    state.job = nil
    notify("failed to start java process", vim.log.levels.ERROR)
  end
end

local function build_args(extra, file)
  local jar = resolved_jar()
  if not jar then return nil end
  local args = { M.config.java }
  vim.list_extend(args, M.config.java_args)
  table.insert(args, "-jar")
  table.insert(args, jar)
  vim.list_extend(args, M.config.exec_args)
  if extra then
    vim.list_extend(args, extra)
  end
  table.insert(args, file)
  return args
end

local function receipt_on_done(outdir, filter_name)
  return function(code, _collected, elapsed_ms)
    if code ~= 0 then
      return { string.format("✘ exit %d (%.0f ms)", code, elapsed_ms) }
    end
    local receipt = read_receipt(outdir)
    if not receipt then
      return { string.format("▾ done (%.0f ms) — no receipt.json found", elapsed_ms) }
    end
    return receipt_summary_lines(outdir, receipt, elapsed_ms, filter_name)
  end
end

function M.run(file_arg)
  local file = current_file(file_arg)
  if not file then return end
  local outdir = exec_outdir(file)
  local args = build_args({ "-o", outdir }, file)
  if not args then return end
  start_job(args, file, {
    "▸ " .. vim.fn.fnamemodify(file, ":t") .. " (all commands)",
    "",
  }, receipt_on_done(outdir, nil))
end

function M.run_command(name)
  if not name or name == "" then
    notify("usage: :AlloyCheck <name>", vim.log.levels.ERROR)
    return
  end
  local file = current_file()
  if not file then return end
  local outdir = exec_outdir(file)
  local args = build_args({ "-c", name, "-o", outdir }, file)
  if not args then return end
  start_job(args, file, {
    "▸ " .. name,
    "",
  }, receipt_on_done(outdir, name))
end

function M.stop()
  if not state.job then
    notify("no running job")
    return
  end
  vim.fn.jobstop(state.job)
  state.job = nil
  notify("stopped")
end

local function viz_launcher_path()
  if M.config.viz_launcher then return M.config.viz_launcher end
  local src = debug.getinfo(1, "S").source:sub(2) -- strip leading @
  local plugin_root = vim.fn.fnamemodify(src, ":h:h:h")
  return plugin_root .. "/launcher/AlloyViz.java"
end

local function viz_cache_dir()
  return M.config.viz_cache_dir or (vim.fn.stdpath("cache") .. "/alloy")
end

function M.viz(name)
  if not name or name == "" then
    notify("usage: :AlloyViz <name>", vim.log.levels.ERROR)
    return
  end
  local jar = resolved_jar()
  if not jar then return end
  local file = current_file()
  if not file then return end

  local outdir = viz_cache_dir() .. "/" .. name
  vim.fn.mkdir(outdir, "p")
  local args = build_args({ "-c", name, "-t", "xml", "-o", outdir }, file)
  if not args then return end

  start_job(args, file, { "▸ " .. name .. " (viz)", "" }, function(code)
    if code ~= 0 then return end
    local xmls = vim.fn.glob(outdir .. "/*.xml", false, true)
    if #xmls == 0 then
      notify("no instance to visualize (UNSAT or no run)", vim.log.levels.WARN)
      return
    end
    table.sort(xmls)
    local launcher = viz_launcher_path()
    if vim.fn.filereadable(launcher) == 0 then
      notify("viz launcher missing: " .. launcher, vim.log.levels.ERROR)
      return
    end
    local viz_args = { M.config.java }
    vim.list_extend(viz_args, M.config.java_args)
    table.insert(viz_args, "-cp")
    table.insert(viz_args, jar)
    table.insert(viz_args, launcher)
    table.insert(viz_args, xmls[1])
    vim.fn.jobstart(viz_args, { detach = true })
    notify("opened visualizer on " .. vim.fn.fnamemodify(xmls[1], ":t"))
  end)
end

function M.open_gui()
  local jar = resolved_jar()
  if not jar then return end
  local args = { M.config.java }
  vim.list_extend(args, M.config.java_args)
  table.insert(args, "-jar")
  table.insert(args, jar)
  vim.list_extend(args, M.config.gui_args)
  local file = vim.api.nvim_buf_get_name(0)
  if file ~= "" then
    table.insert(args, file)
  end
  vim.fn.jobstart(args, { detach = true })
  notify("launched alloy gui")
end

function M.command_names()
  local names = {}
  local seen = {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    for kw, name in line:gmatch("(run%s+)([%w_]+)") do
      if kw and not seen[name] then seen[name] = true; table.insert(names, name) end
    end
    for kw, name in line:gmatch("(check%s+)([%w_]+)") do
      if kw and not seen[name] then seen[name] = true; table.insert(names, name) end
    end
  end
  return names
end

function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", defaults, opts or {})
  vim.o.expandtab = true
  vim.o.tabstop = 4
  vim.o.shiftwidth = 4
end

return M
