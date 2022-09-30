function PluginList (use)
	use 'wbthomason/packer.nvim' -- packer manages itself

	-- Themes
	use 'folke/tokyonight.nvim' -- color scheme

	-- Appearance
	use "lukas-reineke/indent-blankline.nvim" -- indentation guides
	use "unblevable/quick-scope" -- highlight for f & t
	use 'nvim-lualine/lualine.nvim' -- statusbar (w/o requiring icons, since I don't use them)
	use 'airblade/vim-gitgutter'
	-- use 'nvim-treesitter/nvim-treesitter'
	-- use { 'nvim-treesitter/nvim-treesitter-context', requires = {'nvim-treesitter/nvim-treesitter'} }
	-- use { 'nvim-ts-rainbow', requires = {'nvim-treesitter/nvim-treesitter'} }

	-- LSP & Syntax
	use {'neoclide/coc.nvim', branch = 'release'}

	-- Utility
	use 'dstein64/vim-startuptime' -- measure startup time with `:StartupTime`
	use 'tpope/vim-eunuch' -- file operation utilities
	use { 'nvim-telescope/telescope.nvim', -- fuzzy finder
		requires = { 'nvim-lua/plenary.nvim', 'kyazdani42/nvim-web-devicons' }
	}

	-- Editing
	use 'tpope/vim-commentary' -- comments operator & text object
	use 'tpope/vim-abolish' -- various case conversions
	use 'mg979/vim-visual-multi' -- multi-cursor
	use {'tpope/vim-surround', requires = 'tpope/vim-repeat'} -- surround with punctuation
	use 'Raimondi/delimitMate' -- auto-close brackets & quotes in insert mode (Alternative: cohama/lexima.vim)
	use 'michaeljsmith/vim-indent-object' -- indention text objects
	use 'svermeulen/vim-subversive' -- replacement operator
	use 't9md/vim-textmanip' -- line swapping & duplication

end


