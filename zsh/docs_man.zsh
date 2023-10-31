# colorize less https://wiki.archlinux.org/index.php/Color_output_in_console#less .
export LESS_TERMCAP_mb=$'\E[1;31m' # begin bold
export LESS_TERMCAP_md=$'\E[1;33m' # begin blink = YELLOW
export LESS_TERMCAP_me=$'\E[0m'    # reset bold/blink
export LESS_TERMCAP_us=$'\E[1;35m' # begin underline = MAGENTA
export LESS_TERMCAP_ue=$'\E[0m'    # reset underline

# Pager-specific settings
# INFO: less' ignore-case is actually smart-case
export LESS='-R --incsearch --ignore-case --window=-3 --quit-if-one-screen --no-init --tilde'
