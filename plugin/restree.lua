if vim.g.loaded_restree then
  return
end
vim.g.loaded_restree = true

local function run_restree(args)
  local filepath = vim.fn.expand("%:p")
  local show_headers = string.find(args, "headers") ~= nil
  local use_jq = string.find(args, "jq") ~= nil

  -- Create the output buffer
  vim.cmd("vsplit | wincmd l | enew")
  local buf = vim.api.nvim_get_current_buf()

  -- Buffer boilerplate
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].swapfile = false
  vim.keymap.set("n", "q", "<cmd>q<CR>", { buffer = buf, silent = true })

  -- Build the shell command string
  -- We use sh -c to handle the pipe to jq if needed
  local cmd_str = "restree run -k -v " .. vim.fn.shellescape(filepath)
  if use_jq then
    cmd_str = cmd_str .. " | jq"
    vim.bo[buf].filetype = "json"
  end

  vim.system({ "sh", "-c", cmd_str }, { text = true }, function(res)
    vim.schedule(function()
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end

      local lines = {}

      -- Handle Headers (from stderr)
      if show_headers and res.stderr and res.stderr ~= "" then
        vim.list_extend(lines, vim.split(res.stderr, "\n", { plain = true }))
        table.insert(lines, "") -- Spacer
      end

      if res.stdout and res.stdout ~= "" then
        vim.list_extend(lines, vim.split(res.stdout, "\n", { plain = true }))
      end

      -- Handle Errors (if exit code isn't 0 and we haven't shown stderr yet)
      if res.code ~= 0 and not show_headers then
        table.insert(lines, "--- ERROR (Exit Code " .. res.code .. ") ---")
        vim.list_extend(lines, vim.split(res.stderr or "Unknown Error", "\n", { plain = true }))
      end

      vim.bo[buf].modifiable = true
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.bo[buf].modifiable = false
    end)
  end)
end

vim.api.nvim_create_user_command("Restree", function(opts)
  run_restree(opts.args)
end, { nargs = "*" })

-- Keybindings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "http",
  callback = function()
    -- Quick run (Body only)
    vim.keymap.set("n", "<leader>rr", ":Restree<CR>", { buffer = true, silent = true })
    -- Run with JQ
    vim.keymap.set("n", "<leader>rj", ":Restree jq<CR>", { buffer = true, silent = true })
    -- Run with Headers + JQ
    vim.keymap.set("n", "<leader>ra", ":Restree jq headers<CR>", { buffer = true, silent = true })
  end,
})
