#!/usr/bin/env bash
set -euo pipefail

ROOT="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
cd "$ROOT"

function main {
    ensure-sudo

    extend-bashrc
    link-i3

    link-bins
    
    apt-install \
        "xorg" "i3" "lightdm" \
        "pulseaudio" "pavucontrol" \
        "dunst" \
        "python3" \
        "fonts-noto-color-emoji" \
        "i3blocks" \
        "gnome-terminal" \
        "maim" \
        "xclip"
}

function ensure-sudo {
    log-title "Ensuring SUDO access"
    sudo printf "%s" ""
    log "SUDO obtained"
}

function extend-bashrc {
    log-title "Extending ~.bashrc"
    if [ "$(grep -c "# Sirikon dotfiles" ~/.bashrc)" == 0 ]; then
        bashrc-fragment >> ~/.bashrc
        log "Done."
    else
        log "Activation script already exists in ~.bashrc. Skipping."
    fi
}

function link-i3 {
    log-title "Linking i3 folders"
    link-folder-if-not-exists "${ROOT}/config/i3" ~/.config/i3
    link-folder-if-not-exists "${ROOT}/config/i3status" ~/.config/i3status
    link-folder-if-not-exists "${ROOT}/config/i3blocks" ~/.config/i3blocks
}

function link-folder-if-not-exists {
    source="$1"
    target="$2"

    if [ ! -d "$target" ]; then
        mkdir -p "$(dirname "$target")"
        ln -s "$source" "$target"
        log "${target} done."
    else
        log "${target} skipped."
    fi
}

function link-bins {(
    log-title "Linking /bin/* to ~/bin/*"
    mkdir -p ~/bin

    cd bin
    for f in *; do
        if [[ -f $f ]]; then
            rm -f ~/bin/$f
            ln -s "$(pwd)/$f" ~/bin/$f
            log "$f -> OK"
        fi
    done
)}

function apt-install {
    log-title "Installing dependencies using APT"
    sudo apt update && sudo apt install "${@}"
}

function bashrc-fragment {
    cat << EOF

# Sirikon dotfiles
source $(pwd)/activate.sh
EOF
}

function log-title {
    printf "\n\e[1m\e[38;5;208m#\e[0m \e[1m%s\e[0m\n" "${1}" 1>&2
}

function log {
    printf "  %s\n" "${1}" 1>&2
}

main "$@"
