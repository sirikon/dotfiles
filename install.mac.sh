#!/usr/bin/env bash
set -euo pipefail
export PATH=/opt/homebrew/bin:$PATH

brew install coreutils bash jq

ROOT="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
cd "$ROOT"

function main {
	mkdir -p ~/bin
	install-asdf
	configure-bash
	configure-git
	configure-dropbox-links
}

function configure-bash {
	log-title "Extending ~.bash_profile"
	if [ "$(grep -c "# Sirikon dotfiles" ~/.bash_profile)" == 0 ]; then
		bashprofile-fragment >>~/.bash_profile
		log "Done."
	else
		log "Activation script already exists in ~.bash_profile. Skipping."
	fi
}

function bashprofile-fragment {
	cat <<EOF

# Sirikon dotfiles
source $(pwd)/activate.mac.sh
EOF
}

function configure-git {
	log-title "Configuring git"
	git config --global pull.rebase true
	git config --global submodule.recurse true
	git config --global user.name "Carlos Fdez. Llamas"
	git config --global user.email "hello@sirikon.me"
}

function configure-dropbox-links {
	[ ! -d ~/Dropbox/ProgramData ] && return 0
	log-title "Configuring Dropbox links"

	link-force ~/Dropbox/ProgramData/DBeaver/General ~/Library/DBeaverData/workspace6/General
}

function install-asdf {
	[ -d ~/.asdf ] && return

	log-title "Installing asdf vm"
	git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1
}

function link-force {
	source="$1"
	target="$2"

	rm -rf "$target"
	mkdir -p "$(dirname "$target")"
	ln -s "$source" "$target"
	log "${target} done."
}

function log-title {
	printf "\n\e[1m\e[38;5;208m#\e[0m \e[1m%s\e[0m\n" "${1}" 1>&2
}

function log {
	printf "  %s\n" "${1}" 1>&2
}

main "$@"
