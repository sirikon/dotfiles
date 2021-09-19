#!/usr/bin/env bash
set -euo pipefail

ROOT="$(realpath "$(dirname "${BASH_SOURCE[0]}")")"
cd "$ROOT"

function main {
    ensure-sudo

    apt-install \
        "apt-transport-https" "ca-certificates" \
        "curl" "git" "gnupg" "lsb-release"

    configure-extra-repositories

    apt-install \
        "xorg" "i3" "lightdm" \
        "network-manager" "network-manager-gnome" \
        "firefox-esr" "vim" "arandr" \
        "pulseaudio" "pavucontrol" \
        "nitrogen" "dunst" \
        "python3" "python3-pip" "python3-venv" \
        "fwupd" \
        "fonts-noto-color-emoji" \
        "i3blocks" \
        "xfce4-terminal" \
        "maim" "blueman" \
        "xclip" \
        "docker-ce" "docker-ce-cli" "containerd.io" \
        "dbeaver-ce" "sublime-text" "sublime-merge"

    install-pipx
    install-asdf

    link-i3
    link-xfce4-terminal
    link-sublime-merge
    link-x

    link-bins

    configure-git
    configure-networking
    configure-docker-user

    extend-bashrc
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

function install-pipx {
    log-title "Installing pipx"
    pip3 install pipx
}

function install-asdf {
    log-title "Installing asdf vm"
    if [ ! -d ~/.asdf ]; then
        git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.1
    fi
}

function link-i3 {
    log-title "Linking i3 folders"
    link-force "${ROOT}/config/i3" ~/.config/i3
    link-force "${ROOT}/config/i3status" ~/.config/i3status
    link-force "${ROOT}/config/i3blocks" ~/.config/i3blocks
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
}

function configure-git {
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

function configure-extra-repositories {
    log-title "Configuring extra repositories"

    curl -s https://dbeaver.io/debs/dbeaver.gpg.key | sudo apt-key add -
    echo "deb https://dbeaver.io/debs/dbeaver-ce /" | sudo tee /etc/apt/sources.list.d/dbeaver.list

    curl -s https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

    sudo rm -f /usr/share/keyrings/docker-archive-keyring.gpg
    curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
}

function apt-install {
    log-title "Installing dependencies using APT"
    sudo apt update && sudo apt install -y "${@}"
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
