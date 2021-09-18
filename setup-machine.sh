#!/usr/bin/env bash
set -euo pipefail

apt-get install sudo git
usermod -a -G sudo sirikon
sudo -u sirikon bash -c 'cd && git clone https://github.com/sirikon/dotfiles.git .sirikon && cd .sirikon && ./install.sh'
