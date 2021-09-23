#!/usr/bin/env bash
set -euo pipefail

ROOT="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
cd "$ROOT"

function main {
    (
        export PYTHONPATH="${PYTHONPATH:-""}:$ROOT"
        sudo -E python3 -m installer
    )

    install-pipx
    install-asdf
    install-telegram
    install-docker-compose

    link-i3
    link-vscodium
    link-xfce4-terminal
    link-sublime-merge
    link-x
    link-bins

    configure-dropbox-links
    configure-git
    configure-networking
    configure-docker-user

    extend-bashrc
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

function install-pipx {
    command -v pipx >/dev/null && return
    
    log-title "Installing pipx"
    pip3 install pipx
}

function install-asdf {
    [ -d ~/.asdf ] && return
    
    log-title "Installing asdf vm"
    git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1
}

function install-telegram {
    [ -d ~/Software/Telegram ] && return

    log-title "Installing telegram"
    (
        mkdir -p ~/Software/Telegram
        cd ~/Software/Telegram
        wget -O telegram.tar.xz https://telegram.org/dl/desktop/linux
        tar -xf telegram.tar.xz
        mv Telegram t
        mv t/* .
        rmdir t
        rm telegram.tar.xz
        mkdir -p ~/bin
        ln -s "$(pwd)/Telegram" ~/bin/telegram
    )
}

function install-docker-compose {
    command -v docker-compose >/dev/null && return

    log-title "Installing docker-compose"
    ~/.local/bin/pipx install docker-compose
}

function link-i3 {
    log-title "Linking i3 folders"
    link-force "${ROOT}/config/i3" ~/.config/i3
    link-force "${ROOT}/config/i3status" ~/.config/i3status
    link-force "${ROOT}/config/i3blocks" ~/.config/i3blocks
}

function link-vscodium {
    log-title "Linking VSCodium settings"
    link-force "${ROOT}/config/vscode/settings.json" ~/.config/VSCodium/User/settings.json
}

function link-xfce4-terminal {
    log-title "Linking xfce4-terminal config"
    link-force "${ROOT}/config/xfce4-terminal/terminalrc" ~/.config/xfce4/terminal/terminalrc
}

function link-sublime-merge {
    log-title "Linking sublime merge config"
    link-force "${ROOT}/config/sublime-merge/Preferences.sublime-settings" ~/.config/sublime-merge/Packages/User/Preferences.sublime-settings
}

function link-x {
    log-title "Linking X config"
    link-force "${ROOT}/config/x/Xresources" ~/.Xresources
    link-force "${ROOT}/config/x/xsessionrc" ~/.xsessionrc
}

function configure-git {
    log-title "Configuring git"
    git config --global pull.rebase true
    git config --global user.name "Carlos Fdez. Llamas"
    git config --global user.email "hello@sirikon.me"
}

function configure-networking {
    log-title "Configuring networking"

    sudo systemctl disable systemd-networkd systemd-networkd.socket systemd-networkd-wait-online
    sudo systemctl stop systemd-networkd systemd-networkd.socket systemd-networkd-wait-online

    sudo systemctl disable systemd-resolved
    sudo systemctl stop systemd-resolved

    sudo rm -f /etc/network/interfaces

    sudo systemctl enable NetworkManager
    sudo systemctl start NetworkManager
}

function configure-dropbox-links {
    log-title "Configuring Dropbox links"
    [ ! -d ~/Dropbox/ProgramData ] && return 0

    link-force ~/Dropbox/ProgramData/DBeaver/General ~/.local/share/DBeaverData/workspace6/General
    link-force ~/Dropbox/ProgramData/qBittorrent/BT_backup ~/.local/share/data/qBittorrent/BT_backup
}

function configure-docker-user {
    log-title "Configuring docker user"
    sudo groupadd docker || echo "Group already exists"
    sudo usermod -aG docker "$USER"
}

function link-force {
    source="$1"
    target="$2"

    rm -rf "$target"
    mkdir -p "$(dirname "$target")"
    ln -s "$source" "$target"
    log "${target} done."
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
