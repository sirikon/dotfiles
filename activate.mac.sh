#!/usr/bin/env bash
clear

export PATH=/opt/homebrew/bin:~/bin:$PATH
. ~/.asdf/asdf.sh
. ~/.asdf/completions/asdf.bash

function git_branch {
	branch=$(git branch 2>/dev/null | grep '^\*' | colrm 1 2)
	if [ "$branch" == "" ]; then
		echo ""
	else
		echo "[${branch}] "
	fi
}

function python_venv {
	if [ "$VIRTUAL_ENV" == "" ]; then
		echo ""
	else
		echo "[🐍$(basename ${VIRTUAL_ENV})] "
	fi
}

function prompt-normal {
	PS1="\[\033[38;5;208m\]\u\[$(tput sgr0)\]\[\033[38;5;15m\] \[\033[38;5;248m\]\w \$(git_branch)\$(python_venv)\[$(tput sgr0)\]\[\033[38;5;214m\]\\$\[$(tput sgr0)\] "
	export PS1
}

function prompt-tiny {
	PS1="\[\033[38;5;214m\]\\$\[$(tput sgr0)\] "
	export PS1
}

function upgrade-xcodes { (
	mkdir -p ~/Software/xcodes
	cd ~/Software/xcodes
	rm -rf *
	latest_version=$(curl --silent "https://api.github.com/repos/RobotsAndPencils/xcodes/releases/latest" | jq -r ".tag_name")
	printf "%s\n\n" "Downloading xcodes ${latest_version}"
	curl -Lo "xcodes.zip" "https://github.com/RobotsAndPencils/xcodes/releases/download/${latest_version}/xcodes.zip"
	unzip "xcodes.zip"
	rm -f ~/bin/xcodes
	ln -s $(pwd)/xcodes ~/bin/xcodes
); }

prompt-normal
