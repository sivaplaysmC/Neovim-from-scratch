require "user.options"
require "user.keymaps"
require "user.plugins"
require "user.colorscheme"
require "user.cmp"
require "user.lspc"
require "user.telescope"
require "user.treesitter"
require "user.autopairs"
require "user.comment"
require "user.statusline"
require "user.buffer_line"


require"surround".setup {mappings_style = "surround"}
require("trouble").setup{
  position = "right"
}

require'hop'.setup {
  keys = 'asdfghjkl;',
}

local hop = require('hop')
local directions = require('hop.hint').HintDirection

function Trial()
  -- vim.api.nvim_command('normal! d');
  print(vim.api.nvim_get_mode().mode)
  -- print(vim.api.nvim_get_mode().mode)
end

local function leap_to_line(top)
  local winid = vim.api.nvim_get_current_win()
  local mode = vim.api.nvim_get_mode().mode;
  local old_col = vim.fn.col('.');
  local old_line = vim.fn.line('.');

  local command = hop.hint_lines


  print(mode)
  if mode == 'no' or mode == '<or>' then
    vim.api.nvim_command('normal! V');
  elseif mode == '' then
    command = hop.hint_vertical
  end
  if top == 1 then
    command { direction = directions.BEFORE_CURSOR }
  else
    command { direction = directions.AFTER_CURSOR }
  end
end


local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }
keymap("v", "gj", function() leap_to_line(0) end, opts)
keymap("n", "gj", function() leap_to_line(0) end, opts)
keymap("o", "gj", function() leap_to_line(0) end, opts)


keymap("v", "gk", function() leap_to_line(1) end, opts)
keymap("n", "gk", function() leap_to_line(1) end, opts)
keymap("o", "gk", function() leap_to_line(1) end, opts)

keymap("n", "g;", function() hop.hint_words() end, opts)

keymap({"n" , "v" , "o"}, "x", "<CMD>:HopChar2AC<CR>", opts)
keymap({"n" , "v" , "o"}, "X", "<CMD>:HopChar2BC<CR>", opts)


vim.cmd[[let g:Lf_WindowHeight=15]]
vim.cmd[[ 

    let g:Lf_WildIgnore = {
            \ 'dir': ["node_modules" , '.git'],
            \ 'file': []
            \}

]]

vim.cmd [[

    let g:Lf_PreviewResult = {
            \ 'File': 0,
            \ 'Buffer': 0,
            \ 'Mru': 0,
            \ 'Tag': 0,
            \ 'BufTag': 0,
            \ 'Function': 0,
            \ 'Line': 0,
            \ 'Colorscheme': 0,
            \ 'Rg': 0,
            \ 'Gtags': 0
            \}
]]



local function reverseArray(array)
  local reversedTbl = {}
  local n = #array

  for i = 1, n do
    reversedTbl[i] = array[n - i + 1]
  end
  return reversedTbl
end


local function copyFirstNTerms(array, n)
  local newArray = {}
  local startIndex = 1

  for i = startIndex, n do
    table.insert(newArray, array[i])
  end

  return newArray
end


local function getIndex(array, value)
  for k, v in pairs(array) do
    if v == value then
      return k
    end
  end
  return nil
end


local function isInTable(value, tbl)
  

  for _, v in ipairs(tbl) do
    if v == value then
      return true
    end
  end
  return false
end

local function getchar(str)
  return str .. vim.fn.nr2char(vim.fn.getchar())
end

local function getJumpOffset(candidates)
  local char = ""
  local ok = true ;
  local pos = 0


  -- 1181 , 1139
  while #char < 2 do

    ok , char = pcall( getchar , char);
    if not ok then return 0 end

    if isInTable(char, candidates) then
      pos = getIndex(candidates, char)
      break
    end
  end
  return pos
end


local function create_window(buffer, start_line, count)

  local win_id = vim.api.nvim_open_win(buffer, false, {
    relative = 'win',
    row = start_line,
    col = 0,
    width = 2,
    height = math.abs(count),
    style = 'minimal',
  })


  -- Get the current window configuration
  local config = vim.api.nvim_win_get_config(win_id)

  -- Set the z-index to a high value (e.g., 99)
  config.zindex = 99

  -- Update the window configuration
  vim.api.nvim_win_set_config(win_id, config)

  -- Customize the appearance of the floating window
  vim.api.nvim_win_set_option(win_id, 'winhighlight', 'Normal:FloatBorder')
  -- vim.api.nvim_win_set_option(win_id, 'winblend', 70)

  -- force redraw to show the window
  vim.api.nvim_command('redraw')

  return win_id
end

local function create_jump_buffer(text, count, direction)
  local buffer = vim.api.nvim_create_buf(false, true)
  local new_arr = copyFirstNTerms(text, count)
  if direction == "top" then
    new_arr = reverseArray(new_arr)
  end
  vim.api.nvim_buf_set_lines(buffer, 0, -1, true, new_arr)


  -- Define the syntax group for the first character
  vim.cmd("syntax match FirstChar /^./ contained")

  -- Define the syntax group for the remaining characters
  vim.cmd("syntax match RemainingChar /.\\+/ contained")

  -- Link the syntax groups to the highlight groups
  vim.cmd("highlight link FirstChar CmpItemKind")
  vim.cmd("highlight link RemainingChar Type")

  -- Get the lines of the buffer
  local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)

  -- Iterate over each line and apply the highlight
  for i, _ in ipairs(lines) do
    -- Apply the highlight to the first character
    vim.api.nvim_buf_add_highlight(buffer, -1, "FirstChar", i - 1, 0, 1)

    -- Apply the highlight to the remaining characters
    vim.api.nvim_buf_add_highlight(buffer, -1, "RemainingChar", i - 1, 1, -1)
  end


  return buffer
end

local function get_motion(direction)

  local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1]
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local cur_line = vim.fn.line('.')

  local count = wininfo.botline - cur_line
  if direction == "top" then count = cur_line - wininfo.topline end

  local candidates = { 'a', 's', 'd', 'fa', 'fs', 'fd', 'ff', 'fg', 'fh', 'fj', 'fk', 'fl', 'f;', 'ga', 'gs', 'gd', 'gf',
    'gg', 'gh', 'gj', 'gk', 'gl', 'g;', 'ha', 'hs', 'hd', 'hf', 'hg', 'hh', 'hj', 'hk', 'hl', 'h;', 'ja', 'js', 'jd',
    'jf', 'jg', 'jh', 'jj', 'jk', 'jl', 'j;', 'ka', 'ks', 'kd', 'kf', 'kg', 'kh', 'kj', 'kk', 'kl', 'k;', 'la', 'ls',
    'ld', 'lf', 'lg', 'lh', 'lj', 'lk', 'll', 'l;', ';a', ';s', ';d', ';f', ';g', ';h', ';j', ';k', ';l', ';;' };

  local buffer = create_jump_buffer(candidates, count, direction)


  local window = create_window(buffer, 0, count)
  if direction ~= "top" then
    vim.api.nvim_win_close(window, true)
    window = create_window(buffer, vim.fn.line('.') - wininfo.topline + 1, count)
  end

  -- restore back to the original window
  vim.api.nvim_set_current_win(0)
  vim.api.nvim_win_set_cursor(0, cursor_pos)


  local offset = getJumpOffset(candidates )
  local command = offset .. "j"
  if direction == "top" then
    command = offset .. "k"
  end

  vim.api.nvim_win_close(window, true)
  vim.api.nvim_buf_delete(buffer , {force = true})
  return command
end


local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

local function move(direction)
  local current_mode = vim.api.nvim_get_mode().mode
  local motion = get_motion(direction)

  if motion == "" or motion == nil then print("oops") end

  -- If in operator pending mode, switch to visual line mode
  if current_mode == 'no' or current_mode == 'O' then
    vim.api.nvim_command("normal! V")
  end

  local command = 'normal! ' .. motion
  vim.api.nvim_command(command)

end


keymap("n", "gj", function () move("bot") end, opts)
keymap("n", "gk", function () move("top") end, opts)


keymap("x", "gj", function () move("bot") end, opts)
keymap("x", "gk", function () move("top") end, opts)

keymap("o", "gj", function () move("bot") end, opts)
keymap("o", "gk", function () move("top") end, opts)


