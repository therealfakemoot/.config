-- TODO structure plugins as suggested here: https://github.com/folke/lazy.nvim#-structuring-your-plugins
--------------------------------------------------------------------------------
-- Bootstrap Lazy.nvim plugin manager https://github.com/folke/lazy.nvim#-installation
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		"git",
		"clone",
		"--filter=blob:none",
		"--single-branch",
		"https://github.com/folke/lazy.nvim.git",
		lazypath,
	}
end
vim.opt.runtimepath:prepend(lazypath)

--------------------------------------------------------------------------------
-- config https://github.com/folke/lazy.nvim#%EF%B8%8F-configuration
require("lazy").setup("config/load-plugins", {
	defaults = {
		-- version = "*", -- install the latest *stable* versions of plugins
	},
	dev = {
		-- alternative setup method https://www.reddit.com/r/neovim/comments/zk187u/how_does_everyone_segment_plugin_development_from/
		path = vim.fn.stdpath("config") .. "/my-plugins/",
	},
	ui = {
		border = borderStyle,
		size = { width = 1, height = 1 }, -- full width
	},
	checker = {
		enabled = true, -- automatically check for plugin updates
		notify = false, -- get a notification when new updates are found
		frequency = 86400, -- check for updates every 24 hours
	},
	change_detection = {
		notify = false,
	},
	performance = {
		rtp = { -- plugins names to disable
			disabled_plugins = {},
		},
	},
})

-- disable default `K` from lazy
augroup("lazyKeymaps", {})
autocmd({ "FileType" }, {
	group = "lazyKeymaps",
	pattern = "lazy",
	callback = function()
      g.cursorPreYank = getCursor(0)
   end,
})

