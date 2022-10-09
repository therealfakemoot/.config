-- nvim-lint
require('lint').linters_by_ft = {
  sh = { 'shellcheck' },
  zsh = { 'shellcheck' },
  css = { 'stylelint' },
  js = { 'eslint' },
  ts = { 'eslint' },
  yaml = { 'yamllint' },
  markdown = { 'markdownlint' },
  lua = { 'selene' },
}

-- when to lint
augroup("nvimlint", {})
autocmd({ "BufEnter", "InsertLeave", "TextChanged" }, {
	callback = function() require("lint").try_lint() end,
	group = "nvimlint",
})

--------------------------------------------------------------------------------
-- LINTER-SPECIFIC OPTIONS

-- surpress warnings
local stylelintArgs = require("lint.linters.stylelint").args
table.insert(stylelintArgs, 1, "--quiet")

-- fix yamllint config
local yamllintArgs = require("lint.linters.yamllint").args
table.insert(yamllintArgs, 1, '"$HOME/.config/.yamllint.yaml"')
table.insert(yamllintArgs, 1, "--config-file")

-- force zsh linting
local shellcheckArgs = require("lint.linters.shellcheck").args
table.insert(shellcheckArgs, 1, "bash")
table.insert(shellcheckArgs, 1, "--shell")

-- selene
local seleneArgs = require("lint.linters.selene").args
table.insert(seleneArgs, 1, "bash")
table.insert(seleneArgs, 1, "--shell")

