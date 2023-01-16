require("config.utils")
local qol = require("funcs.quality-of-life")
--------------------------------------------------------------------------------
-- META

-- search keymaps
keymap("n", "?", function() cmd.Telescope("keymaps") end, { desc = " Keymaps" })

-- Theme Picker
keymap("n", "<leader>T", function() cmd.Telescope("colorscheme") end, { desc = " Colorschemes" })

-- Highlights
keymap("n", "<leader>H", function() cmd.Telescope("highlights") end, { desc = " Highlight Groups" })

-- Update [P]lugins
keymap("n", "<leader>p", require("lazy").sync, { desc = ":Lazy sync" })
keymap("n", "<leader>P", require("lazy").home, { desc = ":Lazy home" })
keymap("n", "<leader>M", cmd.Mason, { desc = ":Mason" })

-- copy [l]ast ex[c]ommand
keymap("n", "<leader>lc", function()
	local lastCommand = fn.getreg(":")
	fn.setreg("+", lastCommand)
	vim.notify("COPIED\n" .. lastCommand)
end, { desc = "Copy last command" })

-- run [l]ast command [a]gain
keymap("n", "<leader>la", "@:", { desc = "Run last command again" })

--------------------------------------------------------------------------------
-- NAVIGATION

-- HJKL behaves like hjkl, but bigger distance (best used with scroll offset)
keymap({ "o", "x" }, "H", "^")
keymap("n", "H", "0^") -- 0^ ensures fully scrolling to the left on long lines
keymap({ "n", "x", "o" }, "L", "$")

keymap("n", "J", function() qol.overscroll("6j") end, { desc = "6j (with overscroll)" })
keymap("x", "J", "6j")
keymap({ "n", "x" }, "K", "6k")

keymap("o", "J", "2j") -- dj = delete 2 lines, dJ = delete 3 lines
keymap("o", "K", "2k")

-- e,w,b make small movements, treating _-. as word boundaries
for _, key in ipairs { "e", "w", "b" } do
	keymap({ "n", "x" }, key, function()
		local iskeywBefore = opt.iskeyword:get()
		opt.iskeyword:remove { "_", "-", "." }
		normal(key)
		opt.iskeyword = iskeywBefore
	end, { desc = "small " .. key })
end

-- add overscroll
keymap("n", "j", function() qol.overscroll("j") end, { desc = "j (with overscroll)" })
keymap({ "n", "x" }, "G", "Gzz")

-- Jump History
keymap("n", "<C-h>", "<C-o>", { desc = "Jump back" })
keymap("n", "<C-l>", "<C-i>", { desc = "Jump forward" })

-- Search
keymap("n", "-", "/", { desc = "Search" })
keymap("x", "-", "<Esc>/\\%V", { desc = "Search within selection" })
keymap("n", "+", "*", { desc = "Search word under cursor" })
keymap("x", "+", [["zy/\V<C-R>=getreg("@z")<CR><CR>]], { desc = "Visual star" })

-- automatically do `:nohl` when done with search https://www.reddit.com/r/neovim/comments/zc720y/comment/iyvcdf0/?context=3
vim.on_key(function(char)
	if fn.mode() == "n" then
		-- INFO table requires the original vim keys, not the remappings
		local new_hlsearch = vim.tbl_contains({ "<CR>", "n", "N", "*", "#", "?", "/" }, fn.keytrans(char))
		if opt.hlsearch:get() ~= new_hlsearch then vim.opt.hlsearch = new_hlsearch end
	end
end, vim.api.nvim_create_namespace("auto_hlsearch"))

-- Marks
require("funcs.mark-cycler").clearMarks() -- HACK clear marks due to nvim's mark bug
keymap("n", "ä", require("funcs.mark-cycler").gotoMark, { desc = "Goto Next Mark" })
keymap("n", "Ä", require("funcs.mark-cycler").setMark, { desc = "Set Next Mark" })
--------------------------------------------------------------------------------

keymap("n", "<Esc>", function()
	if isGui() then
		local clearPending = require("notify").pending() > 10
		require("notify").dismiss { pending = clearPending }
	end
end, { desc = "clear notifications" })

-- FOLDING
keymap("n", "^", "za", { desc = "toggle fold" })

-- [M]atchUp
keymap({ "n", "x" }, "m", "<Plug>(matchup-%)", { desc = "matchup" })

-- Hunks, Changes, and Quicklist
keymap("n", "gh", ":Gitsigns next_hunk<CR>", { desc = "goto next hunk" })
keymap("n", "gH", ":Gitsigns prev_hunk<CR>", { desc = "goto previous hunk" })
keymap("n", "gc", "g;", { desc = "goto next change" })
keymap("n", "gC", "g,", { desc = "goto previous change" })

-- make cnext loop back https://vi.stackexchange.com/a/8535
keymap(
	"n",
	"gq",
	[[:silent try | cnext | catch | cfirst | catch | endtry<CR><CR>]],
	{ desc = "next quickfix item" }
)
keymap("n", "gQ", function() cmd.Telescope("quickfix") end, { desc = " quickfix list" })
-- Leap
keymap("n", "ö", "<Plug>(leap-forward-to)", { desc = "Leap forward" })
keymap("n", "Ö", "<Plug>(leap-backward-to)", { desc = "Leap backward" })

--------------------------------------------------------------------------------
-- CLIPBOARD
opt.clipboard = "unnamedplus"

-- keep the register clean
keymap("n", "x", '"_x')
keymap("n", "c", '"_c')
keymap("n", "cc", '"_cc')
keymap("n", "C", '"_C')
keymap("x", "p", "P", { desc = "paste without switching register" })
keymap("n", "dd", function()
	local isBlankLine = fn.getline("."):find("^%s*$") ---@diagnostic disable-line: param-type-mismatch, undefined-field
	local expr = isBlankLine and '"_dd' or "dd"
	return expr
end, { expr = true })

-- yanking without moving the cursor
augroup("yankImprovements", {})
autocmd({ "CursorMoved", "VimEnter" }, {
	group = "yankImprovements",
	callback = function() g.cursorPreYank = getCursor(0) end,
})

-- - yanking without moving the cursor
-- - highlighted yank
-- - saves yanks in numbered register, so `"1p` pastes previous yanks.
autocmd("TextYankPost", {
	group = "yankImprovements",
	callback = function()
		-- highlighted yank
		vim.highlight.on_yank { timeout = 1500 }

		-- deletion does not need stickiness and also already shifts register, so
		-- only saving the last yank is required
		if vim.v.event.operator == "d" then
			g.lastYank = fn.getreg('"')
			return
		end

		-- sticky yank
		setCursor(0, g.cursorPreYank)

		-- add yanks and deletes to numbered registers
		if vim.v.event.regname ~= "" then return end
		for i = 8, 2, -1 do
			local regcontent = fn.getreg(tostring(i))
			fn.setreg(tostring(i + 1), regcontent)
		end
		fn.setreg("1", fn.getreg("0")) -- so both y and d copy to "1
		if g.lastYank then fn.setreg("2", g.lastYank) end
		g.lastYank = fn.getreg('"')
	end,
})

-- cycle through the last deletes/yanks ("2 till "9), starting at non-last
-- delete/yank
keymap("n", "P", function()
	if not g.killringCount then g.killringCount = 2 end
	cmd.undo()
	normal('"' .. tostring(g.killringCount) .. "p")
	g.killringCount = g.killringCount + 1
	if g.killringCount > 9 then
		vim.notify("Reached end of killring.")
		g.killringCount = 2
	end
end, { desc = "cycle through killring" })

keymap("n", "p", function()
	g.killringCount = 2 -- pasting resets the killring
	normal("p")
end, { desc = "paste & reset killring" })

-- paste charwise reg as linewise & vice versa
keymap("n", "gp", function()
	local reg = "+"
	local regContent = fn.getreg(reg)
	local isLinewise = fn.getregtype(reg) == "V"

	local targetRegType
	if isLinewise then
		targetRegType = "v"
		regContent = regContent:gsub("^%s*", ""):gsub("%s*$", "")
	else
		targetRegType = "V"
	end

	fn.setreg(reg, regContent, targetRegType) ---@diagnostic disable-line: param-type-mismatch
	normal('"' .. reg .. "p") -- for whatever reason, not naming a register does not work here
	if targetRegType == "V" then normal("==") end
end, { desc = "paste differently" })

--------------------------------------------------------------------------------

-- Whitespace Control
keymap("n", "=", "mzO<Esc>`z", { desc = "add blank above" })
keymap("n", "_", "mzo<Esc>`z", { desc = "add blank below" })

-- Indentation
keymap("n", "<Tab>", ">>", { desc = "indent" })
keymap("n", "<S-Tab>", "<<", { desc = "outdent" })
keymap("x", "<Tab>", ">gv", { desc = "indent" })
keymap("x", "<S-Tab>", "<gv", { desc = "outdent" })

--------------------------------------------------------------------------------
-- EDITING

-- Casing
keymap("n", "ü", "mzlblgueh~`z", { desc = "toggle capital/lowercase of word" })
keymap("n", "Ü", "gUiw", { desc = "uppercase word" })
keymap("n", "~", "~h")
keymap("n", "<C-ü>", qol.wordSwitch, { desc = "switch common words" })

-- Append to / delete from EoL
local trailingKeys = { ",", ";", '"', "'", ")", "}", "]" }
for _, v in pairs(trailingKeys) do
	keymap("n", "<leader>" .. v, "mzA" .. v .. "<Esc>`z", { desc = "append " .. v .. " to EoL" })
end
keymap("n", "X", "mz$x`z", { desc = "delete last character" })

-- Spelling (mnemonic: [z]pe[l]ling)
keymap("n", "zl", function() cmd.Telescope("spell_suggest") end, { desc = "spellsuggest" })
keymap("n", "gl", "]s", { desc = "next misspelling" })
keymap("n", "gL", "]s", { desc = "prev misspelling" })
keymap("n", "za", "mz]s1z=`z", { desc = "autofix spelling" }) -- [a]utofix word under cursor

-- [S]ubstitute Operator (substitute.nvim)
keymap("n", "s", function() require("substitute").operator() end, { desc = "substitute operator" })
keymap("n", "ss", function() require("substitute").line() end, { desc = "substitute line" })
keymap("n", "S", function() require("substitute").eol() end, { desc = "substitute to end of line" })
-- stylua: ignore
keymap( "n", "sx", function() require("substitute.exchange").operator() end, { desc = "exchange operator" })
keymap("n", "sxx", function() require("substitute.exchange").line() end, { desc = "exchange line" })

-- IS[w]ap
keymap("n", "<leader>w", cmd.ISwapWith, { desc = "swap nodes" })

-- search & replace
keymap(
	"n",
	"<leader>f",
	[[:%s/<C-r>=expand("<cword>")<CR>//gI<Left><Left><Left>]],
	{ desc = "substitute" }
)
keymap("x", "<leader>f", ":s///gI<Left><Left><Left><Left>", { desc = "substitute" })
keymap(
	{ "n", "x" },
	"<leader>F",
	function() require("ssr").open() end,
	{ desc = "structural search & replace" }
)
keymap("n", "<leader>n", ":%normal ", { desc = ":normal" })
keymap("x", "<leader>n", ":normal ", { desc = ":normal" })

-- Replace Mode
keymap("n", "cR", "R", { desc = "replace mode" })

-- Duplicate Line / Selection (mnemonic: [r]eplicate)
keymap("n", "R", require("funcs.duplication").smartDuplicateLine, { nowait = true, desc = "smart duplicate line" })
keymap("n", "yd", require("funcs.duplication").duplicateLines, { nowait = true, expr = true, desc = "duplicate lines" })

-- Undo
keymap({ "n", "x" }, "U", "<C-r>", { desc = "redo" }) -- redo
keymap("n", "<C-u>", qol.undoDuration, { desc = "undo specific durations" })
keymap("n", "<leader>u", function() cmd.Telescope("undo") end, { desc = " Undotree" })

-- Refactor
keymap(
	{ "n", "x" },
	"<leader>i",
	function() require("refactoring").refactor("Inline Variable") end,
	{ desc = "Refactor: Inline Var" }
)
keymap(
	{ "n", "x" },
	"<leader>e",
	function() require("refactoring").refactor("Extract Variable") end,
	{ desc = "Refactor: Extract Var" }
)

-- Logging & Debugging
local qlog = require("funcs.quicklog")
keymap({ "n", "x" }, "<leader>ll", qlog.quicklog, { desc = " log" })
keymap({ "n", "x" }, "<leader>lb", qlog.beeplog, { desc = " beep log" })
keymap({ "n", "x" }, "<leader>lt", qlog.timelog, { desc = " time log" })
keymap({ "n", "x" }, "<leader>lr", qlog.removelogs, { desc = "  remove log" })
keymap({ "n", "x" }, "<leader>ld", qlog.debuglog, { desc = " debugger" })

-- Sort & highlight duplicate lines
-- stylua: ignore
keymap( { "n", "x" }, "<leader>S", [[:sort<CR>:g/^\(.*\)$\n\1$/<CR><CR>]], { desc = "sort & highlight duplicates" })

-- URL Opening
keymap("n", "gx", function()
	require("various-textobjs").url()
	local foundURL = fn.mode():find("v")
	if foundURL then
		normal([["zy]])
		local url = fn.getreg("z")
		os.execute("open '" .. url .. "'")
	end
end, { desc = "Smart URL Opener" })

--------------------------------------------------------------------------------

-- Line & Character Movement
keymap("n", "<Down>", qol.moveLineDown)
keymap("n", "<Up>", qol.moveLineUp)
keymap("x", "<Down>", qol.moveSelectionDown)
keymap("x", "<Up>", qol.moveSelectionUp)
keymap("n", "<Right>", qol.moveCharRight)
keymap("n", "<Left>", qol.moveCharLeft)
keymap("x", "<Right>", qol.moveSelectionRight)
keymap("x", "<Left>", qol.moveSelectionLeft)

-- Merging / Splitting Lines
keymap({ "n", "x" }, "M", "J", { desc = "merge line up" })
keymap({ "n", "x" }, "<leader>m", "ddpkJ", { desc = "merge line down" })
keymap("n", "|", "a<CR><Esc>k$", { desc = "split line at cursor" })
keymap("x", "|", "<Esc>`>a<CR><Esc>`<i<CR><Esc>", { desc = "split around selection" })

-- TreeSJ plugin
keymap("n", "<leader>s", cmd.TSJToggle, { desc = "split/join" })

-- TS Node Action Plugin
-- keymap(
-- 	"n",
-- 	"<leader>t",
-- 	function() require("ts-node-action").node_action() end,
-- 	{ desc = "node action" }
-- )

--------------------------------------------------------------------------------
-- INSERT MODE & COMMAND MODE
keymap("i", "<C-e>", "<Esc>A") -- EoL
keymap("i", "<C-k>", "<Esc>lDi") -- kill line
keymap("i", "<C-a>", "<Esc>I") -- BoL
keymap("c", "<C-a>", "<Home>")
keymap("c", "<C-e>", "<End>")
keymap("c", "<C-u>", "<C-e><C-u>") -- clear

--------------------------------------------------------------------------------
-- VISUAL MODE
keymap("x", "V", "j", { desc = "repeated V selects more lines" })
keymap("x", "v", "<C-v>", { desc = "vv from Normal Mode starts Visual Block Mode" })
-- INFO <CR> to increment, <BS> to decrement selection defined via treesitter

--------------------------------------------------------------------------------
-- BUFFERS & WINDOWS & SPLITS

keymap("n", "gb", function() cmd.Telescope("buffers") end, { desc = " open buffers" })
-- INFO: <BS> to cycle buffer has to be set in cybu config

local altalt = require("funcs.alt-alt")
keymap("n", "<CR>", altalt.altBufferWindow, { desc = "switch to alt buffer/window" })

if isGui() then
	keymap({ "n", "x", "i" }, "<D-w>", altalt.betterClose, { desc = "close buffer/window/tab" })
end

keymap("n", "<C-w>v", ":vsplit #<CR>", { desc = "vertical split (alt file)" }) -- open the alternate file in the split instead of the current file
keymap("n", "<C-w>h", ":split #<CR>", { desc = "horizontal split (alt file)" })
keymap("", "<C-Right>", ":vertical resize +3<CR>", { desc = "vertical resize (+)" }) -- resizing on one key for sanity
keymap("", "<C-Left>", ":vertical resize -3<CR>", { desc = "vertical resize (-)" })
keymap("", "<C-Down>", ":resize +3<CR>", { desc = "horizontal resize (+)" })
keymap("", "<C-Up>", ":resize -3<CR>", { desc = "horizontal resize (-)" })

--------------------------------------------------------------------------------

-- CMD-Keybindings
if isGui() then
	keymap({ "n", "x", "i" }, "<D-s>", cmd.write, { desc = "save" }) -- cmd+s, will be overridden on lsp attach

	keymap({ "n", "x" }, "<D-l>", function() -- show file in default GUI file explorer
		fn.system("open -R '" .. expand("%:p") .. "'")
	end, { desc = "open in file explorer" })

	keymap("n", "<D-0>", ":10messages<CR>", { desc = ":messages (last 10)" }) -- as cmd.function these wouldn't require confirmation
	keymap("n", "<D-9>", function() cmd.Telescope("notify") end, { desc = " Notifications" })

	-- Multi-Cursor https://github.com/mg979/vim-visual-multi/blob/master/doc/vm-mappings.txt
	g.VM_maps = {
		["Find Under"] = "<D-j>", -- select word under cursor and enter visual-multi (normal mode)
		["Visual Add"] = "<D-j>", -- enter visual-multi (visual mode)
		["Skip Region"] = "<D-S-j>", -- skip current selection (visual-multi mode)
	}

	-- cut, copy & paste
	keymap({ "n", "x" }, "<D-v>", "p", { desc = "paste" }) -- needed for pasting from Alfred clipboard history
	keymap("c", "<D-v>", "<C-r>+", { desc = "paste" })
	keymap("i", "<D-v>", "<C-r><C-o>+", { desc = "paste" })

	-- cmd+e: inline code
	keymap("n", "<D-e>", "bi`<Esc>ea`<Esc>", { desc = "Inline Code Markup" }) -- no selection = word under cursor
	keymap("x", "<D-e>", "<Esc>`<i`<Esc>`>la`<Esc>", { desc = "Inline Code Markup" })
	keymap("i", "<D-e>", "``<Left>", { desc = "Inline Code Markup" })

	-- cmd+t: template string
	keymap("n", "<D-t>", "bi${<Esc>ea}<Esc>b", { desc = "Template String Markup" }) -- no selection = word under cursor
	keymap("x", "<D-t>", "<Esc>${<i}<Esc>${>la}<Esc>b", { desc = "Template String Markup" })
	keymap("i", "<D-t>", "${}<Left>", { desc = "Template String Markup" })
end

--------------------------------------------------------------------------------
-- luasnip

keymap({ "i", "s" }, "<D-j>", function()
	if require("luasnip").jumpable(1) then
		require("luasnip").jump(1)
	else
		vim.notify("No Jump available.", logWarn)
	end
end, { desc = "LuaSnip: Jump" })

keymap({ "i", "s" }, "<D-S-j>", function()
	if require("luasnip").jumpable(-1) then
		require("luasnip").jump(-1)
	else
		vim.notify("No Jump back available.", logWarn)
	end
end, { desc = "LuaSnip: Jump Back" })

keymap({ "i", "s" }, "<D-k>", function()
	if require("luasnip").choice_active() then
		require("luasnip.extras.select_choice")()
		return "<Esc>" -- HACK so we do not end up in insert mode for the selection
	elseif bo.filetype == "markdown" then
		return "<D-k>" -- md link creation
	else
		vim.notify("No Choice available.", logWarn)
		return ""
	end
end, { desc = "LuaSnip: Select Choice", expr = true, remap = true })

keymap("n", "<leader>ls", function() cmd.Telescope("luasnip") end, { desc = " LuaSnip: Snippets" })

--------------------------------------------------------------------------------

-- Color Picker
keymap("n", "#", ":CccPick<CR>")
keymap("n", "'", ":CccConvert<CR>") -- shift-# on German keyboard

-- Neural
keymap("x", "<leader>a", ":NeuralCode complete<CR>", { desc = "ﮧ Code Completion" })

-- ChatGPT
keymap("n", "<leader>a", ":ChatGPT<CR>", { desc = "ﮧ ChatGPT Prompt" })

--------------------------------------------------------------------------------
-- FILES

-- File Switchers
keymap("n", "go", function()
	local isGitRepo = os.execute("test -e $(git rev-parse --show-toplevel)/.git") == 0 -- using test -e instead of -f to check for repo and submodule
	local cwd = expand("%:p:h")
	local scope = "git_files"
	if cwd:find("/nvim/") and not (cwd:find("/my%-plugins/")) then
		scope = "find_files cwd=" .. fn.stdpath("config")
	elseif not isGitRepo or cwd:find("/hammerspoon/") then
		scope = "find_files"
	end
	cmd("Telescope " .. scope)
end, { desc = " Smart Find Files" })
keymap("n", "gO", function() cmd.Telescope("find_files") end, { desc = " Files in cwd" })
keymap("n", "gF", function() cmd.Telescope("live_grep") end, { desc = " Text in cwd" })
keymap("n", "gr", function() cmd.Telescope("oldfiles") end, { desc = " Recent Files" })
-- keymap("n", "gr", function() cmd.Telescope("frecency") end, { desc = " Recent Files" })

-- File Operations
keymap("n", "<C-p>", function() require("genghis").copyFilepath() end, { desc = "copy filepath" })
keymap("n", "<C-n>", function() require("genghis").copyFilename() end, { desc = "copy filename" })
keymap("n", "<leader>x", function() require("genghis").chmodx() end, { desc = "chmod +x" })
keymap("n", "<C-r>", function() require("genghis").renameFile() end, { desc = "rename file" })
-- stylua: ignore
keymap("n", "<D-S-m>", function() require("genghis").moveAndRenameFile() end, { desc = "move-rename file" })
keymap("n", "<C-d>", function() require("genghis").duplicateFile() end, { desc = "duplicate file" })
keymap("n", "<D-BS>", function() require("genghis").trashFile() end, { desc = "move file to trash" })
keymap("n", "<D-n>", function() require("genghis").createNewFile() end, { desc = "create new file" })
-- stylua: ignore
keymap("x", "X", function() require("genghis").moveSelectionToNewFile() end, { desc = "selection to new file" })

--------------------------------------------------------------------------------
-- GIT

-- Neo[G]it
keymap("n", "<leader>gs", ":Neogit<CR>", { desc = " Neogit" })
keymap("n", "<leader>gc", ":Neogit commit<CR>", { desc = " Commit" })
keymap("n", "<leader>ga", ":Gitsigns stage_hunk<CR>", { desc = " Add Hunk" })
keymap("n", "<leader>gr", ":Gitsigns reset_hunk<CR>", { desc = " Reset Hunk" })

-- Git-link
keymap({ "n", "x" }, "<leader>gl", qol.gitLink, { desc = " GitHub Link" })

-- add-commit-pull-push
keymap("n", "<leader>gg", qol.addCommitPush, { desc = " Add-Commit-Push" })

-- Diffview
keymap("n", "<leader>gd", function()
	vim.ui.input({ prompt = "Git Pickaxe (empty = full history)" }, function(query)
		if not query then return end
		if query ~= "" then query = " -G" .. query end
		cmd("DiffviewFileHistory %" .. query)
		cmd.wincmd("w") -- go directly to file window
		cmd.wincmd("|") -- maximize
	end)
end, { desc = " File History (Diffview)" })

--------------------------------------------------------------------------------

-- Option Toggling
keymap("n", "<leader>os", ":set spell!<CR>", { desc = "  toggle spelling" })
keymap("n", "<leader>or", ":set relativenumber!<CR>", { desc = "  relative line numbers" })
keymap("n", "<leader>on", ":set number!<CR>", { desc = "  line numbers" })
keymap("n", "<leader>ol", cmd.LspRestart, { desc = " 璉LSP Restart" })
keymap("n", "<leader>ow", qol.toggleWrap, { desc = "  wrap" })

keymap("n", "<leader>od", function()
	if g.diagnosticOn == nil then g.diagnosticOn = true end
	if g.diagnosticOn then
		vim.diagnostic.disable(0)
	else
		vim.diagnostic.enable(0)
	end
	g.diagnosticOn = not g.diagnosticOn
end, { desc = "  diagnostics" })

--------------------------------------------------------------------------------

-- TERMINAL AND CODI
keymap("t", "<S-CR>", [[<C-\><C-n><C-w>w]], { desc = "go to next window" })
keymap("t", "<D-v>", [[<C-\><C-n>pi]], { desc = "Paste in Terminal Mode" })

keymap("n", "6", ":ToggleTerm size=8<CR>", { desc = "ToggleTerm" })
keymap("x", "6", ":ToggleTermSendVisualSelection size=8<CR>", { desc = "Selection to ToggleTerm" })

keymap("n", "5", function()
	cmd.CodiNew()
	cmd.file("Codi: " .. bo.filetype) -- HACK to set buffername, since Codi does not provide a filename for its buffer
end, { desc = ":CodiNew" })

--------------------------------------------------------------------------------

-- BUILD SYSTEM

keymap("n", "<leader>r", function()
	cmd.update()
	local parentFolder = expand("%:p:h")
	local ft = bo.filetype

	-- sketchybar
	if parentFolder:find("sketchybar") then
		fn.system("brew services restart sketchybar")

	-- markdown / pandoc
	elseif ft == "markdown" then
		local filepath = expand("%:p")
		local pdfFilename = expand("%:t:r") .. ".pdf"
		fn.system("pandoc '" .. filepath .. "' --output='" .. pdfFilename .. "' --pdf-engine=wkhtmltopdf")
		fn.system("open '" .. pdfFilename .. "'")

	-- nvim config
	elseif ft == "lua" and parentFolder:find("nvim") then
		cmd.source()
		vim.notify(expand("%:r") .. " re-sourced")

	-- Hammerspoon
	elseif ft == "lua" and parentFolder:find("hammerspoon") then
		os.execute([[open -g "hammerspoon://hs-reload"]])

	-- Karabiner
	elseif ft == "yaml" and parentFolder:find("/karabiner") then
		local karabinerBuildScp = vim.env.DOTFILE_FOLDER .. "/karabiner/build-karabiner-config.js"
		local result = fn.system('osascript -l JavaScript "' .. karabinerBuildScp .. '"')
		result = result:gsub("\n$", "")
		vim.notify(result)

	-- Typescript
	elseif ft == "typescript" then
		cmd.redir("@z")
		-- silent, to not show up message (redirection still works)
		-- make-command run is defined in bo.makeprg in the typescript ftplugin
		cmd([[silent make]])
		local output = fn.getreg("z"):gsub(".-\r", "") -- remove first line
		local logLevel = output:find("error") and logError or logTrace
		vim.notify(output, logLevel)
		cmd.redir("END")

	-- AppleScript
	elseif ft == "applescript" then
		cmd.AppleScriptRun()
		cmd.wincmd("p") -- switch to previous window

	-- None
	else
		vim.notify("No build system set.", logWarn)
	end
end, { desc = "Build System" })

--------------------------------------------------------------------------------

-- q / Esc to close special windows
augroup("quickClose", {})
autocmd("FileType", {
	group = "quickClose",
	pattern = {
		"help",
		"startuptime",
		"netrw",
		"lspinfo",
		"tsplayground",
		"qf",
		"lazy",
		"notify",
		"AppleScriptRunOutput",
		"man",
	},
	callback = function()
		local opts = { buffer = true, nowait = true, desc = "close" }
		keymap("n", "<Esc>", cmd.close, opts)
		keymap("n", "q", cmd.close, opts)
	end,
})

-- HACK to remove the waiting time from the q, due to conflict with `qq`
-- for comments
autocmd("FileType", {
	group = "quickClose",
	pattern = { "ssr", "TelescopePrompt" },
	callback = function()
		local opts = { buffer = true, nowait = true, remap = true, desc = "close" }
		if bo.filetype == "ssr" then
			keymap("n", "q", "Q", opts)
		else
			keymap("n", "q", "<Esc>", opts)
		end
	end,
})

--------------------------------------------------------------------------------

-- Simple version of delaytrain
for _, key in ipairs { "x", "h", "l" } do
	local timeout = 5000
	local maxUsage = 8

	local count = 0
	keymap("n", key, function()
		if key == "x" then key = [["_x]] end
		if fn.reg_executing() ~= "" then return key end

		if count <= maxUsage then
			count = count + 1
			vim.defer_fn(function() count = count - 1 end, timeout) ---@diagnostic disable-line: param-type-mismatch
			return key
		end
	end, { expr = true, desc = key .. " (delaytrain)" })
end

--------------------------------------------------------------------------------
