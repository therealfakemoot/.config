-- source definitions
local s = {
	emojis = { name = "emoji", keyword_length = 2 },
	nerdfont = { name = "nerdfont", keyword_length = 2 },
	buffer = { name = "buffer", keyword_length = 3 },
	path = { name = "path" },
	zsh = { name = "zsh" },
	tabnine = { name = "cmp_tabnine", keyword_length = 3 },
	snippets = { name = "luasnip" },
	lsp = { name = "nvim_lsp" },
	treesitter = { name = "treesitter" },
	cmdline_history = { name = "cmdline_history", keyword_length = 3 },
	cmdline = { name = "cmdline" },
}

local defaultSources = {
	s.snippets,
	s.lsp,
	s.tabnine,
	s.emojis,
	s.treesitter,
	s.buffer,
}

--------------------------------------------------------------------------------

local kind_icons = {
	Text = "",
	Method = "",
	Function = "",
	Constructor = "",
	Field = "",
	Variable = "",
	Class = "ﴯ",
	Interface = "",
	Module = "",
	Property = "ﰠ",
	Unit = "",
	Value = "",
	Enum = "",
	Keyword = "",
	Snippet = "",
	Color = "",
	File = "",
	Reference = "",
	Folder = "",
	EnumMember = "",
	Constant = "",
	Struct = "",
	Event = "",
	Operator = "",
	TypeParameter = "",
}

local source_icons = {
	buffer = "﬘",
	treesitter = "",
	zsh = "",
	nvim_lsp = "璉",
	cmp_tabnine = "ﮧ",
	luasnip = "ﲖ",
	emoji = "",
	nerdfont = "",
	cmdline = "",
	cmdline_history = "",
	path = "",
	omni = "", -- since only used for folders right now
	git = "",
}

local function cmpconfig()
	local cmp = require("cmp")
	local compare = require("cmp.config.compare")

	cmp.setup {
		snippet = {
			-- REQUIRED a snippet engine must be specified and installed
			expand = function(args) require("luasnip").lsp_expand(args.body) end,
		},
		window = {
			completion = {
				side_padding = 0,
				border = borderStyle,
			},
			documentation = {
				border = borderStyle,
			},
		},
		sorting = {
			comparators = {
				compare.offset,
				-- compare.exact, -- disable exact matches getting higher priority https://github.com/hrsh7th/nvim-cmp/blob/main/lua/cmp/config/default.lua#L57
				-- compare.scopes,
				compare.score,
				compare.recently_used,
				compare.locality,
				compare.kind,
				compare.sort_text,
				compare.length,
				compare.order,
			},
		},
		mapping = cmp.mapping.preset.insert {
			["<CR>"] = cmp.mapping.confirm { select = true }, -- true = autoselect first entry
			["<S-Up>"] = cmp.mapping.scroll_docs(-4),
			["<S-Down>"] = cmp.mapping.scroll_docs(4),
			["<C-e>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.abort()
				else
					fallback()
				end
			end, { "i", "s" }),

			-- expand or jump in luasnip snippet https://github.com/hrsh7th/nvim-cmp/wiki/Example-mappings#luasnip
			["<Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				else
					fallback()
				end
			end, { "i", "s" }),
			["<S-Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				else
					fallback()
				end
			end, { "i", "s" }),
		},
		formatting = {
			fields = { "kind", "abbr", "menu" }, -- order of the fields
			format = function(entry, vim_item)
				vim_item.kind = " " .. kind_icons[vim_item.kind] .. " "
				vim_item.menu = source_icons[entry.source.name]
				return vim_item
			end,
		},
		-- DEFAULT SOURCES
		sources = cmp.config.sources(defaultSources),
	}
	--------------------------------------------------------------------------------
	-- FILETYPE SPECIFIC COMPLETION

	cmp.setup.filetype("lua", {
		enabled = function() -- disable leading "-"
			local lineContent = vim.fn.getline(".") ---@diagnostic disable-line: param-type-mismatch
			return not (lineContent:match(" %-%-?$") or lineContent:match("^%-%-?$")) ---@diagnostic disable-line: undefined-field
		end,
		sources = cmp.config.sources {
			s.snippets,
			s.lsp,
			s.tabnine,
			s.nerdfont, -- add nerdfont for config
			s.emojis,
			s.treesitter,
			s.buffer,
		},
	})

	cmp.setup.filetype("toml", {
		sources = cmp.config.sources {
			s.snippets,
			s.lsp,
			s.tabnine,
			s.nerdfont, -- add nerdfont for config
			s.emojis,
			s.treesitter,
			s.buffer,
		},
	})

	-- css
	cmp.setup.filetype("css", {
		sources = cmp.config.sources {
			s.snippets,
			s.lsp,
			s.tabnine,
			s.emojis,
			-- buffer and treesitter too slow on big files
		},
	})

	-- markdown
	cmp.setup.filetype("markdown", {
		sources = cmp.config.sources {
			s.snippets,
			s.path, -- e.g. image paths
			s.lsp,
			s.emojis,
			-- no buffer or tabnine, since only adding noise
		},
	})

	cmp.setup.filetype("yaml", {
		sources = cmp.config.sources {
			s.lsp,
			s.snippets,
			s.treesitter, -- treesitter works good on yaml
			s.tabnine,
			s.emojis,
			s.buffer,
		},
	})

	-- ZSH
	cmp.setup.filetype("sh", {
		sources = cmp.config.sources {
			s.snippets,
			s.zsh,
			s.lsp,
			s.path,
			s.tabnine,
			s.treesitter,
			s.buffer,
			s.emojis,
			s.nerdfont, -- used for some configs
		},
	})

	-- bibtex
	cmp.setup.filetype("bib", {
		sources = cmp.config.sources {
			s.snippets,
			s.treesitter,
			s.buffer,
		},
	})

	-- plaintext (e.g., pass editing)
	cmp.setup.filetype("text", {
		sources = cmp.config.sources {
			s.snippets,
			s.buffer,
			s.emojis,
		},
	})

	--------------------------------------------------------------------------------
	-- Command Line Completion
	cmp.setup.cmdline({ "/", "?" }, {
		mapping = cmp.mapping.preset.cmdline(),
		sources = {}, -- empty cause all suggestions do not help much?
	})

	cmp.setup.cmdline(":", {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({
			s.path,
			s.cmdline,
		}, { -- second array only relevant when no source from the first matches
			s.cmdline_history,
		}),
	})

	-- Enable Completion in DressingInput
	cmp.setup.filetype("DressingInput", {
		sources = cmp.config.sources { { name = "omni" } },
	})
end
--------------------------------------------------------------------------------

return {
	{
		"hrsh7th/nvim-cmp",
		event = { "InsertEnter", "CmdlineEnter" }, -- CmdlineEnter for completions there
		dependencies = {
			"hrsh7th/cmp-buffer", -- completion sources
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"dmitmel/cmp-cmdline-history",
			"hrsh7th/cmp-emoji",
			"chrisgrieser/cmp-nerdfont",
			"tamago324/cmp-zsh",
			"ray-x/cmp-treesitter",
			"petertriho/cmp-git",
			"hrsh7th/cmp-nvim-lsp", -- lsp
			"L3MON4D3/LuaSnip", -- snippet
			"saadparwaiz1/cmp_luasnip", -- adapter for snippet engine
			"hrsh7th/cmp-omni", -- omni for autocompletion in input prompts
		},
		config = cmpconfig,
	},
	{
		"petertriho/cmp-git",
		lazy = true, -- is being loaded by cmp
		dependencies = "nvim-lua/plenary.nvim",
		config = function()
			local cmp = require("cmp")
			cmp.setup.filetype("gitcommit", {
				sources = cmp.config.sources {
					{ name = "git" },
				},
			})

			require("cmp_git").setup {
				git = { commits = { limit = 0 } }, -- 0 = disable completing commits
				github = {
					issues = {
						limit = 100,
						state = "open", -- open, closed, all
					},
					mentions = {
						limit = 100,
					},
					pull_requests = {
						limit = 10,
						state = "open",
					},
				},
			}
		end,
	},

	{
		"hrsh7th/nvim-insx",
		config = function()
			local insx = require("insx")
			local esc = insx.helper.regex.esc

			-- Endwise (experimental).
			local endwise = require("insx.recipe.endwise")
			insx.add("<CR>", endwise.recipe(endwise.builtin))

			-- Quotes
			for open, close in pairs {
				["'"] = "'",
				['"'] = '"',
				["`"] = "`",
			} do
				-- Auto pair.
				insx.add(
					open,
					require("insx.recipe.auto_pair") {
						open = open,
						close = close,
						ignore_pat = [[\\\%#]],
					}
				)

				-- Jump next.
				insx.add(
					close,
					require("insx.recipe.jump_next") {
						jump_pat = {
							[[\%#]] .. esc(close) .. [[\zs]],
						},
					}
				)

				-- Delete pair.
				insx.add(
					"<BS>",
					require("insx.recipe.delete_pair") {
						open_pat = esc(open),
						close_pat = esc(close),
					}
				)
			end

			-- Pairs.
			for open, close in pairs {
				["("] = ")",
				["["] = "]",
				["{"] = "}",
				["<"] = ">",
			} do
				-- Auto pair.
				insx.add(
					open,
					require("insx.recipe.auto_pair") {
						open = open,
						close = close,
					}
				)

				-- Jump next.
				insx.add(
					close,
					require("insx.recipe.jump_next") {
						jump_pat = {
							[[\%#]] .. esc(close) .. [[\zs]],
						},
					}
				)

				-- Delete pair.
				insx.add(
					"<BS>",
					require("insx.recipe.delete_pair") {
						open_pat = esc(open),
						close_pat = esc(close),
					}
				)

				-- Increase/decrease spacing.
				insx.add(
					"<Space>",
					require("insx.recipe.pair_spacing").increase {
						open_pat = esc(open),
						close_pat = esc(close),
					}
				)
				insx.add(
					"<BS>",
					require("insx.recipe.pair_spacing").decrease {
						open_pat = esc(open),
						close_pat = esc(close),
					}
				)

				-- Break pairs: `(|)` -> `<CR>` -> `(<CR>|<CR>)`
				insx.add(
					"<CR>",
					require("insx.recipe.fast_break") {
						open_pat = esc(open),
						close_pat = esc(close),
					}
				)

				-- Wrap next token: `(|)func(...)` -> `)` -> `(func(...)|)`
				insx.add(
					"<C-;>",
					require("insx.recipe.fast_wrap") {
						close = close,
					}
				)
			end

			-- Remove HTML Tag: `<div>|</div>` -> `<BS>` -> `|`
			insx.add(
				"<BS>",
				require("insx.recipe.delete_pair") {
					open_pat = insx.helper.search.Tag.Open,
					close_pat = insx.helper.search.Tag.Close,
				}
			)

			-- Break HTML Tag: `<div>|</div>` -> `<BS>` -> `<div><CR>|<CR></div>`
			insx.add(
				"<CR>",
				require("insx.recipe.fast_break") {
					open_pat = insx.helper.search.Tag.Open,
					close_pat = insx.helper.search.Tag.Close,
				}
			)
		end,
	},
	-- {
	-- 	"windwp/nvim-autopairs",
	-- 	dependencies = "hrsh7th/nvim-cmp",
	-- 	event = "InsertEnter",
	-- 	config = function()
	-- 		require("nvim-autopairs").setup()
	--
	-- 		-- add brackets to cmp completions, e.g. "function" -> "function()"
	-- 		local cmp_autopairs = require("nvim-autopairs.completion.cmp")
	-- 		require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
	-- 	end,
	-- },

	-----------------------------------------------------------------------------

	{
		"L3MON4D3/LuaSnip",
		event = "InsertEnter",
		config = function()
			local ls = require("luasnip")

			ls.setup {
				history = false, -- false = allow jumping back into the snippet
				region_check_events = "InsertEnter", -- prevent <Tab> jumping back to a snippet after it has been left early
				update_events = "TextChanged,TextChangedI", -- live updating of snippets
				enable_autosnippets = true,
			}

			-- SPELLING
			-- INFO using these instead of vim abbreviations since they do not work with
			-- added extra undo points
			local spellAutoFixes = {}
			local spellfixes = require("config.spell-autocorrects")
			for _, wordPair in pairs(spellfixes) do
				-- lsp-style-snippets for future-proofness
				local parsed = ls.parser.parse_snippet(wordPair[1], wordPair[2])
				table.insert(spellAutoFixes, parsed)
			end
			ls.add_snippets("all", spellAutoFixes, {
				type = "autosnippets",
				key = "all_auto",
			})

			-- VS-code-style snippets
			-- INFO has to be loaded after the regular luasnip-snippets
			require("luasnip.loaders.from_vscode").lazy_load { paths = "./snippets" }
		end,
	},
}
