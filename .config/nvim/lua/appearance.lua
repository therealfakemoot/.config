require("utils")
-- see also gui-settings.lua

--------------------------------------------------------------------------------
-- STYLING FOR VIM IN TERMINAL

-- Ruler
cmd[[highlight ColorColumn ctermbg=DarkGrey]]

-- Active Line
cmd[[highlight CursorLine term=none cterm=none ctermbg=black]]

-- Indentation Lines
cmd[[highlight IndentBlanklineChar ctermfg=DarkGrey]]

-- Comments
cmd[[highlight Comment ctermfg=grey]]

-- Popup Menus
cmd[[highlight Pmenu ctermbg=DarkGrey]]

-- Line Numbers
cmd[[highlight LineNr ctermfg=DarkGrey]]
cmd[[highlight CursorLineNr ctermfg=Grey]]


--------------------------------------------------------------------------------
-- custom highlights

function customHighlights()
	-- Diagnostics: use straight underlines instead of curly underlines
	cmd[[highlight DiagnosticUnderlineError gui=underline]]
	cmd[[highlight DiagnosticUnderlineWarn gui=underline]]
	cmd[[highlight DiagnosticUnderlineHint gui=underline]]
	cmd[[highlight DiagnosticUnderlineInfo gui=underline]]

	-- leading spaces
	cmd[[highlight WhiteSpaceBol guibg=DarkGrey ctermbg=DarkGrey]]
	cmd[[call matchadd('WhiteSpaceBol', '^ \+')]]

	-- URLs
	cmd[[highlight urls cterm=underline term=underline gui=underline]]
	cmd[[call matchadd('urls', 'http[s]\?:\/\/[[:alnum:]%\/_#.-]*') ]]

	-- Annotations
	cmd[[highlight def link myAnnotations Todo]] -- use same styling as "TODO"
	cmd[[call matchadd('myAnnotations', 'INFO\|TODO\|NOTE\|WARNING\|WARN\|REQUIRED') ]]
end

customHighlights() -- call once for startup / nvim in the Terminal

-- since overriden by some themes, also call after a colorscheme
-- has been loaded
augroup("themeAdditions", {})
autocmd("ColorScheme", {
	group = "themeAdditions",
	callback = customHighlights,
})

--------------------------------------------------------------------------------

-- GUTTER
opt.signcolumn = "yes:1"
cmd[[highlight clear SignColumn]] -- transparent

-- Git Gutter
g.gitgutter_map_keys = 0 -- disable gitgutter mappings I don't use anyway

cmd[[highlight GitGutterAdd    ctermfg=Green]]
cmd[[highlight GitGutterChange ctermfg=Yellow]]
cmd[[highlight GitGutterDelete ctermfg=Red]]
g.gitgutter_sign_added = '│'
g.gitgutter_sign_modified = '│'
g.gitgutter_sign_removed = '–'
g.gitgutter_sign_removed_first_line = '–'
g.gitgutter_sign_removed_above_and_below = '–'
g.gitgutter_sign_modified_removed = '│'
g.gitgutter_sign_priority = 9 -- 10 is used by nvim diagnostics

--------------------------------------------------------------------------------
-- DIAGNOSTICS

-- ▪︎▴• ▲  
-- https://www.reddit.com/r/neovim/comments/qpymbb/lsp_sign_in_sign_columngutter/
local signs = {
	Error = "",
	Warn = "▲",
	Info = "" ,
	Hint = "",
}
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

--------------------------------------------------------------------------------

-- STATUS LINE (LuaLine)
local function alternateFile()
	local altFile = api.nvim_exec('echo expand("#:t")', true)
	local curFile = api.nvim_exec('echo expand("%:t")', true)
	if altFile == curFile or altFile == "" then return "" end
	return "# "..altFile
end

local function currentFile() -- using this function instead of default filename, since this does not show "[No Name]" for Telescope
	local curFile = api.nvim_exec('echo expand("%:t")', true)
	if not(curFile) or curFile == "" then return "" end
	return "%% "..curFile -- "%" is lua's escape character and therefore needs to be escaped itself
end

require('lualine').setup {
	sections = {
		lualine_a = {'mode'},
		lualine_b = {{ currentFile }},
		lualine_c = {{ alternateFile }},
		lualine_x = {'diff'},
		lualine_y = {'diagnostics'},
		lualine_z = {'location', 'progress'},
	},
	options = {
		theme  = 'auto',
		globalstatus = true,
		component_separators = { left = '', right = ''},
		section_separators = { left = ' ', right = ' '}, -- nerd font: 'nf-ple'
	},
}

