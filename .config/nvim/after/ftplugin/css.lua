require("utils")
local opts = {buffer = true, silent = true}
--------------------------------------------------------------------------------

-- comment marks more useful than symbols for theme development
keymap("n", "gs", function() telescope.current_buffer_fuzzy_find {
		default_text = "/* < ",
		prompt_prefix = " ",
		prompt_title = "Navigation Markers",
	}
end, opts)

-- search only for variables
keymap("n", "gS", function() telescope.current_buffer_fuzzy_find {
		default_text = "--",
		prompt_prefix = " ",
		prompt_title = "CSS Variables",
	}
end, opts)

--------------------------------------------------------------------------------

-- section jumping instead of function jumping
keymap({"n", "x"}, "<C-j>", [[/^\/\* <\+ <CR>:nohl<CR>]], opts)
keymap({"n", "x"}, "<C-k>", [[?^\/\* <\+ <CR>:nohl<CR>]], opts)

--------------------------------------------------------------------------------

keymap("n", "cv", "^Ewct;", opts) -- change [v]alue key
keymap("n", "<leader>c", "mzlEF.yEEp`z", opts) -- double [c]lass under cursor
keymap("n", "<leader>C", "lF.d/[.\\s]<CR>:nohl<CR>", opts) -- delete [c]lass under cursor

-- prefix "." and join the last paste. Useful when copypasting from the dev tools
keymap("n", "<leader>.", "mz`[v`]: s/^\\| /./g<CR>:nohl<CR>`zl", opts)

-- smart line duplicate (mnemonic: [R]eplicate)
-- switches top/bottom & moves to value
keymap("n", "R", function () qol.duplicateLine {reverse = true, moveTo = "value"} end, opts)

---@diagnostic disable: undefined-field, param-type-mismatch
-- toggle !important
keymap("n", "<leader>i", function()
	local lineContent = fn.getline(".")
	if lineContent:find("!important") then
		lineContent = lineContent:gsub(" !important", "")
	else
		lineContent = lineContent:gsub(";", " !important;")
	end
	fn.setline(".", lineContent)
end, {buffer = true})

keymap("n", "zh", function()
	local hr = {
		"/* ───────────────────────────────────────────────── */",
		"/* << ",
		"──────────────────────────────────────────────────── */",
		"",
		"",
	}
	fn.append(".", hr)
	local lineNum = api.nvim_win_get_cursor(0)[1] + 2
	local colNum = #hr[2] + 2
	api.nvim_win_set_cursor(0, {lineNum, colNum})
	cmd [[startinsert!]]
end, opts)

---@diagnostic enable: undefined-field, param-type-mismatch
