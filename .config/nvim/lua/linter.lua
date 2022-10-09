-- nvim-lint
require('lint').linters_by_ft = {
  sh = { 'shellcheck' },
  zsh = { 'shellcheck' },
  css = { 'stylelint' },
  js = { 'eslint' },
  ts = { 'eslint' },
}

-- when to lint
augroup("nvimlint", {})
autocmd({ "BufEnter", "InsertLeave" }, {
	callback = function() require("lint").try_lint() end,
	group = "nvimlint",
})

--------------------------------------------------------------------------------
-- LINTER-SPECIFIC OPTIONS

local stylelintArgs = require("lint.linters.stylelint").args
table.insert(stylelintArgs, 1, "--quiet")

local shellcheckArgs = require("lint.linters.shellcheck").args
table.insert(shellcheckArgs, 1, "bash")
table.insert(shellcheckArgs, 1, "--shell")
