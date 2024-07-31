--* configurations
vim.o.number = true
vim.o.relativenumber = true
vim.o.clipboard = 'unnamedplus'

vim.api.nvim_create_autocmd({ 'BufReadPost' }, {
  pattern = { '*' },
  callback = function()
    vim.api.nvim_exec('silent! normal! g`"zv', false)
  end,
})

--* special characters
vim.keymap.set('n', '<C-Left>', ':bprevious<CR>')
vim.keymap.set('n', '<C-Right>', ':bnext<CR>')
-- vim.keymap.set('n', '<C-j>', '<C-w>j')
-- vim.keymap.set('n', '<C-k>', '<C-w>k')
-- vim.keymap.set('n', '<C-l>', '<C-w>l')
-- vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('v', '<Tab>', ':lua ToggleComments()<CR>')
vim.keymap.set('n', '<leader>.', ':Telescope builtin<CR>')
vim.keymap.set('n', '<leader>,', ":lua require('telescope.builtin').find_files({ cwd = vim.fn.expand('%:p:h') })<CR>")
--vim.keymap.set('n', '<leader><leader>.', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader><leader>.', ':Telescope keymaps<CR>')
vim.keymap.set('n', '<leader><leader><leader>.', ':Telescope help_tags<CR>')
-- vim.keymap.set('n', '<leader><', ':lua require("").goto_previous_outline()<CR>', { noremap = true, silent = true })
-- vim.keymap.set('n', '<leader>>', ':lua require("a").goto_next_outline()<CR>', { noremap = true, silent = true })
-- vim.keymap.set('n', '<leader><Left>', ':lua require("a").goto_previous_outline()<CR>', { noremap = true, silent = true })
-- vim.keymap.set('n', '<leader><Right>', ':lua require("a").goto_next_outline()<CR>', { noremap = true, silent = true })
vim.keymap.set('n', '<leader><leader>1', ':only<CR>')
vim.keymap.set('n', '<leader><leader>/', ':Telescope live_grep<CR>')
vim.keymap.set('n', '<Down>', 'Lzt')
vim.keymap.set('n', '<Up>', 'Hzb')

vim.keymap.set('n', '<M-Left>', '<C-W>5>')
vim.keymap.set('n', '<M-Right>', '<C-W>5<')
vim.keymap.set('n', '<M-Up>', '<C-W>+')
vim.keymap.set('n', '<M-Down>', '<C-W>-')

vim.keymap.set('n', ',r', ':Telescope registers<CR>')
vim.keymap.set('n', ',m', ':Telescope marks<CR>')

-- local gt_dirs = require 'gt_directories'
vim.keymap.set('n', ',,', ':lua FindAndOpenGT_Directories()<CR>')

--* a
vim.keymap.set('n', '<leader>a', ':e `dirname %`<CR>')

--* b
vim.keymap.set('n', '<leader>bb', ':Telescope buffers<CR>')
vim.keymap.set('n', '<leader>bg', ':Telescope git_status<CR>')
vim.keymap.set('n', '<leader>bt', ':Telescope oldfiles<CR>')
vim.keymap.set('n', '<leader>bp', ":lua require('telescope.builtin').git_files({ cwd = vim.fn.expand('%:p:h') })<CR>")
vim.keymap.set('n', '<leader>bk', ':bprevious<CR>:bdelete #<CR>')
vim.keymap.set('n', '<leader>b+', ':!chmod +x %<CR>')
vim.keymap.set('n', '<leader>bl', ':lua SystemLocate()<CR>')

--* c
vim.keymap.set('n', '<leader>cc', ':lua ExecuteOnTerminal("I")<CR>')
vim.keymap.set('v', '<leader>cc', ':lua ExecuteOnTerminal("V")<CR>')

--* e
vim.keymap.set('n', '<leader>ee', ':vsplit | terminal<CR>')

--* f
vim.keymap.set('n', '<leader>fvd', '<cmd>edit ' .. vim.fn.stdpath 'config' .. '/init.lua<CR>')
vim.keymap.set('n', '<leader>fvm', '<cmd>edit ' .. vim.fn.stdpath 'config' .. '/lua/myconfig.lua<CR>')
vim.keymap.set('n', '<leader>fvr', '<cmd>edit ' .. vim.fn.stdpath 'config' .. '/README.md<CR>')

vim.keymap.set('n', '<leader>fed', '<cmd>edit ' .. os.getenv 'HOME' .. '/.doom.d/config.el<CR>')
vim.keymap.set('n', '<leader>fei', '<cmd>edit ' .. os.getenv 'HOME' .. '/.doom.d/init.el<CR>')
vim.keymap.set('n', '<leader>fem', '<cmd>edit ' .. os.getenv 'HOME' .. '/.doom.d/elisp.el<CR>')
vim.keymap.set('n', '<leader>fep', '<cmd>edit ' .. os.getenv 'HOME' .. '/.doom.d/packages.el<CR>')
vim.keymap.set('n', '<leader>fer', '<cmd>edit ' .. os.getenv 'HOME' .. '/.doom.d/README.md<CR>')

--* q
vim.keymap.set('n', '<leader>qr', ':lua ReloadConfig()<CR>')

--* w
vim.keymap.set('n', '<leader>wh', ':split<CR>')
vim.keymap.set('n', '<leader>wv', ':vsplit<CR>')
vim.keymap.set('n', '<leader>wk', ':q<CR>')

--* functions
--** toggleComments
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

--** SystemLocate
function SystemLocate()
  local search_query = vim.fn.input 'System Locate Search: '
  local results = vim.fn.systemlist('locate ' .. search_query)
  vim.fn.setqflist({}, ' ', { title = 'Search Results', items = vim.tbl_map(function(item)
    return { filename = item }
  end, results) })
  vim.cmd 'copen'
end

--** ReloadConfig
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

--** ExecuteOnTerminal
function ExecuteOnTerminal(type)
  local ft = vim.bo.filetype -- Get the current buffer's filetype
  local file_path = '/tmp/file.' .. (ft == 'javascript' and 'js' or ft)
  local file_path_mjs = '/tmp/file.mjs'

  -- Write to the specific file based on type
  vim.cmd(type == 'V' and ("'<,'>w! " .. file_path) or (':w! ' .. file_path))

  if ft == 'javascript' then
    -- Array of commands to be executed
    local cmds = {
      'sed -i "/global.get/d" ' .. file_path,
      'sed -i "/node.status/d" ' .. file_path,
      -- additional sed commands
    }

    -- Execute commands
    for _, cmd in ipairs(cmds) do
      os.execute(cmd)
    end

    -- JSON and file handling
    if os.execute 'jq -e . ~/payload >/dev/null 2>&1' == 0 then
      os.execute('sed -i "6i let global = new Map();" ' .. file_path)
      -- Correct handling of single and double quotes in os.execute
    end

    local language = io.popen(
      'file="'
        .. file_path
        .. '"; flag="false"; while read line; do if [[ "$line" =~ ^import.*$ ]]; then flag="true"; fi; done < $file; if [[ "$flag" == "true" ]]; then echo "mjs"; else echo "js"; fi'
    )
    local result = language:read '*a'
    language:close()

    if result:match 'mjs' then
      os.execute('cp ' .. file_path .. ' ' .. file_path_mjs)
      file_path = file_path_mjs
    end

    vim.cmd(':vert sp | terminal env NODE_PATH=/home/rafael/node_modules node ' .. file_path)
    os.execute 'xdotool key "Control_L+e"; xdotool type r'
  end
end

--* firenvim

---- Check if running in Neovim and started by Firenvim
--if vim.fn.has 'nvim' == 1 and vim.fn.exists 'g:started_by_firenvim' == 1 then
--  vim.fn.system 'notify-send "Hello" "This is a notification from Neovim!"'
--  -- vim.g.UltiSnipsExpandTrigger = "<C-l>"
--  --vim.cmd 'colorscheme nordic'
--  vim.cmd 'set guifont=monospace:h8'
--
--  -- Auto command settings
--  local autocmds = {
--    -- Buffer enter patterns for various sites and filetype settings
--    { 'BufEnter', 'localhost_*', 'set filetype=javascript' },
--    { 'BufEnter', 'github.com_*.py', 'set filetype=python' },
--    { 'BufEnter', 'github.com_*.bash', 'set filetype=sh' },
--    { 'BufEnter', 'github.com_*.js', 'set filetype=javascript' },
--    { 'BufEnter', 'gitlab.com_*.py', 'set filetype=python' },
--    { 'BufEnter', 'gitlab.com_*.bash', 'set filetype=sh' },
--    { 'BufEnter', 'gitlab.com_*.js', 'set filetype=javascript' },
--    { 'BufEnter', 'w3schools.com_*', 'set filetype=javascript' },
--    { 'BufEnter', '*', 'set filetype=javascript' },
--    { 'BufRead,BufNewFile', '*.txt', 'set filetype=bash' },
--  }
--
--  -- Apply autocmds
--  for _, autocmd in ipairs(autocmds) do
--    vim.api.nvim_create_autocmd(autocmd[1], { pattern = autocmd[2], command = autocmd[3] })
--  end
--end
--
---- Configuration for Firenvim
--vim.g.firenvim_config = {
--  localSettings = {
--    ['.*'] = {
--      cmdline = 'neovim',
--      selector = 'textarea, div[role="textbox"]',
--      priority = 0,
--      takeover = 'never',
--    },
--  },
--}
--
---- Function to check if Firenvim is active
--function IsFirenvimActive(event)
--  if vim.fn.exists '*nvim_get_chan_info' == 0 then
--    return false
--  end
--  local ui = vim.fn.nvim_get_chan_info(event.chan)
--  if ui.client and ui.client.name:find 'Firenvim' then
--    return true
--  end
--  return false
--end

--* git files

local Job = require 'plenary.job'
local telescope = require 'telescope.builtin'

function FindAndOpenGT_Directories()
  -- Define the home directory
  local home = '/home/Dados/Github/'

  -- Function to find all directories with a .git subdirectory, ignoring specified directories
  local function find_gt_directories()
    local result = {}
    Job:new({
      command = 'find',
      args = {
        home,
        "-type d \\( -name node_modules -o -name volumes -o -name '.*' ! -name '.git' \\) -prune -o -type d -name .git -exec dirname {} \\;",
      },
      on_exit = function(j, return_val)
        if return_val == 0 then
          result = j:result()
        end
      end,
    }):sync()
    return result
  end

  -- Find the directories
  local directories = find_gt_directories()

  -- Launch Telescope with the found directories
  telescope.find_files {
    prompt_title = 'GT Directories',
    cwd = home,
    find_command = { 'echo', table.concat(directories, '\n') },
    attach_mappings = function(prompt_bufnr, map)
      local function open_dired(selection)
        vim.cmd('edit ' .. selection)
      end
      map('i', '<CR>', function(prompt_bufnr)
        local selection = require('telescope.actions.state').get_selected_entry()
        open_dired(selection.value)
      end)
      return true
    end,
  }
end
