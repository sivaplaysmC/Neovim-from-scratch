

local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)


-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- Move text up and down
keymap("n", "<A-j>", "<Esc>:m .+1<CR>==gi", opts)
keymap("n", "<A-k>", "<Esc>:m .-2<CR>==gi", opts)

-- Insert --
-- Press jk fast to enter
keymap("i", "jk", "<ESC>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
keymap("x", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Terminal --
-- Better terminal navigation
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

keymap("n" , "<leader>w" ,"<C-w>" , opts);

local telescope_theme = require("telescope.themes").get_ivy{layout_config = {height = 15} , results_title = false }
local telescope = require("telescope.builtin");

vim.keymap.set('n' , '<leader>ff' ,function () telescope.find_files(telescope_theme) end, opts)
vim.keymap.set('n' , '<leader>fo' ,function () telescope.oldfiles(telescope_theme) end, opts)
vim.keymap.set('n' , '<leader>fd' ,function () telescope.fd(telescope_theme) end, opts)
vim.keymap.set('n' , '<leader>fr' ,function () telescope.live_grep(telescope_theme) end, opts)


vim.keymap.set('n' , '<leader>bk' ,":bd!<CR>", opts)
vim.keymap.set('n' , '<leader>bb' ,function () telescope.buffers(telescope_theme) end, opts)
vim.keymap.set('n' , '<leader>bs' ,function () telescope.current_buffer_fuzzy_find(telescope_theme) end, opts)



local function get_line_starts(winid)
  local wininfo =  vim.fn.getwininfo(winid)[1]
  local cur_line = vim.fn.line('.')
  -- local cur_colm = vim.fn.col('.')

  -- Get targets.
  local targets = {}
  local lnum = wininfo.topline
  while lnum <= wininfo.botline do
    local fold_end = vim.fn.foldclosedend(lnum)
    -- Skip folded ranges.
    if fold_end ~= -1 then
      lnum = fold_end + 1
    else
      if lnum ~= cur_line then table.insert(targets, { pos = { lnum, 1 } }) end
      lnum = lnum + 1
    end
  end
  -- Sort them by vertical screen distance from cursor.
  local cur_screen_row = vim.fn.screenpos(winid, cur_line, 5)['row']
  local function screen_rows_from_cur(t)
    local t_screen_row = vim.fn.screenpos(winid, t.pos[1], t.pos[2])['row']
    return math.abs(cur_screen_row - t_screen_row)
  end
  table.sort(targets, function (t1, t2)
    return screen_rows_from_cur(t1) < screen_rows_from_cur(t2)
  end)

  if #targets >= 1 then
    return targets
  end
end

local function get_line_starts_below(winid)
  local wininfo =  vim.fn.getwininfo(winid)[1]
  local cur_line = vim.fn.line('.')
  -- local cur_colm = vim.fn.col('.')

  -- Get targets.
  local targets = {}
  local lnum = cur_line
  while lnum <= wininfo.botline do
    local fold_end = vim.fn.foldclosedend(lnum)
    -- Skip folded ranges.
    if fold_end ~= -1 then
      lnum = fold_end + 1
    else
      if lnum ~= cur_line then table.insert(targets, { pos = { lnum, 1 } }) end
      lnum = lnum + 1
    end
  end
  -- Sort them by vertical screen distance from cursor.
  local cur_screen_row = vim.fn.screenpos(winid, cur_line, 5)['row']
  local function screen_rows_from_cur(t)
    local t_screen_row = vim.fn.screenpos(winid, t.pos[1], t.pos[2])['row']
    return math.abs(cur_screen_row - t_screen_row)
  end
  table.sort(targets, function (t1, t2)
    return screen_rows_from_cur(t1) < screen_rows_from_cur(t2)
  end)

  if #targets >= 1 then
    return targets
  end
end



local function get_line_starts_above(winid)
  local wininfo =  vim.fn.getwininfo(winid)[1]
  local cur_line = vim.fn.line('.')
  -- local cur_colm = vim.fn.col('.')

  -- Get targets.
  local targets = {}
  local lnum = wininfo.topline
  while lnum <= cur_line do
    local fold_end = vim.fn.foldclosedend(lnum)
    -- Skip folded ranges.
    if fold_end ~= -1 then
      lnum = fold_end + 1
    else
      if lnum ~= cur_line then table.insert(targets, { pos = { lnum, 1 } }) end
      lnum = lnum + 1
    end
  end
  -- Sort them by vertical screen distance from cursor.
  local cur_screen_row = vim.fn.screenpos(winid, cur_line, 5)['row']
  local function screen_rows_from_cur(t)
    local t_screen_row = vim.fn.screenpos(winid, t.pos[1], t.pos[2])['row']
    return math.abs(cur_screen_row - t_screen_row)
  end
  table.sort(targets, function (t1, t2)
    return screen_rows_from_cur(t1) < screen_rows_from_cur(t2)
  end)

  if #targets >= 1 then
    return targets
  end
end



-- Usage:
local function leap_to_line( top )
  local winid = vim.api.nvim_get_current_win()
  local mode = vim.api.nvim_get_mode().mode;
  local old_col = vim.fn.col('.');
  if mode == 'n' or mode == 'v' then
    -- local operator = vim.fn.execute('echo v:operator')
  else
    vim.api.nvim_command('normal! V');
  end
  local targets = get_line_starts_below(winid);
  if top == 1 then
    targets = get_line_starts_above(winid)
  end
  require('leap').leap {
    target_windows = { winid },
    targets = targets ,
  }
  if mode == 'v' or mode == 'n' then
    local cur_line = vim.fn.line('.');
    vim.api.nvim_win_set_cursor(0 , {cur_line , old_col - 1})
  end


end


local function leap_to_line_only()
  local winid = vim.api.nvim_get_current_win()
  local mode = vim.api.nvim_get_mode().mode;
  local old_col = vim.fn.col('.');
  if mode == 'n' or mode == 'v' then
    -- local operator = vim.fn.execute('echo v:operator')
  else
    vim.api.nvim_command('normal! V');
  end
  local targets = get_line_starts(winid);
  require('leap').leap {
    target_windows = { winid },
    targets = targets ,
  }
  if mode == 'v' or mode == 'n' then
    local cur_line = vim.fn.line('.');
    vim.api.nvim_win_set_cursor(0 , {cur_line , old_col - 1})
  end


end





keymap = vim.keymap.set
opts = { noremap = true, silent = true }


keymap("n", "gj", function () leap_to_line(0) end, opts)
keymap("n", "gk", function () leap_to_line(1) end, opts)
keymap("n", "gl", function () leap_to_line_only() end, opts)


keymap("x", "gj", function () leap_to_line(0) end, opts)
keymap("x", "gk", function () leap_to_line(1) end, opts)
keymap("x", "gl", function () leap_to_line_only() end, opts)

keymap("o", "gj", function () leap_to_line(0) end, opts)
keymap("o", "gk", function () leap_to_line(1) end, opts)
keymap("o", "gl", function () leap_to_line_only() end, opts)


-- The below settings make Leap's highlighting closer to what you've been
-- used to in Lightspeed.

vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Comment' }) -- or some grey
vim.api.nvim_set_hl(0, 'LeapMatch', {
  -- For light themes, set to 'black' or similar.
  fg = 'white', bold = true, nocombine = true,
})
-- Of course, specify some nicer shades instead of the default "red" and "blue".
vim.api.nvim_set_hl(0, 'LeapLabelPrimary', {
  fg = 'blue', bold = true, nocombine = true,
})
vim.api.nvim_set_hl(0, 'LeapLabelSecondary', {
  fg = 'green', bold = true, nocombine = true,
})
-- Try it without this setting first, you might find you don't even miss it.
-- require('leap').opts.highlight_unlabeled_phase_one_targets = true

