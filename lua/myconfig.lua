-- Set some basic options
vim.o.number = true
vim.o.relativenumber = true
vim.o.clipboard = 'unnamedplus'

-- Map 'SPC a' to 'Ntree' command
-- vim.keymap.set('n', '<leader>a', ':Ntree<CR>', {noremap = true, silent = true})
vim.keymap.set('n', '<leader>a', ':Ntree<CR>')

--* Set up mappings for various functionalities
vim.keymap.set('n', '<leader>bb', ':Telescope buffers<CR>')
vim.keymap.set('n', '<leader>bt', ':Telescope oldfiles<CR>')
vim.keymap.set('n', '<leader>bp', ':Telescope find_files<CR>')
vim.keymap.set('n', '<leader>bk', ':bprevious<CR>:bdelete #<CR>')
vim.keymap.set('n', '<leader>b+', ':!chmod +x %<CR>')

-- e
vim.keymap.set('n', '<leader>ee', ':vsplit | terminal<CR>')

vim.keymap.set('n', '<leader>bl', ':lua SystemLocate()<CR>')

-- Map this function to a key, for example <leader>rr
vim.keymap.set('n', '<leader>qr', ':lua ReloadConfig()<CR>')

-- Key mappings for opening specific files
vim.keymap.set('n', '<leader>fed', '<cmd>edit ' .. vim.fn.stdpath 'config' .. '/init.lua<CR>')
vim.keymap.set('n', '<leader>fem', '<cmd>edit ' .. vim.fn.stdpath 'config' .. '/lua/myconfig.lua<CR>')
vim.keymap.set('n', '<leader>fer', '<cmd>edit ' .. vim.fn.stdpath 'config' .. '/README.md<CR>')

-- Define key mappings in normal mode
vim.keymap.set('n', '<C-Left>', ':bprevious<CR>')
vim.keymap.set('n', '<C-Right>', ':bnext<CR>')

-- Define key mappings for window movement
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')
vim.keymap.set('n', '<C-h>', '<C-w>h')

-- Define key mappings for splitting windows
vim.keymap.set('n', '<leader>wh', ':split<CR>')
vim.keymap.set('n', '<leader>wv', ':vsplit<CR>')
vim.keymap.set('n', '<leader>wk', ':q<CR>')

-- Map the function to Tab key in visual mode
vim.keymap.set('v', '<Tab>', ':lua ToggleComments()<CR>')

-- special characters
vim.keymap.set('n', '<leader>.', ':Telescope commands<CR>')
vim.keymap.set('n', '<leader>,', ':lua require("a").root_reopen_file()<CR>')
vim.keymap.set('n', '<leader><leader>.', ':Telescope help_tags<CR>')
-- vim.keymap.set('n', '<leader><', ':lua require("a").goto_previous_outline()<CR>', { noremap = true, silent = true })
-- vim.keymap.set('n', '<leader>>', ':lua require("a").goto_next_outline()<CR>', { noremap = true, silent = true })
-- vim.keymap.set('n', '<leader><Left>', ':lua require("a").goto_previous_outline()<CR>', { noremap = true, silent = true })
-- vim.keymap.set('n', '<leader><Right>', ':lua require("a").goto_next_outline()<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader><leader>1', ':only<CR>')
vim.keymap.set('n', '<leader><leader>/', ':Telescope live_grep<CR>')

-- Set key mappings directly
vim.keymap.set('n', '<Down>', 'Lzt')
vim.keymap.set('n', '<Up>', 'Hzb')

vim.keymap.set('n', '<M-Left>', '<C-W>5>')
vim.keymap.set('n', '<M-Right>', '<C-W>5<')
vim.keymap.set('n', '<M-Up>', '<C-W>+')
vim.keymap.set('n', '<M-Down>', '<C-W>-')

function ToggleComments()
  -- Get the comment character based on filetype
  local commentstring = vim.bo.commentstring
  local commentChar = string.gsub(commentstring, '%%s.*', '')

  -- Fallback for specific file syntax
  local syntax = vim.bo.syntax
  if syntax == 'python' or syntax == 'sh' or syntax == 'yaml' then
    commentChar = '#'
  elseif syntax == 'javascript' then
    commentChar = '//'
  elseif syntax == 'vim' then
    commentChar = '"'
  elseif syntax == 'lua' then
    commentChar = '--'
  end

  -- Add a space for readability, if needed
  if not string.match(commentChar, '%s$') then
    commentChar = commentChar .. ' '
  end

  -- Escape the comment character for regex
  local escapedCommentChar = vim.pesc(commentChar)

  -- Get the range of selected lines
  local startLine, endLine = unpack(vim.fn.getpos "'<", 2, 3)
  local endLine = unpack(vim.fn.getpos "'>", 2, 3)

  -- Iterate over the selected lines
  for i = startLine, endLine do
    local line = vim.fn.getline(i)

    -- Build a regex pattern to check if the line is already commented
    local commentPattern = '^%s*' .. escapedCommentChar

    -- Check if the line is already commented
    if string.match(line, commentPattern) then
      -- Uncomment the line
      local newLine = string.gsub(line, commentPattern, '')
      vim.fn.setline(i, newLine)
    else
      -- Comment the line
      local newLine = commentChar .. line
      vim.fn.setline(i, newLine)
    end
  end
end

function SystemLocate()
  local search_query = vim.fn.input 'System Locate Search: '
  local results = vim.fn.systemlist('locate ' .. search_query)
  vim.fn.setqflist({}, ' ', { title = 'Search Results', items = vim.tbl_map(function(item)
    return { filename = item }
  end, results) })
  vim.cmd 'copen'
end

function ReloadConfig()
  -- Unload the Lua namespace which includes your configs
  for name, _ in pairs(package.loaded) do
    if name:match '^config' then
      package.loaded[name] = nil
    end
  end

  -- Reload the init file, or another specific configuration file
  dofile(vim.env.MYVIMRC) -- Assuming MYVIMRC points to your init.lua

  -- Provide feedback that the configuration has been reloaded
  print 'Configuration reloaded!'
end
