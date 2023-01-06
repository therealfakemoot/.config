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
	git = { name = "git" }, -- mentions with "@", issues/PRs with "#"
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

	-- gitcommit
	cmp.setup.filetype("gitcommit", {
		sources = cmp.config.sources {
			s.git,
			s.path,
			s.buffer,
			s.emojis,
		},
	})

	cmp.setup.filetype("NeogitCommitMessage", {
		sources = cmp.config.sources {
			s.git,
			s.path,
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
	{ -- git-related completion
		"petertriho/cmp-git",
		lazy = true,
		config = function()
			require("cmp_git").setup {
				filetypes = { "gitcommit", "NeogitCommitMessage" },
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
		"windwp/nvim-autopairs",
		dependencies = "hrsh7th/nvim-cmp",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup()
			-- add brackets to cmp
			local cmp_autopairs = require("nvim-autopairs.completion.cmp")
			require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
		end,
	},
	{
		"L3MON4D3/LuaSnip",
		event = "InsertEnter",
		config = function()
			require("config/snippets") -- loads all snippets
			local ls = require("luasnip")

			ls.setup {
				enable_autosnippets = true,
				history = false, -- false = allow jumping back into the snippet
				region_check_events = "InsertEnter", -- prevent <Tab> jumping back to a snippet after it has been left early
				update_events = "TextChanged,TextChangedI", -- live updating of snippets
			}

			-- to be able to jump without <Tab> (e.g. when there is a non-needed suggestion)
			vim.keymap.set({ "i", "s" }, "<D-j>", function()
				if require("luasnip").expand_or_jumpable() then
					require("luasnip").jump(1)
				else
					vim.notify("No Jump available.", vim.log.levels.WARN)
				end
			end)
			vim.keymap.set({ "i", "s" }, "<D-S-j>", function()
				if require("luasnip").jumpable(-1) then
					require("luasnip").jump(-1)
				else
					vim.notify("No Jump back available.", vim.log.levels.WARN)
				end
			end)

			-- needs to come after snippet definitions
			ls.filetype_extend("typescript", { "javascript" }) -- typescript uses all javascript snippets
			ls.filetype_extend("bash", { "zsh" })
			ls.filetype_extend("sh", { "zsh" })
			ls.filetype_extend("scss", { "css" })
		end,
	},
}
