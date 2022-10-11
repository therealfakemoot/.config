require("utils")
--------------------------------------------------------------------------------

local cmp = require('cmp')

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
	Snippet = "",
	Color = "",
	File = "",
	Reference = "",
	Folder = "",
	EnumMember = "",
	Constant = "",
	Struct = "",
	Event = "",
	Operator = "",
	TypeParameter = ""
}

cmp.setup({
	snippet = { -- REQUIRED a snippet engine must be specified and installed
		expand = function(args) require('luasnip').lsp_expand(args.body) end,
	},
	experimental = { ghost_text = true },

	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},

	mapping = {
		['<Tab>'] = cmp.mapping.select_next_item(),
		['<S-Tab>'] = cmp.mapping.select_prev_item(),
		['<Down>'] = cmp.mapping.select_next_item(),
		['<Up>'] = cmp.mapping.select_prev_item(),
		['<Esc>'] = cmp.mapping.close(), -- close() leaves the current text, abort() restores pre-completion situation
		['<CR>'] = cmp.mapping.confirm({ select = true }),
		['<S-Up>'] = cmp.mapping.scroll_docs(-4),
		['<S-Down>'] = cmp.mapping.scroll_docs(4),
	},

	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		{ name = 'luasnip' },
		{ name = 'emoji', keyword_length = 2 },
		{ name = 'buffer', keyword_length = 2 },
	}),
	formatting = {
		format = function(entry, vim_item)
			-- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
			vim_item.kind = kind_icons[vim_item.kind]
			vim_item.menu = ({
				buffer = "[B]",
				nvim_lsp = "[LSP]",
				luasnip = "[S]",
			})[entry.source.name]
			return vim_item
		end
	},

	-- disable completion in comments https://github.com/hrsh7th/nvim-cmp/wiki/Advanced-techniques#disabling-completion-in-certain-contexts-such-as-comments
	enabled = function()
		local context = require 'cmp.config.context'
		if vim.api.nvim_get_mode().mode == 'c' then -- keep command mode completion enabled when cursor is in a comment
			return true
		else
			return not context.in_treesitter_capture("comment")
			and not context.in_syntax_group("Comment")
		end
	end
})

--------------------------------------------------------------------------------
-- autopairs
require("nvim-autopairs").setup {}

-- add brackets to cmp
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on( 'confirm_done', cmp_autopairs.on_confirm_done())

--------------------------------------------------------------------------------
-- Filetype specific Completion

-- disable leading "-" and comments
cmp.setup.filetype ("lua", {
	enabled = function()
		local context = require 'cmp.config.context'
		if api.nvim_get_mode().mode == 'c' then -- keep command mode completion enabled when cursor is in a comment
			return true
		elseif fn.getline("."):match("%s*%-+") then ---@diagnostic disable-line: undefined-field
			return false
		else
			return not context.in_treesitter_capture("comment")
			and not context.in_syntax_group("Comment")
		end
	end
})

-- don't use buffer in css completions
cmp.setup.filetype ("css", {
	sources = {
		{ name = 'nvim_lsp' },
		{ name = 'cmp-nvim-lsp-signature-help' },
		{ name = 'luasnip' },
	}, {
		{ name = 'emoji', keyword_length = 2 },
	}
})

--------------------------------------------------------------------------------
-- Command Line Completion

cmp.setup.cmdline({ '/', '?' }, {
	mapping = cmp.mapping.preset.cmdline(),
	sources = {
		{ name = 'buffer', max_item_count = 20, keyword_length = 4 }
	}
})

-- if a path can be matched, omit the rest. If a cmd can be matched, omit
-- history
cmp.setup.cmdline(':', {
	mapping = cmp.mapping.preset.cmdline(),
	sources = cmp.config.sources({
		{ name = 'path' }
	}, {
		{ name = 'cmdline', max_item_count = 15 },
	}, {
		{ name = 'cmdline_history', max_item_count = 15 },
	})
})


