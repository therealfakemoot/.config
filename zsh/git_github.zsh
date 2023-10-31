# shellcheck disable=SC2164

alias co="git checkout"
alias gs='git status'
alias gd='git diff'
alias gc="git commit -m"
alias ga="git add"
alias gr="git reset"
alias grh="git reset --hard"
alias push="git push"
alias pull="git pull"
alias amend="git commit --amend"

# go to git root https://stackoverflow.com/a/38843585
alias root='r=$(git rev-parse --git-dir) && r=$(cd "$r" && pwd)/ && cd "${r%%/.git/*}"'
alias gg="git checkout -" # go to previous branch/commit, like `zz` switching to last directory


#───────────────────────────────────────────────────────────────────────────────

# GIT LOG

# short
alias gl="git log -n 15 --all --graph --pretty=format:'%C(yellow)%h%C(red)%d%C(reset) %s %C(green)(%ch) %C(bold blue)<%an>%C(reset)' ; echo '(…)'"

# long
# append `true` to avoid exit code 141: https://www.ingeniousmalarkey.com/2016/07/git-log-exit-code-141.html
alias gll="git log --all --graph --pretty=format:'%C(yellow)%h%C(red)%d%C(reset) %s %C(green)(%ch) %C(bold blue)<%an>%C(reset)' ; true"

#───────────────────────────────────────────────────────────────────────────────

# search for [g]it [d]eleted [f]ile
function gdf() {
	if ! command -v fzf &>/dev/null; then echo "fzf not installed." && exit 1; fi
	if ! command -v bat &>/dev/null; then echo "bat not installed." && exit 1; fi

	local deleted_path deletion_commit
	r=$(git rev-parse --git-dir) && r=$(cd "$r" && pwd)/ && cd "${r%%/.git/*}" # goto git root

	# alternative method: `git rev-list -n 1 HEAD -- "**/*$1*"` to get the commit of a deleted file
	deleted_path=$(git log --diff-filter=D --summary | grep delete | grep -i "$*" | cut -d" " -f5-)

	if [[ -z "$deleted_path" ]]; then
		print "🔍\033[1;31m No deleted file found."
		return 1
	elif [[ $(echo "$deleted_path" | wc -l) -gt 1 ]]; then
		print "🔍\033[1;34m Multiple files found."
		selection=$(echo "$deleted_path" | fzf --layout=reverse --height=70%)
		[[ -z "$selection" ]] && return 0
		deleted_path="$selection"
	fi

	deletion_commit=$(git log --format='%h' --follow -- "$deleted_path" | head -n1)
	last_commit=$(git show --format='%h' "$deletion_commit^" | head -n1)
	if [[ -z "$selection" ]] ; then
		print "🔍\033[1;32m One file found:"
	else
		print "🔍\033[1;32m Selected file:"
	fi

	# decision on how to act on file
	echo "$deleted_path"
	print "\033[1;34m"
	echo "[r]estore (checkout file)"
	echo "[s]how file"
	echo "[c]opy content"
	echo "copy [h]ash of last commit w/ file"
	print "[a]bort\033[0m"

	read -r -k 1 DECISION
	# shellcheck disable=SC2193
	if [[ "$DECISION:l" == "c" ]]; then
		git show "$last_commit:$deleted_path" | pbcopy
		echo "Content copied."
	elif [[ "$DECISION:l" == "h" ]]; then
		echo "$last_commit" | pbcopy
		echo "Hash \"$last_commit\" copied."
	elif [[ "$DECISION:l" == "r" ]]; then
		git checkout "$last_commit" -- "$deleted_path"
	elif [[ "$DECISION:l" == "s" ]]; then
		git show "$last_commit:$deleted_path" | bat
	fi
}

#───────────────────────────────────────────────────────────────────────────────
