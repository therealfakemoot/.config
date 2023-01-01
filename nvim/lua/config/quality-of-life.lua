---@diagnostic disable: param-type-mismatch, assign-type-mismatch
local M = {}
--------------------------------------------------------------------------------
local bo = vim.bo
local b = vim.b
local fn = vim.fn
local cmd = vim.cmd
local lineNo = vim.fn.line
local colNo = vim.fn.col
local append = vim.fn.append
local getCursor = vim.api.nvim_win_get_cursor
local setCursor = vim.api.nvim_win_set_cursor
local expand = vim.fn.expand

---runs :normal natively with bang
local function normal(cmdStr) vim.cmd.normal { cmdStr, bang = true } end

---@param option string
---@return any
local function getlocalopt(option) return vim.api.nvim_get_option_value(option, { scope = "local" }) end

---equivalent to `:setlocal option&`
---@param option string
---@return any
local function getglobalopt(option) return vim.api.nvim_get_option_value(option, { scope = "global" }) end
--------------------------------------------------------------------------------

-- Duplicate line under cursor, and change occurrences of certain words to their
-- opposite, e.g., "right" to "left". Intended for languages like CSS.
---@param opts? table available: reverse, moveTo = key|value|none, incrementKeys
function M.duplicateLine(opts)
	if not opts then opts = { reverse = false, moveTo = "key", incrementKeys = true } end

	local line = fn.getline(".") ---@type string
	if opts.reverse then
		if line:find("top") then
			line = line:gsub("top", "bottom")
		elseif line:find("bottom") then
			line = line:gsub("bottom", "top")
		elseif line:find("right") then
			line = line:gsub("right", "left")
		elseif line:find("left") then
			line = line:gsub("left", "right")
		elseif line:find("height") and not (line:find("line-height")) then
			line = line:gsub("height", "width")
		elseif line:find("width") and not (line:find("border-width")) and not (line:find("outline-width")) then
			line = line:gsub("width", "height")
		end
	end

	local lineHasNumberedKey, _, num = line:find("(%d+).*[:=]")
	if opts.incrementKeys and lineHasNumberedKey then
		local nextNum = tostring(tonumber(num) + 1)
		line = line:gsub("%d+(.*[:=])", nextNum .. "%1")
	end

	append(".", line)

	-- cursor movement
	local lineNum, colNum = unpack(getCursor(0))
	lineNum = lineNum + 1 -- line down
	local keyPos, valuePos = line:find(".%w+ ?[:=] ?")
	if opts.moveTo == "value" and valuePos then
		colNum = valuePos
	elseif opts.moveTo == "key" and keyPos then
		colNum = keyPos
	end
	setCursor(0, { lineNum, colNum })
end

function M.duplicateSelection()
	local prevReg = fn.getreg("z")
	cmd([[noautocmd silent! normal!"zy`]"zp]]) -- `noautocmd` to not trigger highlighted-yank
	fn.setreg("z", prevReg)
end

--------------------------------------------------------------------------------

--- open URLs (non macOS needs to modify open comment)
function M.bettergx()
	local urlVimRegex =
		[[https\?:\/\/\(\w\+\(:\w\+\)\?@\)\?\([A-Za-z][-_0-9A-Za-z]*\.\)\{1,}\(\w\{2,}\.\?\)\{1,}\(:[0-9]\{1,5}\)\?\S*]] -- https://gist.github.com/tobym/584909
	local urlLuaRegex = [[https?:?[^%s]+]] -- lua url regex being simple is okay, since vimregex runs before
	local prevCur = getCursor(0)

	normal("0") -- to prioritize URLs in the same line
	local urlLineNr = fn.search(urlVimRegex, "wcz")
	if urlLineNr == 0 then
		vim.notify("No URL found in this file.", logWarn)
	else
		local urlLine = fn.getline(urlLineNr) ---@type string
		local url = urlLine:match(urlLuaRegex)
		os.execute('open "' .. url .. '"')
	end
	setCursor(0, prevCur)
end

--------------------------------------------------------------------------------
-- BUFFERS

function M.currentFileStatusline()
	local maxLen = 15
	local altFile = expand("#:t")
	local curFile = expand("%:t")
	local icon = bo.modifiable and "%% " or " "
	local ft = bo.filetype
	if bo.buftype == "terminal" then
		local mode = fn.mode() == "t" and "[N]" or "[T]"
		return " Terminal " .. mode
	elseif bo.buftype == "nofile" or (curFile == "" and ft ~= "") then
		return " " .. ft -- special windows, e.g., lazy
	elseif curFile == "" and ft == "" then
		return "%% [New]"
	elseif curFile == altFile then
		local curParent = expand("%:p:h:t")
		if #curParent > maxLen then curParent = curParent:sub(1, maxLen) .. "…" end
		return "%% " .. curParent .. "/" .. curFile
	end
	return icon .. curFile
end

---get the alternate window, accounting for special windows (scrollbars, notify)
---@return string|nil path of buffer in altwindow, nil if none exists (= only
--one window)
local function altWindow()
	local i = 0
	local altWin

	repeat
		if i > fn.winnr("$") then return nil end
		-- two checks for regular window to catch all edge cases
		altWin = fn.bufname(fn.winbufnr(i))
		local isRegularWin1 = altWin and altWin ~= fn.bufname() and altWin ~= ""
		local win = api.nvim_win_get_config(fn.win_getid(i)) -- https://github.com/dstein64/nvim-scrollview/issues/83
		local isRegularWin2 = not win.external and win.focusable
		i = i + 1
	until isRegularWin1 and isRegularWin2

	return altWin
end

---get the alternate oldfile, accounting for non-existing files etc.
---@return string|nil path of oldfile, nil if none exists in all oldfiles
local function altOldfile()
	local oldfile
	local i = 0
	repeat
		i = i + 1
		if i > #vim.v.oldfiles then return nil end
		oldfile = vim.v.oldfiles[i]
		local fileExists = fn.filereadable(oldfile) == 1
		local isCurrentFile = oldfile == expand("%:p")
	until fileExists and not isCurrentFile -- check for deleted, renamed, or irregular files
	return oldfile
end

---shows info on alternate window/buffer/oldfile in that priority
function M.alternateFileStatusline()
	local maxLen = 15
	local altFile = expand("#:t")
	local curFile = expand("%:t")

	if altFile == "" and not altOldfile() then -- no oldfile and after start
		return ""
	elseif altWindow() then
		return "  " .. altWindow()
	elseif altFile == "" and altOldfile() then
		return " " .. vim.fs.basename(altOldfile())
	elseif curFile == altFile then -- same name, different file
		local altParent = expand("#:p:h:t")
		if #altParent > maxLen then altParent = altParent:sub(1, maxLen) .. "…" end
		return "# " .. altParent .. "/" .. altFile
	end
	return "# " .. altFile
end

---switch to alternate window/buffer/oldfile in that priority
function M.altBufferWindow()
	cmd.nohlsearch()
	if altWindow() then
		cmd.wincmd("p")
	elseif expand("#") ~= "" then
		cmd.buffer("#")
	elseif altOldfile() then
		cmd.edit(altOldfile())
	else
		vim.notify("Nothing to switch to.", logWarn)
	end
end

---Close window/buffer in that priority
function M.betterClose()
	local openBuffers = fn.getbufinfo { buflisted = 1 }
	local bufToDel = expand("%:p")

	if bo.modifiable then cmd.update() end
	cmd.nohlsearch()

	if #openBuffers == 1 then
		vim.notify("Only one buffer open.", logWarn)
		return
	elseif #openBuffers == 2 then
		cmd.bwipeout() -- cannot clear altfile otherwise :/
		return
	end

	cmd.bdelete()

	-- ensure new alt file points towards open, non-active buffer, or altoldfile
	local curFile = expand("%:p")
	local i = 0
	local newAltBuf = ""
	repeat
		i = i + 1
		if i > #openBuffers then
			newAltBuf = altOldfile() or "" 
			break
		end
		newAltBuf = openBuffers[i].name
	until newAltBuf ~= curFile and newAltBuf ~= bufToDel

	fn.setreg("#", newAltBuf) -- empty string will set the altfile to the current buffer
end

--------------------------------------------------------------------------------
-- UNDO

-- Save Open time
augroup("undoTimeMarker", {})
autocmd("BufReadPost", {
	group = "undoTimeMarker",
	callback = function() b.timeOpened = os.time() end,
})

---select between undoing the last 1h, 4h, or 24h
function M.undoDuration()
	local now = os.time() -- saved in epoch secs
	local minsPassed = math.floor((now - b.timeOpened) / 60)
	local resetLabel = "~" .. tostring(minsPassed) .. "m ago)"
	local selection = { resetLabel, "15m", "1h", "4h", "24h", " present" }

	vim.ui.select(selection, { prompt = "Undo…" }, function(choice)
		if not choice then
			return
		elseif choice:find("ago") then
			cmd.earlier(minsPassed .. "m")
		elseif choice:find("present") then
			cmd.later(tostring(opt.undolevels:get())) -- redo as much as there are undolevels
		else
			cmd.earlier(choice)
		end
	end)
end

--------------------------------------------------------------------------------

---enables overscrolling for that action when close to the last line, depending
---on 'scrolloff' option
---@param action string The motion to be executed when not at the EOF
function M.overscroll(action)
	if bo.filetype ~= "DressingSelect" then
		local curLine = lineNo(".")
		local lastLine = lineNo("$")
		if (lastLine - curLine) <= vim.wo.scrolloff then normal("zz") end
	end

	local usedCount = vim.v.count1
	local actionCount = action:match("%d+") -- if action includes a count
	if actionCount then
		action = action:gsub("%d+", "")
		usedCount = tonumber(actionCount) * usedCount
	end
	normal(tostring(usedCount) .. action)
end

---toggle wrap, colorcolumn, and hjkl visual/logical maps in one go
function M.toggleWrap()
	local wrapOn = getlocalopt("wrap")
	local opts = { buffer = true }
	if wrapOn then
		setlocal("wrap", false) -- soft wrap
		setlocal("colorcolumn", getglobalopt("colorcolumn")) -- reactivate ruler

		local del = vim.keymap.del
		del({ "n", "x" }, "H", opts)
		del({ "n", "x" }, "L", opts)
		del({ "n", "x" }, "J", opts)
		del({ "n", "x" }, "K", opts)
		del({ "n", "x" }, "k", opts)
		del({ "n", "x" }, "j", opts)
	else
		setlocal("wrap", true) -- soft wrap
		setlocal("colorcolumn", "") -- deactivate ruler

		local keymap = vim.keymap.set
		keymap({ "n", "x" }, "H", "g^", opts)
		keymap({ "n", "x" }, "L", "g$", opts)
		keymap({ "n", "x" }, "J", function() M.overscroll("6gj") end, opts)
		keymap({ "n", "x" }, "K", "6gk", opts)
		keymap({ "n", "x" }, "k", "gk", opts)
		keymap({ "n", "x" }, "j", function() M.overscroll("gj") end, opts)
	end
end

--------------------------------------------------------------------------------
-- GIT

-- options for fn.jobstart()
local shellOpts = {
	stdout_buffered = true,
	stderr_buffered = true,
	detach = true,
	on_stdout = function(_, data, _)
		if not data or (data[1] == "" and #data == 1) then return end
		local stdOut = table.concat(data, " \n "):gsub("%s*$", "")
		vim.notify(stdOut)
	end,
	on_stderr = function(_, data, _)
		if not data or (data[1] == "" and #data == 1) then return end
		local stdErr = table.concat(data, " \n "):gsub("%s*$", "")
		vim.notify(stdErr)
	end,
}

---@param prefillMsg? string
function M.addCommitPush(prefillMsg)
	if not prefillMsg then prefillMsg = "" end

	-- uses dressing + cmp + omnifunc for autocompletion of filenames
	vim.ui.input({ prompt = "Commit Message", default = prefillMsg, completion = "file" }, function(commitMsg)
		if not commitMsg then
			return
		elseif #commitMsg > 50 then
			vim.notify("Commit Message too long.", logWarn)
			M.addCommitPush(commitMsg:sub(1, 50))
			return
		elseif commitMsg == "" then
			commitMsg = "chore"
		end

		local cc =
			{ "chore", "build", "test", "fix", "feat", "refactor", "perf", "style", "revert", "ci", "docs" }
		local firstWord = commitMsg:match("^%w+")
		if not vim.tbl_contains(cc, firstWord) then
			vim.notify("Not using a Conventional Commits keyword.", logWarn)
			M.addCommitPush(commitMsg)
			return
		end

		vim.notify(' git add-commit-push\n"'..commitMsg.. '"')
		fn.jobstart("git add -A && git commit -m '" .. commitMsg .. "' ; git pull ; git push", shellOpts)
	end)
end

function M.gitLink()
	local repo = fn.system([[git --no-optional-locks remote -v]]):gsub(".*:(.-)%.git .*", "%1")
	local branch = fn.system([[git --no-optional-locks branch --show-current]]):gsub("\n", "")
	if branch:find("^fatal: not a git repository") then
		vim.notify("Not a git repository.", logWarn)
		return
	end
	local filepath = expand("%:p")
	local gitroot = fn.system([[git --no-optional-locks rev-parse --show-toplevel]])
	local pathInRepo = filepath:sub(#gitroot)

	local location
	local selStart = fn.line("v")
	local selEnd = fn.line(".")
	if selStart == selEnd then -- normal mode or one-line-selection
		location = "L" .. tostring(selStart)
	elseif selStart < selEnd then
		location = "L" .. tostring(selStart) .. "-L" .. tostring(selEnd)
	else
		location = "L" .. tostring(selEnd) .. "-L" .. tostring(selStart)
	end

	local gitRemote = "https://github.com/" .. repo .. "/blob/" .. branch .. pathInRepo .. "#" .. location

	os.execute("open '" .. gitRemote .. "'")
	fn.setreg("+", gitRemote)
end
--------------------------------------------------------------------------------

---log statement for variable under cursor, similar to the 'turbo console log'
---VS Code plugin. Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.quicklog()
	local varname
	if fn.mode() == "n" then
		varname = fn.expand("<cword>")
	else
		local prevReg = fn.getreg("z")
		normal('"zy')
		varname = fn.getreg("z")
		fn.setreg("z", prevReg)
	end

	local logStatement
	local ft = bo.filetype
	local lnStr = ""

	if ft == "lua" then
		logStatement = 'print("' .. lnStr .. varname .. ':", ' .. varname .. ")"
	elseif ft == "python" then
		logStatement = 'print("' .. lnStr .. varname .. ': " + ' .. varname .. ")"
	elseif ft == "javascript" or ft == "typescript" then
		logStatement = 'console.log("' .. lnStr .. varname .. ': " + ' .. varname .. ");"
	elseif ft == "zsh" or ft == "bash" or ft == "fish" or ft == "sh" then
		logStatement = 'echo "(log) ' .. lnStr .. varname .. ": $" .. varname .. '"'
	elseif ft == "applescript" then
		logStatement = 'log "' .. lnStr .. varname .. ': " & ' .. varname
	else
		vim.notify("Quicklog does not support " .. ft .. " yet.", logWarn)
		return
	end

	append(".", logStatement)
	normal("j==")
end

function M.timelog()
	if not g.timelogStart == nil then g.timelogStart = true end
	local logStatement1, logStatement2
	local ft = bo.filetype

	if ft == "lua" then
		logStatement1 = {
			'print("timelog start")',
			"local timelogStart = os.time()",
		}
		logStatement2 = {
			"local duration = os.difftime(timelogStart, os.time())",
			'print("timelog: ", duration, "s")',
		}
	elseif ft == "javascript" or ft == "typescript" then
		logStatement1 = 'console.time("timelog")'
		logStatement2 = 'console.timeEnd("timelog")'
	elseif ft == "bash" or ft == "zsh" or ft == "sh" or ft == "fish" then
		logStatement1 = {
			"timelogStart=$(date +%s)",
			'echo "(time) start"',
		}
		logStatement2 = {
			"timelogEnd=$(date +%s) && runtime = $((timelogEnd - timelogStart))",
			'echo "(time) ${runtime}s"',
		}
	else
		vim.notify("Timelog does not support " .. ft .. " yet.", logWarn)
		return
	end
	local logToAdd = g.timelogStart and logStatement1 or logStatement2

	append(".", logToAdd)
	for i = 1, #logToAdd, 1 do
		normal("j==")
	end
	g.timelogStart = not g.timelogStart
end

---adds simple "beep" log statement to check whether conditionals have been
---entered Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.beeplog()
	local logStatement
	local ft = bo.filetype

	if ft == "lua" or ft == "python" then
		logStatement = 'print("beep")'
	elseif ft == "javascript" or ft == "typescript" then
		logStatement = 'console.log("beep")'
	elseif ft == "zsh" or ft == "bash" or ft == "fish" or ft == "sh" then
		logStatement = 'echo "(beep)"'
	elseif ft == "applescript" then
		logStatement = 'log "beep"'
	else
		vim.notify("Beeplog does not support " .. ft .. " yet.", logWarn)
		return
	end

	append(".", logStatement)
	normal("j==")
end

---Remove all log statements in the current buffer
---Supported: lua, python, js/ts, zsh/bash/fish, and applescript
function M.removelogs()
	g.timelogCount = 0 -- reset timelog
	local ft = bo.filetype
	local logCommand
	local linesBefore = fn.line("$")
	if ft == "lua" or ft == "python" then
		logCommand = "print"
	elseif ft == "javascript" or ft == "typescript" then
		logCommand = "console."
	elseif ft == "zsh" or ft == "bash" or ft == "fish" or ft == "sh" then
		cmd([[g/echo "(beep)"/d]]) -- keywords in () needed to ensure that other echos are not deleted
		cmd([[g/echo "(log)/d]])
		cmd([[g/echo "(time)/d]])
		return
	elseif ft == "applescript" then
		logCommand = "log"
	else
		vim.notify("Removelog does not support " .. ft .. " yet.", logWarn)
	end

	cmd([[g/^\s*]] .. logCommand .. [[/d]])
	cmd.nohlsearch()

	local linesRemoved = linesBefore - fn.line("$")
	local msg = "Cleared " .. tostring(linesRemoved) .. " log statements."
	if linesRemoved == 1 then msg = msg:gsub("s%.$", ".") end -- remove plural
	vim.notify(msg)
end

--------------------------------------------------------------------------------
-- MOVEMENT
-- performed via `:normal` makes them less glitchy

local function leaveVisualMode()
	-- https://github.com/neovim/neovim/issues/17735#issuecomment-1068525617
	local escKey = vim.api.nvim_replace_termcodes("<Esc>", false, true, true)
	vim.api.nvim_feedkeys(escKey, "nx", false)
end

function M.moveLineDown()
	if lineNo(".") == lineNo("$") then return end
	cmd([[. move +1]])
	if bo.filetype ~= "yaml" then normal("==") end
end

function M.moveLineUp()
	if lineNo(".") == 1 then return end
	cmd([[. move -2]])
	if bo.filetype ~= "yaml" then normal("==") end
end

function M.moveCharRight()
	if colNo(".") >= colNo("$") - 1 then return end
	normal('"zx"zp')
end

function M.moveCharLeft()
	if colNo(".") == 1 then return end
	normal('"zdh"zph')
end

function M.moveSelectionDown()
	leaveVisualMode()
	cmd([['<,'> move '>+1]])
	normal("gv=gv")
end

function M.moveSelectionUp()
	leaveVisualMode()
	cmd([['<,'> move '<-2]])
	normal("gv=gv")
end

function M.moveSelectionRight() normal('"zx"zpgvlolo') end

function M.moveSelectionLeft() normal('"zdh"zPgvhoho') end

--------------------------------------------------------------------------------

return M
