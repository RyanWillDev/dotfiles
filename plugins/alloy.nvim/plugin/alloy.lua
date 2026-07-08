if vim.g.loaded_alloy_nvim then
  return
end
vim.g.loaded_alloy_nvim = true

local function alloy()
  return require("alloy")
end

vim.api.nvim_create_user_command("AlloyRun", function(opts)
  alloy().run(opts.fargs[1])
end, {
  nargs = "?",
  desc = "Run all commands in the current Alloy file (or a given file path)",
})

vim.api.nvim_create_user_command("AlloyCheck", function(opts)
  alloy().run_command(opts.fargs[1])
end, {
  nargs = 1,
  desc = "Run a named Alloy command (run/check/assert) from the current file",
  complete = function()
    return alloy().command_names()
  end,
})

vim.api.nvim_create_user_command("AlloyStop", function()
  alloy().stop()
end, { desc = "Cancel a running Alloy job" })

vim.api.nvim_create_user_command("AlloyOpenGui", function()
  alloy().open_gui()
end, { desc = "Open the Alloy Swing GUI on the current file" })

vim.api.nvim_create_user_command("AlloyViz", function(opts)
  alloy().viz(opts.fargs[1])
end, {
  nargs = 1,
  desc = "Run a named Alloy command and open the Swing visualizer on the first instance",
  complete = function()
    return alloy().command_names()
  end,
})
