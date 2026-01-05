-- Trim trailing whitespace from the current file
vim.api.nvim_create_user_command(
  'TrimWhitespace',
  function()
    local save_search = vim.fn.getreg('/')
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.setreg('/', save_search)
  end,
  {}
)

-- Toggle spell checking in the current buffer
vim.api.nvim_create_user_command(
  'ToggleSpell',
  function()
    vim.wo.spell = not vim.wo.spell
  end,
  {}
)

-- Toggle text wrapping in the current buffer
vim.api.nvim_create_user_command(
  'ToggleWrap',
  function()
    vim.wo.wrap = not vim.wo.wrap
  end,
  {}
)

-- Project-wide search without moving from the current buffer
vim.api.nvim_create_user_command(
    'PGrep', 'silent grep! <args> | copen', { nargs = 1 }
)

-- Toggle relative line numbers
vim.api.nvim_create_user_command(
  'ToggleRelNum',
  function()
    vim.wo.relativenumber = not vim.wo.relativenumber
  end,
  {}
)

-- Replace all occurrences of a term in the document
vim.api.nvim_create_user_command(
  'ReplaceAll',
  function(opts)
    local search = opts.fargs[1]
    local replace = opts.fargs[2] or ''
    vim.cmd(string.format("%%s/%s/%s/g", vim.fn.escape(search, "/\\"), vim.fn.escape(replace, "/\\")))
  end,
  { nargs = '+' }
)

-- Quick diff view
vim.api.nvim_create_user_command(
  'ToggleDiff',
  function()
    vim.wo.diff = not vim.wo.diff
  end,
  {}
)

-- Delete all empty lines
vim.api.nvim_create_user_command(
  'DelEmptyLines',
  function()
    vim.cmd([[%s/^\n//]])
  end,
  {}
)
