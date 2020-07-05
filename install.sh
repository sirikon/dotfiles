#!/usr/bin/env bash
set -euo pipefail

ROOT="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
cd "$ROOT"

function main {
    extend-bashrc

    link-folder-if-not-exists "${ROOT}/config/i3" ~/.config/i3
    link-folder-if-not-exists "${ROOT}/config/i3status" ~/.config/i3status
    link-folder-if-not-exists "${ROOT}/config/i3blocks" ~/.config/i3blocks

    pacman-install \
        vim dmenu gnome-terminal i3blocks firefox pamac \
        pavucontrol terminus-font noto-fonts-emoji ttf-dejavu \
        polkit-gnome nitrogen openssh code xorg-xbacklight \
        keepassxc zenity

    prevent-dropbox-self-update
}

function extend-bashrc {
    if [ "$(grep -c "# Sirikon dotfiles" ~/.bashrc)" == 0 ]; then
        bashrc-fragment >> ~/.bashrc
    else
        printf "%s\n" "Activation script already exists in .bashrc"
    fi
}

function link-folder-if-not-exists {
    source="$1"
    target="$2"

    if [ ! -d "$source" ]; then
        ln -s "$source" "$target"
    else
        printf "%s\n" "Link: skipping ${source}"
    fi
}

function pacman-install {
    if command -v pacman &> /dev/null; then
        sudo pacman -Syu --needed "$@"
    else
        printf "%s\n" "pacman not found. Skipping"
    fi
}

function prevent-dropbox-self-update {
    # https://wiki.archlinux.org/index.php/Dropbox#Prevent_automatic_updates
    rm -rf ~/.dropbox-dist
    install -dm0 ~/.dropbox-dist
}

function bashrc-fragment {
    cat << EOF

# Sirikon dotfiles
source $(pwd)/activate.sh
EOF
}

main "$@"
