local function config()
	vim.opt.termguicolors = true -- required for the plugin
	--------------------------------------------------------------------------------
	-- Base config
	local notifyWidth = 55
	local printDurationSecs = 8

	require("notify").setup {
		render = "minimal",
		stages = "slide",
		level = 0, -- minimum severity level to display (0 = display all)
		max_height = 25,
		max_width = notifyWidth, -- HACK see below
		minimum_width = 13,
		timeout = 4000,
		top_down = false,
		on_open = function(win)
			if vim.api.nvim_win_is_valid(win) then
				vim.api.nvim_win_set_config(win, { border = borderStyle })
			end
		end,
	}

	--------------------------------------------------------------------------------

	-- HACK requires custom wrapping setup https://github.com/rcarriga/nvim-notify/issues/129
	-- replaces vim.notify = require("notify")
	local function split_length(text, length)
		local lines = {}
		local next_line
		while true do
			if #text == 0 then return lines end
			next_line, text = text:sub(1, length), text:sub(length)
			lines[#lines + 1] = next_line
		end
	end

	-- HACK filter out annoying buggy messages from the satellite plugin: https://github.com/lewis6991/satellite.nvim/issues/36
	local function banned(msg) -- https://github.com/rcarriga/nvim-notify/issues/114#issuecomment-1179754969
		return msg:find("^gitsigns ROW: %d+")
			or msg:find("^line value outside range")
			or msg:find("^diagnostic ROW: %d+")
	end

	augroup("macOSnotification", {})
	autocmd("FocusGained", {
		group = "macOSnotification",
		callback = function() g.nvim_has_focus = true end,
	})
	autocmd("FocusLost", {
		group = "macOSnotification",
		callback = function() g.nvim_has_focus = false end,
	})

	vim.notify = function(msg, level, opts) ---@diagnostic disable-line: duplicate-set-field
		if banned(msg) then return end
		if type(msg) == "string" then
			local isCodeOutput = msg:find("^%s*{")
			if isCodeOutput then return require("notify")(msg, level, opts) end
			msg = vim.split(msg, "\n", { trimepty = true })
		end
		local truncated = {}
		for _, line in pairs(msg) do
			local new_lines = split_length(line, notifyWidth)
			new_lines = new_lines
			for _, nl in ipairs(new_lines) do
				nl = nl:gsub("^%s*", ""):gsub("%s*$", "")
				table.insert(truncated, " " .. nl .. " ")
			end
		end

		-- use macOS notification if not focused
		if not g.nvim_has_focus then
			local _msg = table.concat(truncated, "\n")
			os.execute([[osascript -e 'display notification "" with title "]] .. _msg .. [[" with sound']])
		end
		return require("notify")(truncated, level, opts)
	end

	-----------------------------------------------------------------------------

	-- replace lua's print message with notify.nvim → https://www.reddit.com/r/neovim/comments/xv3v68/tip_nvimnotify_can_be_used_to_display_print/
	-- selene: allow(incorrect_standard_library_use)
	print = function(...)
		local safe_args = {}
		local args = { ... }
		local includesTable = false
		for _, arg in pairs(args) do
			if type(arg) == "table" then arg = "= " .. vim.inspect(arg) end -- pretty print tables
			includesTable = true
			table.insert(safe_args, tostring(arg))
		end
		local notifyOpts = { timeout = printDurationSecs * 1000 }

		-- enable treesitter highlighting in the notification
		if includesTable then
			notifyOpts.on_open = function(win)
				local buf = api.nvim_win_get_buf(win)
				api.nvim_buf_set_option(buf, "filetype", "lua")
			end
		end

		vim.notify(table.concat(safe_args, " "), logInfo, notifyOpts)
	end
end

--------------------------------------------------------------------------------

return {
	"rcarriga/nvim-notify",
	event = "VeryLazy",
	config = config,
	cond = function() return vim.g.neovide or vim.g.goneovim end,
}
