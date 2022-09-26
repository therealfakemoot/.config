-- leader
vim.g.mapleader = ','

local function keymap (modes, key, result)
	if #modes < 2 then -- < 2 to account for empty mode (= ":map")
		vim.keymap.set(modes, key, result)
	else
		-- set for every mode in the mode-arg
		for i=1, #modes do
			local mode = modes:sub(i, i)
			vim.keymap.set(mode, key, result)
		end
	end
end

-- [r]eload current config file
keymap("n", "<leader>r", ":write<CR>:source %<CR>") -- alternative: https://www.reddit.com/r/neovim/comments/puuskh/how_to_reload_my_lua_config_while_using_neovim/

-- Update [P]lugins
keymap("n", "<leader>p", ":PackerSync<CR>")

-- copy [l]ast [c]ommand
keymap("n", "<leader>lc", ":let @+=@:<CR>")

--------------------------------------------------------------------------------
-- NAVIGATION

-- Have j and k navigate visual lines rather than logical ones
-- (useful if wrapping is on)
keymap("n", "j", "gj")
keymap("n", "k", "gk")
keymap("n", "gj", "j")
keymap("n", "gk", "k")

-- HJKL behaves like hjkl, but bigger distance (best used with scroll offset)
keymap("", "H", "0^") -- 0^ ensures scrolling to the left on long lines
keymap("", "L", "$")
keymap("", "J", "7j")
keymap("", "K", "7k")
-- quicker to press + on home row
keymap("", "s", "}")
keymap("", "S", "{")

-- Misc
keymap("", "-", "/") -- German Keyboard consistent with US Keyboard layout
keymap("", "+", "*") -- no more modifier key on German Keyboard
keymap("", "ä", "`") -- Goto Mark

--------------------------------------------------------------------------------
-- EDITING

-- don't pollute the register
keymap("nv", "x", '"_x')
keymap("nv", "c", '"_c')
keymap("nv", "C", '"_C')

-- Text Objects
-- for some reason, recursive remap does not seem to work properly, therefore
-- the text-objects below need "_
keymap("n", "<Space>", '"_ciw') -- change word
keymap("n", "<S-Space>", '"_daw')
keymap("v", "<Space>", '"_c')
keymap("v", "<S-Space>", '"_d')
keymap("n", "Q", '"_ci"') -- change double [q]uote content
keymap("n", "q", '"_ci\'') -- change single [q]uote content
keymap("n", "R", 'viw"0p') -- [R]eplace Word with register content

-- Macros
keymap("n", "<leader>q" ,"q")

-- Whitespace
keymap("n", "!", "a <Esc>h") -- append space
keymap("n", "=", "mzO<Esc>`z") -- add blank above
keymap("n", "_", "mzo<Esc>`z") -- add blank below

-- Indention
keymap("n", "<Tab>", ">>")
keymap("n", "<S-Tab>", "<<")
keymap("v", "<Tab>", ">gv")
keymap("v", "<S-Tab>", "<gv")
keymap("nv", "^", "=") -- auto-indent

-- Switch Case of first letter of the word (= toggle between Capital and lower case)
keymap("n", "ü", "mzlblgueh~`z")

-- Transpose
keymap("n", "ö", "xp") -- current & next char
keymap("n", "Ö", "xhhp") -- current & previous char
keymap("n", "Ä", "dawelpb") -- current & next word

-- <leader>{char} → Append {char} to end of line
trailingKeys = {".", ",", ";", ":", '"', "'", "(", ")", "[", "]", "{", "}", "|", "/", "\\", "`" }
for i = 1, #trailingKeys do
	keymap("n", "<leader>"..trailingKeys[i], "mzA"..trailingKeys[i].."<Esc>`z")
end

-- Remove last character from line
keymap("n", "X", 'mz$"_x`z')

-- Misc
keymap("nv", "U", "<C-r>") -- undo consistent on one key
keymap("nv", "M", "J") -- [M]erge Lines

--------------------------------------------------------------------------------
-- INSERT MODE
keymap("i", "jj", '<Esc>')

-- consistent with insert mode / emacs bindings
keymap("i", "<C-e>", '<Esc>A')
keymap("n", "<C-e>", 'A')
keymap("i", "<C-a>", '<Esc>I')
keymap("n", "<C-a>", 'I')
keymap("i", "<C-k>", '<Esc>Dli')

--------------------------------------------------------------------------------
-- VISUAL MODE
keymap("v", "V", "j") -- so double "V" selects two lines
keymap("v", "p", '"_dP') -- do not override register when pasting on selection (still able to do so with P)
keymap("v", "<BS>", '"_d') -- consistent with insert mode selection

--------------------------------------------------------------------------------
-- LANGUAGE-SPECIFIC BINDINGS

-- Markdown
keymap("n", "<CR>", 'A') -- So Double return keeps list syntax
keymap("n", "<leader>x", 'mz^lllrx`z') -- check tasks

-- CSS
keymap("n", "<leader>v", '^Ellct;') -- change [v]alue key (also works for JSON, actually)
keymap("n", "<leader>c", 'mzlEF.yEEp`z') -- double [c]lass under cursor
keymap("n", "<leader>C", 'lF.d/[.\\s]<CR>') -- remove [C]lass under cursor

-- JS
keymap("n", "<leader>t", 'ysiw}i$<Esc>f}') -- make template string variable, requires vim.surround

--------------------------------------------------------------------------------
-- EMULATING MAC BINDINGS
-- - requires GUI app like Neovide (called "Logo Key" there)
-- - mostly done for consistency with other apps
keymap("", "<D-v>", "p") -- cmd+v
keymap("n", "<D-c>", "yy") -- cmd+c: copy line
keymap("v", "<D-c>", "y") -- cmd+c: copy selection
keymap("n", "<D-x>", "dd") -- cmd+x: cut line
keymap("v", "<D-x>", "d") -- cmd+x: cut selection

keymap("n", "<D-n>", ":tabnew<CR>") -- cmd+n
keymap("n", "<D-t>", ":tabnew<CR>") -- cmd+t
keymap("n", "<D-s>", ":write<CR>") -- cmd+s
keymap("n", "<D-a>", "ggvG") -- cmd+a
keymap("n", "<D-w>", ":bd<CR>") -- cmd+w

keymap("n", "<D-D>", "yyp") -- cmd+shift+d: duplicate lines
keymap("v", "<D-D>", "yp") -- cmd+shift+d: duplicate selected lines
keymap("n", "<D-2>", "ddkkp") -- line up
keymap("n", "<D-3>", "ddp") -- line down
keymap("v", "<D-2>", "dkkp") -- selected lines up
keymap("v", "<D-3>", "dp") -- selected lines down
keymap("n", "<D-7>", "gcc") -- comment line
keymap("v", "<D-7>", "gc") -- comment selection
keymap("n", "<D-l>", ":!open %:h <CR>") -- show file in default GUI file explorer
keymap("n", "<D-,>", ":e $HOME/.config/nvim/init.lua <CR>") -- cmd+,
keymap("n", "<D-;>", ":e $HOME/.config/nvim/init.lua <CR>") -- cmd+shift+,

--------------------------------------------------------------------------------
-- FILES AND WINDOWS

-- Telescope
local function telescope(picker)
	return ':lua require("telescope.builtin").'..picker..'()<CR>'
end
keymap("n", "go", telescope("find_files")) -- [o]pen file in current directory (should be used with 'autochdir' option)
keymap("n", "gr", telescope("oldfiles")) -- [r]ecent files
keymap("n", "gb", telescope("buffers")) -- open [b]uffer

-- Using built-in vim commands
-- keymap("n", "go", ":Explore<CR>")
-- keymap("n", "gb", ":ls<CR>:buffer<Space>")

-- Buffers
keymap("", "<C-Tab>", ":bn<CR>")
keymap("n", "gw", "<C-w><C-w>") -- switch to next split
keymap("n", "gt", ":bn<CR>") -- use vim's buffer model instead of tabs
keymap("n", "gT", ":bp<CR>")

-- File Operations
keymap("n", "<C-p>", ":let @+=@%<CR>") -- copy path of current file
keymap("n", "<C-n>", ':let @+ = expand("%:t")<CR>') -- copy name of current file
keymap("n", "<C-r>", ':Rename') -- rename of current file, requires eunuch.vim
keymap("n", "<C-l>", ":!open %:h<CR>") -- show file in default GUI file explorer
keymap("n", "<C-d>", ":saveas %:h/Untitled.%:e<CR>") -- duplicate current file

-- Sorting
keymap("n", "<leader>ss", ":'<,'>sort<CR>") -- [s]ort [s]election
keymap("n", "<leader>sa", "vi]:sort u<CR>") -- [s]ort [a]rray, if multi-line (+ remove duplicates)
keymap("n", "<leader>sg", ":sort<CR>") -- [s]ort [g]lobally
keymap("n", "<leader>sp", "vip:sort<CR>") -- [s]ort [p]aragraph

