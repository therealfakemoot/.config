require("utils")
--------------------------------------------------------------------------------

-- THEME
-- keep using terminal colorscheme in the Terminal, for consistency with
-- Alacritty looks
if fn.has('gui_running') == 1 then -- https://www.reddit.com/r/neovim/comments/u1998d/comment/i4asi0h/?utm_source=share&utm_medium=web2x&context=3
	cmd[[colorscheme tokyonight]]
end

--------------------------------------------------------------------------------
-- UI ELEMENTS
-- partially overriden when using a theme

-- Ruler
cmd('highlight ColorColumn ctermbg=0 guibg=black') -- https://www.reddit.com/r/neovim/comments/me35u9/lua_config_to_set_highlight/

-- Active Line
cmd('highlight CursorLine term=bold cterm=bold guibg=black ctermbg=black')

--------------------------------------------------------------------------------
-- LUA LINE

local function alternateFile()
	local altFile = api.nvim_exec('echo expand("#:t")', true)
	local thisFile = api.nvim_exec('echo expand("%:t")', true)
	if altFile ~= thisFile then
		return "#"..altFile
	else
		return ""
	end
end

local function currentFile()
	local thisFile = api.nvim_exec('echo expand("%:t")', true)
	return "%"..thisFile
end

require('lualine').setup {
	sections = {
		lualine_a = {{ 'mode', fmt = function(str) return str:sub(1,1) end }},
		-- lualine_b = {{ currentFile }},
		lualine_c = {{ alternateFile }},
		lualine_x = {''},
		lualine_y = {'diagnostics'},
		lualine_z = {'location', 'progress'}
	},
	options = {
		theme  = 'auto',
		component_separators = { left = '', right = ''},
		section_separators = { left = '', right = '' },
	},
}



