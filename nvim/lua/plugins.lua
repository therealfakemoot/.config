return {

	-- Treesitter
	{
		"nvim-treesitter/nvim-treesitter",
		build = function() -- auto-update parsers on start: https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation#packernvim
			require("nvim-treesitter.install").update { with_sync = true }
		end,
		dependencies = {
			"nvim-treesitter/nvim-treesitter-refactor",
			"nvim-treesitter/nvim-treesitter-textobjects",
			"mrjones2014/nvim-ts-rainbow",
		},
	},

	-- LSP
	{
		"neovim/nvim-lspconfig",
		dependencies = {
			"williamboman/mason.nvim",
			"kosayoda/nvim-lightbulb",
			"williamboman/mason-lspconfig.nvim",
			"lvimuser/lsp-inlayhints.nvim", -- only temporarily needed, until https://github.com/neovim/neovim/issues/18086
			"ray-x/lsp_signature.nvim", -- signature hint
			"SmiteshP/nvim-navic", -- breadcrumbs for statusline/winbar
			"folke/neodev.nvim", -- lsp for nvim-lua config
			"b0o/SchemaStore.nvim", -- schemas for json-lsp
		},
	},
	{
		"kosayoda/nvim-lightbulb",
		lazy = true,
		config = function()
			vim.fn.sign_define("LightBulbSign", { text = "" })

			-- HACK since ignore options does not work https://github.com/kosayoda/nvim-lightbulb/issues/39
			require("nvim-lightbulb").setup { autocmd = { enabled = false } }
			vim.api.nvim_create_augroup("lightbulb-fix", {})
			vim.api.nvim_create_autocmd({ "CursorHold" }, {
				group = "lightbulb-fix",
				callback = function()
					require("nvim-lightbulb").update_lightbulb {
						ignore = {
							"sumneko_lua", -- only non-diagnostic code action is to change roder of parameters, which is not very useful and mostly noise
							"marksman", -- marksman adds the "Update ToC" code action everywhere
						},
					}
				end,
			})
		end,
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
			vim.opt.timeoutlen = 1200 -- duration until which-key is shown
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

	-- Filetype-specific
	{ "mityu/vim-applescript", ft = "applescript" }, -- syntax highlighting
	{ "hail2u/vim-css3-syntax", ft = "css" }, -- better syntax highlighting (until treesitter css looks decent…)
	{ "iamcco/markdown-preview.nvim", ft = "markdown", build = "cd app && npm install" },
}
