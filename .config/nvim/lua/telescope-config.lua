-- https://github.com/nvim-telescope/telescope.nvim#telescope-setup-structure

require("telescope").setup {
	defaults = {
		selection_caret = "ﰉ ",
		prompt_prefix = "❱ ",
		path_display = { "tail" },
		file_ignore_patterns = {
			"packer_compiled.lua",
			"%.DS_Store",
			"%.git/",
			"%.spl",
			"%.log",
			"%[No Name%]", -- new files / sometimes folders (netrw)
			"/$", -- ignore folders (netrw)
			"node_modules",
			"%.png",
			"%.zip",
			"%.pxd",
			"Spoons/", -- Hammerspoon spoons
			"info.plist", -- Alfred Config Data
		},
		mappings = {
			i = {
				["<Esc>"] = "close", -- close w/ one esc
				["?"] = "which_key",
			},
			n = {
				q = "close",
				["<Esc>"] = "close",
			},
		},
		layout_strategy = 'horizontal',
		layout_config = {
			horizontal = {
				height = 0.95,
				preview_cutoff = 70,
				width = 0.92,
				preview_width = {0.55, max = 50}
			},
			bottom_pane = {
				height = 12,
				preview_cutoff = 70,
				prompt_position = "bottom",
			},
		},
	},

	pickers = {
		lsp_references = {
			prompt_prefix='⬅️',
			show_line=false,
			trim_text=true,
			include_declaration=false,
			initial_mode = "normal",
		},
		lsp_definitions = {
			prompt_prefix='➡️',
			show_line=false,
			trim_text=true,
			initial_mode = "normal",
		},
		lsp_document_symbols = {
			prompt_prefix='* ',
			show_line = false,
		},
		treesitter = {
			prompt_prefix=' ',
			show_line = false,
		},
		find_files = {
			cwd='%:p:h',
			prompt_prefix=' ',
			hidden = true,
			follow = true,
		},
		keymaps = { prompt_prefix='? ' },
		oldfiles = { prompt_prefix=' ' },
		highlights = { prompt_prefix=' ' },
		git_files = {
			prompt_prefix=' ',
			show_untracked = true,
			path_display = { "tail" },
		},
		buffers = {
			prompt_prefix='﬘ ',
			ignore_current_buffer = true,
			initial_mode = "normal",
			sort_mru = true,
		},
		live_grep = {
			cwd='%:p:h',
			disable_coordinates=true,
			prompt_title='Search in Folder',
			prompt_prefix=' ',
		},
		spell_suggest = {
			initial_mode = "normal",
			prompt_prefix = "暈",
			theme = "cursor",
			layout_config = { cursor = { width = 0.3 } }
		},
		colorscheme = {
			enable_preview = true,
			prompt_prefix = '',
			results_title = '',
			layout_strategy = "bottom_pane",
		},
	},

	extensions = {
		["ui-select"] = { -- mostly code actions
			initial_mode = "normal",
			prompt_prefix = "  ",
			results_title = '',
			layout_strategy = "bottom_pane",
			sorting_strategy = "ascending",
			layout_config = { bottom_pane = { height = 8 } },
		}
	}
}

--------------------------------------------------------------------------------

-- have to be loaded after telescope config
require("telescope").load_extension("ui-select") -- use telescope for selections like code actions

