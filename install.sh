#!/usr/bin/env bash
set -euo pipefail

ROOT="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
cd "$ROOT"

function main {
    if [ "$(grep -c "# Sirikon dotfiles" ~/.bashrc)" == 0 ]; then
        bashrc-fragment >> ~/.bashrc
    else
        printf "%s\n" "Activation script already exists in .bashrc"
    fi

    if [ -d ~/.config/i3 ]; then
        printf "%s\n" "i3 config directory already exists"
    else
        ln -s "${ROOT}/config/i3" ~/.config/i3
    fi

    if [ -d ~/.config/i3status ]; then
        printf "%s\n" "i3status config directory already exists"
    else
        ln -s "${ROOT}/config/i3status" ~/.config/i3status
    fi
}

function bashrc-fragment {
    cat << EOF

# Sirikon dotfiles
source $(pwd)/activate.sh
EOF
}

main "$@"
