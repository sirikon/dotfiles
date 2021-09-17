#!/usr/bin/env bash
set -euo pipefail

apt-get install sudo xorg i3 lightdm
usermod -a -G sudo sirikon
sudo -u sirikon bash -c 'cd && git clone https://github.com/sirikon/dotfiles.git .sirikon && cd .sirikon && ./install.sh'
