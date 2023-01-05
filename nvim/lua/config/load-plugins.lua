return {
	-- Themes
	"EdenEast/nightfox.nvim",
	"folke/tokyonight.nvim",
	-- "rose-pine/neovim",
	-- "rebelot/kanagawa.nvim",
	-- "nyoom-engineering/oxocarbon.nvim",
	"glepnir/zephyr-nvim",
	"savq/melange",

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = function() -- auto-update parsers on start: https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#packernvim
			require("nvim-treesitter.install").update { with_sync = true }
		end,
		dependencies = {
			"nvim-treesitter/nvim-treesitter-refactor",
			"nvim-treesitter/nvim-treesitter-textobjects",
			"p00f/nvim-ts-rainbow", -- WARN: no longer maintained
		},
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			"lvimuser/lsp-inlayhints.nvim", -- only temporarily needed, until https://github.com/neovim/neovim/issues/18086
			"ray-x/lsp_signature.nvim", -- signature hint
			"SmiteshP/nvim-navic", -- breadcrumbs for statusline/winbar
			"folke/neodev.nvim", -- lsp for nvim-lua config
			"b0o/SchemaStore.nvim", -- schemas for json-lsp
		},
	},

	-- Linting & Formatting
	{
		"jose-elias-alvarez/null-ls.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"jayp0521/mason-null-ls.nvim",
		},
	},

	-- Misc
	{
		"chrisgrieser/nvim-genghis",
		dev = true,
		lazy = true,
		dependencies = "stevearc/dressing.nvim",
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		config = function()
			vim.opt.timeoutlen = 700 -- duration until which-key is shown
			require("which-key").setup {
				window = {
					border = "none", -- none to save space
					padding = { 0, 0, 0, 0 },
					margin = { 0, 0, 0, 0 },
				},
				layout = { -- of the columns
					height = { min = 4, max = 17 },
					width = { min = 20, max = 33 },
					spacing = 1,
				},
			}
		end,
	},
	{
		"axieax/urlview.nvim",
		cmd = "UrlView",
		dependencies = "nvim-telescope/telescope.nvim",
		config = function()
			require("urlview").setup {
				default_picker = "telescope",
				default_action = "system",
				sorted = false,
			}
		end,
	},
	"Darazaki/indent-o-matic", -- auto-determine indents

	-- Filetype-specific
	{ "mityu/vim-applescript", ft = "applescript" }, -- syntax highlighting
	{ "hail2u/vim-css3-syntax", ft = "css" }, -- better syntax highlighting (until treesitter css looks decent…)
	{ "iamcco/markdown-preview.nvim", ft = "markdown", build = "cd app && npm install" },
}
