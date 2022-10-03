require("utils")
--------------------------------------------------------------------------------
-- GUI (Neovide)
g.neovide_transparency = 0.97
g.neovide_confirm_quit = false
g.neovide_scroll_animation_length = 0.1
g.neovide_cursor_animation_length = 0.08
g.neovide_cursor_trail_size = 0.4
g.neovide_remember_window_size = true
g.neovide_hide_mouse_when_typing = true
g.neovide_input_use_logo = true -- cmd key on macOS
g.neovide_input_macos_alt_is_meta = false -- makes alt usable on mac (TODO: but needs to remap @)
opt.guifont = "JetBrainsMonoNL Nerd Font:h28"

if fn.has('gui_running') or g.neovide then
	-- keep using terminal colorscheme in the Terminal, for consistency with Alacritty
	cmd[[colorscheme onedark]]
else
	cmd[[highlight clear Pmenu]]
end

--------------------------------------------------------------------------------
-- UI ELEMENTS
-- partially overriden when using a theme

-- Ruler
cmd[[highlight ColorColumn ctermbg=DarkGrey guibg=black]] -- https://www.reddit.com/r/neovim/comments/me35u9/lua_config_to_set_highlight/

-- Active Line
cmd[[highlight CursorLine term=none cterm=none guibg=black ctermbg=black]]

-- Current Word Highlight (from Coc)
cmd[[highlight CocHighlightText term=underdotted cterm=underdotted]]

-- TreeSitter Context Line
cmd[[highlight TreesitterContext ctermbg=black guibg=black]]

-- Indentation Lines
cmd[[highlight IndentBlanklineChar ctermfg=DarkGrey guifg=DarkGrey]]

-- Comments
cmd[[highlight Comment ctermfg=grey]]

--------------------------------------------------------------------------------
-- custom highlights

-- leading spaces
cmd[[highlight WhiteSpaceBol guibg=DarkGrey ctermbg=DarkGrey]]
cmd[[call matchadd('WhiteSpaceBol', '^ \+')]]

-- Annotations
cmd[[highlight def link myAnnotations Todo]] -- use same styling as "TODO"
cmd[[call matchadd('myAnnotations', 'INFO\|TODO\|NOTE') ]]

-- Underline URLs
cmd[[highlight urls cterm=underline]]
cmd[[call matchadd('urls', 'http[s]\?:\/\/[[:alnum:]%\/_#.-]*') ]]

--------------------------------------------------------------------------------

-- GUTTER
cmd[[highlight clear SignColumn]] -- transparent

-- Git Gutter
cmd[[highlight GitGutterAdd    guifg=Green  ctermfg=Green]]
cmd[[highlight GitGutterChange guifg=Yellow ctermfg=Yellow]]
cmd[[highlight GitGutterDelete guifg=Red    ctermfg=Red]]
g.gitgutter_sign_added = '│'
g.gitgutter_sign_modified = '│'
g.gitgutter_sign_removed = '–'
g.gitgutter_sign_removed_first_line = '⎺'
g.gitgutter_sign_removed_above_and_below = '␥'
g.gitgutter_sign_modified_removed = '│'
g.gitgutter_sign_priority = 9 -- lower to not overwrite when in conflict with other icons
-- INFO: Coc Gutter indicators set in coc-settings.json

--------------------------------------------------------------------------------

-- STATUS LINE (LuaLine)
local function alternateFile()
	local altFile = api.nvim_exec('echo expand("#:t")', true)
	local curFile = api.nvim_exec('echo expand("%:t")', true)
	if altFile == curFile then return "" end
	return "# "..altFile
end

local function currentFile() -- using this function instead of default filename, since this does not show "[No Name]" for Telescope
	local curFile = api.nvim_exec('echo expand("%:t")', true)
	if not(curFile) then return "" end
	return "%% "..curFile -- "%" is lua's escape character and therefore needs to be escaped itself
end

require('lualine').setup {
	sections = {
		lualine_a = {{ 'mode', fmt = function(str) return str:sub(1,1) end }},
		lualine_b = {{ currentFile }},
		lualine_c = {{ alternateFile }},
		lualine_x = {'diff'},
		lualine_y = {{'diagnostics', sources = { 'nvim_diagnostic', 'coc', 'ale' }}},
		lualine_z = {'location', 'progress'}
	},
	options = {
		theme  = 'auto',
		globalstatus = true,
		component_separators = { left = '', right = ''},
		section_separators = { left = '', right = ''},
	},
}

--------------------------------------------------------------------------------
-- WILDMENU

-- INFO: "UpdateRemotePlugins" may be necessary to make wilder work correctly
-- https://github.com/gelguy/wilder.nvim/issues/158

local wilder = require('wilder')
wilder.setup({modes = {':', '/', '?'}})
wilder.set_option('renderer', wilder.popupmenu_renderer(
	wilder.popupmenu_border_theme({
		highlighter = wilder.basic_highlighter(),
		min_width = '30%',
		min_height = '30%',
		max_height = '50%',
		left = {' ', wilder.popupmenu_devicons()},
		reverse = 0,
		border = 'rounded',
		highlights = {
			accent = wilder.make_hl('WilderAccent', 'Pmenu', {
				{foreground = 'Magenta'}, -- term
				{foreground = 'Magenta'}, -- cterm
				{foreground = '#f4468f'} -- gui
			}),
		},
	})
))



