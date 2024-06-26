local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
  config = wezterm.config_builder()
end

config.audible_bell = 'Disabled'

config.color_scheme = 'Bitmute (terminal.sexy)'
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }

return config
