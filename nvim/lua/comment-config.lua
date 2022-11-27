require("utils")
--------------------------------------------------------------------------------

-- COMMENTS (mnemonic: [q]uiet text)
require("Comment").setup {
	ignore = "^$", -- ignore empty lines
	toggler = {
		line = "qq",
		block = "<Nop>",
	},
	opleader = {
		line = "q",
		block = "<Nop>",
	},
	extra = {
		above = "<Nop>",
		below = "<Nop>",
		eol = "Q",
	},
}

-- effectively creating "q" as comment textobj, can't map directly to q since
-- overlap in visual mode where q can be object and operator. However, this
-- method here also has the advantage of making it possible to preserve cursor
-- position.
-- requires remap for treesitter and comments.nvim mappings
keymap("n", "dq", [[:normal!mz<CR>dCOM`z]], {remap = true}) -- since remap is required, using mz via :normal, since m has been remapped
keymap("n", "yq", "yCOM", {remap = true}) -- thanks to yank positon saving, doesnt need to be done here
keymap("n", "cq", '"_dCOMxQ', {remap = true}) -- delete & append comment to preserve commentstring

-- TEXTOBJECT FOR ADJACENT COMMENTED LINES
-- = qu for uncommenting
-- big Q also as text object
-- https://github.com/numToStr/Comment.nvim/issues/22#issuecomment-1272569139
local function commented_lines_textobject()
	local U = require("Comment.utils")
	local cl = vim.api.nvim_win_get_cursor(0)[1] -- current line
	local range = {srow = cl, scol = 0, erow = cl, ecol = 0}
	local ctx = {ctype = U.ctype.linewise, range = range}
	local cstr = require("Comment.ft").calculate(ctx) or vim.bo.commentstring
	local ll, rr = U.unwrap_cstr(cstr)
	local padding = true
	local is_commented = U.is_commented(ll, rr, padding)
	local line = vim.api.nvim_buf_get_lines(0, cl - 1, cl, false)
	if next(line) == nil or not is_commented(line[1]) then return end
	local rs, re = cl, cl -- range start and end
	repeat
		rs = rs - 1
		line = vim.api.nvim_buf_get_lines(0, rs - 1, rs, false)
	until next(line) == nil or not is_commented(line[1])
	rs = rs + 1
	repeat
		re = re + 1
		line = vim.api.nvim_buf_get_lines(0, re - 1, re, false)
	until next(line) == nil or not is_commented(line[1])
	re = re - 1
	vim.fn.execute("normal! " .. rs .. "GV" .. re .. "G")
end

keymap("o", "u", commented_lines_textobject, {silent = true})
keymap("o", "Q", commented_lines_textobject, {silent = true})