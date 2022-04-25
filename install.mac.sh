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
}

function configure-bash {
	log-title "Configuring bash"
	rm ~/.bash_profile
	ln -s "$(pwd)/activate.mac.sh" ~/.bash_profile
}

function configure-git {
	log-title "Configuring git"
	git config --global pull.rebase true
	git config --global submodule.recurse true
	git config --global user.name "Carlos Fdez. Llamas"
	git config --global user.email "hello@sirikon.me"
}

function install-asdf {
	[ -d ~/.asdf ] && return

	log-title "Installing asdf vm"
	git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1
}

function log-title {
	printf "\n\e[1m\e[38;5;208m#\e[0m \e[1m%s\e[0m\n" "${1}" 1>&2
}

function log {
	printf "  %s\n" "${1}" 1>&2
}

main "$@"
