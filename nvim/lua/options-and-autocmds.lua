require("utils")
--------------------------------------------------------------------------------

-- timeout for awaiting keystrokes
opt.timeoutlen = 500

-- Search
opt.showmatch = true
opt.smartcase = true
opt.ignorecase = true

-- Popup
opt.pumheight = 15 -- max number of items in popup menu
opt.pumwidth = 10 -- min width popup menu

-- Spelling
opt.spell = false
opt.spelllang = "en_us"

-- Gutter
opt.fillchars = "eob: "
opt.numberwidth = 3 -- minimum width, save some space for shorter files
opt.number = false
opt.relativenumber = false

-- whitespace & indentation
opt.tabstop = 3
opt.softtabstop = 3
opt.shiftwidth = 3
opt.shiftround = true
opt.smartindent = true
opt.list = true
opt.listchars = "multispace:··,tab:  ,nbsp:ﮊ"
opt.virtualedit = "block" -- select whitespace for proper rectangles in visual block mode

-- Split
opt.splitright = true -- vsplit right instead of left
opt.splitbelow = true -- split down instead of up

-- Window Managers/espanso: set title
opt.title = true
opt.titlelen = 0 -- do not shorten title
opt.titlestring = "%{expand(\"%:p\")} [%{mode()}]"

-- Editor
opt.cursorline = true
opt.scrolloff = 12
opt.sidescrolloff = 20
opt.textwidth = 80 -- used by `gq`
opt.wrap = false
opt.colorcolumn = {"+1", "+20"} -- relative to textwidth
opt.signcolumn = "yes:1" -- = gutter

-- Formatting vim.opt.formatoptions:remove("o") would not work, since it's
-- overwritten by the ftplugins having the o option. therefore needs to be set
-- via autocommand https://www.reddit.com/r/neovim/comments/sqld76/stop_automatic_newline_continuation_of_comments/
augroup("formatopts", {})
autocmd("FileType", {
	group = "formatopts",
	callback = function()
		if not (bo.filetype == "markdown") then -- not for markdown, for autolist hack (see markdown.lua)
			bo.formatoptions = bo.formatoptions:gsub("[ro]", "")
		end
	end
})

-- Remember Cursor Position
augroup("rememberCursorPosition", {})
autocmd("BufReadPost", {
	group = "rememberCursorPosition",
	callback = function()
		local jumpcmd
		if bo.filetype == "commit" then
			return
		elseif bo.filetype == "log" or bo.filetype == "" then -- for log files jump to the bottom
			jumpcmd = "G"
		elseif fn.line [['"]] >= fn.line [[$]] then -- in case file has been shortened outside of vim
			jumpcmd = "G"
		elseif fn.line [['"]] >= 1 then -- check file has been entered already
			jumpcmd = [['"]]
		end
		cmd("keepjumps normal! " .. jumpcmd)
	end,
})

-- clipboard & yanking
opt.clipboard = "unnamedplus"
augroup("highlightedYank", {})
autocmd("TextYankPost", {
	group = "highlightedYank",
	callback = function() vim.highlight.on_yank {timeout = 2000} end
})

-- don't treat "-" as word boundary, useful for things like kebab-case-variables
opt.iskeyword:append("-")

--------------------------------------------------------------------------------

-- FILES & SAVING
opt.hidden = true -- inactive buffers are only hidden, not unloaded
opt.undofile = true -- persistent undo history
opt.updatetime = 200 -- affects current symbol highlight (treesitter-refactor) and currentline lsp-hints
opt.autochdir = true -- always current directory
opt.confirm = true

augroup("autosave", {})
autocmd({"BufWinLeave", "BufLeave", "QuitPre", "FocusLost", "InsertLeave"}, {
	group = "autosave",
	pattern = "?*",
	command = "silent! update"
})

augroup("Mini-Lint", {})
autocmd("BufWritePre", {
	group = "Mini-Lint",
	callback = function()
		local save_view = fn.winsaveview() -- save cursor positon
		if bo.filetype ~= "markdown" then -- to preserve spaces from the two-space-rule, and trailing spaces on sentences
			cmd [[%s/\s\+$//e]] -- trim trailing whitespaces
		end
		cmd [[silent! %s#\($\n\s*\)\+\%$##]] -- trim extra blanks at eof https://stackoverflow.com/a/7496112
		fn.winrestview(save_view)
	end
})

--------------------------------------------------------------------------------

-- status bar & cmdline
opt.history = 250 -- do not save too much history to reduce noise for command line history search
opt.cmdheight = 0

--------------------------------------------------------------------------------
-- FOLDING

-- local foldIcon = " 祉"
-- opt.fillchars:append(",fold: ") -- remove the dots in folded lines
opt.foldenable = false -- do not fold at start

-- use treesitter folding
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldmethod = "expr"

-- keep folds on save https://stackoverflow.com/questions/37552913/vim-how-to-keep-folds-on-save
augroup("rememberFolds", {})
autocmd("BufWinLeave", {
	group = "rememberFolds",
	pattern = "?*",
	command = "silent! mkview!"
})

autocmd("BufWinEnter", {
	group = "rememberFolds",
	pattern = "?*",
	command = "silent! loadview"
})

-- pretty fold
-- require("pretty-fold").setup {
-- 	sections = {
-- 		left = { "content", },
-- 		right = {
-- 			" ", "number_of_folded_lines", ": ", "percentage", " ",
-- 			function(config) return config.fill_char:rep(3) end
-- 		}
-- 	},
-- 	fill_char = "",
-- 	remove_fold_markers = true,
-- 	keep_indentation = true, -- Keep the indentation of the content of the fold string.

-- 	-- Possible values:
-- 	-- "delete" : Delete all comment signs from the fold string.
-- 	-- "spaces" : Replace all comment signs with equal number of spaces.
-- 	-- false    : Do nothing with comment signs.
-- 	process_comment_signs = "spaces",

-- 	-- Comment signs additional to the value of `&commentstring` option.
-- 	comment_signs = {},

-- 	-- List of patterns that will be removed from content foldtext section.
-- 	stop_words = {
-- 		"@brief%s*", -- (for C++) Remove '@brief' and all spaces after.
-- 	},

-- 	add_close_pattern = true, -- true, 'last_line' or false
-- 	matchup_patterns = {
-- 		{"{", "}"},
-- 		{"%(", ")"}, -- % to escape lua pattern char
-- 		{"%[", "]"}, -- % to escape lua pattern char
-- 	},
-- }

--------------------------------------------------------------------------------

-- Terminal Mode
augroup("Terminal", {})
autocmd("TermOpen", {
	group = "Terminal",
	command = "startinsert",
})
autocmd("TermClose", {
	group = "Terminal",
	command = "bdelete",
})

--------------------------------------------------------------------------------

-- Skeletons (Templates)
-- apply templates for any filetype named `.config/nvim/templates/skeletion.{ft}`
augroup("Templates", {})
local filetypeList = fn.system('ls "$HOME/.config/nvim/templates/skeleton."* | xargs basename | cut -d. -f2')
local ftWithSkeletons = split(filetypeList, "\n")
for _, ft in pairs(ftWithSkeletons) do
	if ft == "" then break end
	local readCmd = "0r $HOME/.config/nvim/templates/skeleton." .. ft .. " | normal! Go"

	autocmd("BufNewFile", {
		group = "Templates",
		pattern = "*." .. ft,
		command = readCmd,
	})

	-- BufReadPost + empty file as additional condition to also auto-insert
	-- skeletons when empty files were created by other apps
	autocmd("BufReadPost", {
		group = "Templates",
		pattern = "*." .. ft,
		callback = function()
			local curFile = fn.expand("%")
			local fileIsEmpty = fn.getfsize(curFile) < 2 -- 2 to account for linebreak
			if fileIsEmpty then cmd(readCmd) end
		end
	})
end
