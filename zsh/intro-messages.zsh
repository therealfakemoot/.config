# shellcheck disable=SC2164,SC1009,SC1073,SC1056

# requirements:
# - cowsay
# - fortune

if [[ "$TERM" == "alacritty" ]] ; then
	arr[1]=""   # standard
	arr[2]="-b" # Borg Mode
	arr[3]="-d" # dead
	arr[4]="-g" # greedy
	arr[5]="-p" # paranoia
	arr[6]="-s" # stoned
	arr[7]="-t" # tired
	arr[8]="-w" # wake/wired
	arr[9]="-y" # youthful
	rand=$((RANDOM % ${#arr[@]}))
	random_emotion=${arr[$rand]}

	cow_maxwidth=70
	width=$(($(tput cols) - 10))
	[[ $width -gt $cow_maxwidth ]] && width=$cow_maxwidth

	if [[ $((RANDOM%2)) == 1 ]] ; then
		say_or_think="cowsay"
	else
		say_or_think="cowthink"
	fi

	# shellcheck disable=SC2248
	fortune -n270 -s | sed 's/--/\n--/g' | $say_or_think -W$width $random_emotion
	echo

	# shellcheck disable=SC2012
	if [[ $(ls | wc -l) -lt 20 ]] && [[ $(ls | wc -l) -gt 0 ]] ; then
		separator
		exa
		echo
	fi
fi
