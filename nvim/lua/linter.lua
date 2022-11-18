require("utils")
--------------------------------------------------------------------------------

-- INFO: linters also need to be added as source below
-- these require the null-ls name, not the mason name: https://github.com/jayp0521/mason-null-ls.nvim#available-null-ls-sources
local lintersAndFormatters = {
	"eslint_d",
	"shellcheck",
	"yamllint",
	"markdownlint",
	"proselint",
	"write_good",
	-- stylelint not available :(
}

--------------------------------------------------------------------------------
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTIN_CONFIG.md
-- https://github.com/jose-elias-alvarez/null-ls.nvim/blob/main/doc/BUILTINS.md

local null_ls = require("null-ls")
local builtins = null_ls.builtins

null_ls.setup {
	sources = {
		builtins.code_actions.gitsigns, -- gitsings.nvim plugin, e.g. reset hunks

		builtins.diagnostics.zsh, -- basic diagnostics via shell -x
		builtins.diagnostics.shellcheck.with {-- `bashls` and `diagnosticls` both do not work for zsh shellcheck; `efm` depends on go
			extra_filetypes = {"zsh"},
			extra_args = {"--shell=bash"},
		},
		builtins.code_actions.shellcheck.with {
			extra_filetypes = {"zsh"},
			extra_args = {"--shell=bash"},
		},

		builtins.formatting.stylelint.with {
			-- using config without ordering, since ordering on save is confusing
			extra_args = {"--config", dotfilesFolder.."/.stylelintrc-formatting.json"},
		},
		builtins.diagnostics.stylelint.with {-- not using stylelint-lsp due to: https://github.com/bmatcuk/stylelint-lsp/issues/36
			extra_args = {"--quiet"}, -- only errors, no warnings
		},

		-- builtins.formatting.eslint_d,
		builtins.code_actions.eslint_d,
		builtins.diagnostics.eslint_d.with {
			extra_args = {"--quiet"}, -- only errors, no warnings
		},

		builtins.diagnostics.yamllint.with {
			extra_args = {"--config-file", fn.expand("~/.config/yamllint/config/.yamllint.yaml")},
		},

		builtins.diagnostics.write_good.with{
			extra_args = {"--no-passive", "--no-adverb"}, -- disable those rules
		},
		builtins.diagnostics.proselint,
		builtins.diagnostics.markdownlint.with {
			extra_args = {"--disable=trailing-spaces"}, -- vim already takes care of that
		},
		builtins.hover.dictionary, -- vim's builtin dictionary
		builtins.formatting.markdownlint,
		builtins.completion.spell.with {-- vim's built-in spell-suggestions
			filetypes = {"markdown"},
		},

	},
}

--------------------------------------------------------------------------------
-- mason-null-ls should be loaded after null-ls and mason
-- https://github.com/jayp0521/mason-null-ls.nvim#setup

require("mason-null-ls").setup {
	ensure_installed = lintersAndFormatters,
}
