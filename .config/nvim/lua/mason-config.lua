require("mason").setup({
	ui = {
		icons = {
			package_installed = "✓",
			package_pending = "➜",
			package_uninstalled = "✗"
		}
	}
})
require("mason-lspconfig").setup({
	-- this plugin uses the lspconfig servernames, not mason servernames https://github.com/williamboman/mason-lspconfig.nvim/blob/main/doc/server-mapping.md
	ensure_installed = {
		"sumneko_lua",
		"yamlls",
		"tsserver",
		"marksman",
		"jsonls",
		"cssls",
		"bashls",
	},
})

-- Mappings.
local opts = { noremap=true, silent=true }
vim.keymap.set('n', 'ge', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', 'gE', vim.diagnostic.goto_prev, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local bufopts = { noremap=true, silent=true, buffer=bufnr }
	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
	vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, bufopts)
	vim.keymap.set('n', 'gD', vim.lsp.buf.references, bufopts)
	vim.keymap.set('n', '<leader>h', vim.lsp.buf.hover, bufopts)
	vim.keymap.set('n', '<leader>R', vim.lsp.buf.rename, bufopts)
	vim.keymap.set('n', '<leader>,', vim.lsp.buf.code_action, bufopts)
end

local lsp_flags = {
	debounce_text_changes = 150, -- This is the default in Nvim 0.7+
}
require('lspconfig')['tsserver'].setup{
	on_attach = on_attach,
	flags = lsp_flags,
}
require('lspconfig')['sumneko_lua'].setup{
	on_attach = on_attach,
	flags = lsp_flags,
}
