#!/usr/bin/env python3
from typing import Optional, List, Tuple
from subprocess import run, PIPE
from dataclasses import dataclass
from os import path

def main():
    ensure_sudo()
    refresh_apt_packages()

    ensure_apt_packages(
        'apt-transport-https', 'ca-certificates', 'curl', 'git',
        'gnupg', 'lsb-release', 'debian-archive-keyring'
    )

    set_apt_repositories(
        # Debian extras
        APTRepository('deb', 'http://deb.debian.org/debian bullseye contrib non-free'),
        APTRepository('deb-src', 'http://deb.debian.org/debian bullseye contrib non-free'),
        APTRepository('deb', 'http://deb.debian.org/debian-security/ bullseye-security contrib non-free'),
        APTRepository('deb-src', 'http://deb.debian.org/debian-security/ bullseye-security contrib non-free'),

        # Others
        APTRepository('deb', 'https://dbeaver.io/debs/dbeaver-ce /',
            key=('dbeaver', 'https://dbeaver.io/debs/dbeaver.gpg.key')),
        APTRepository('deb', 'https://download.sublimetext.com/ apt/stable/',
            key=('sublimehq', 'https://download.sublimetext.com/sublimehq-pub.gpg')),
        APTRepository('deb', 'https://download.docker.com/linux/debian ' + get_debian_version_name() + ' stable',
            key=('docker', 'https://download.docker.com/linux/debian/gpg')),
        APTRepository('deb', 'https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs vscodium main',
            key=('vscodium', 'https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg'))
    )

    refresh_apt_packages()

    update_pciids()

    ensure_apt_packages(
        *get_apt_packages_for_devices(),
        "xorg", "i3", "lightdm",
        "network-manager", "network-manager-gnome",
        "firefox-esr", "vim", "arandr",
        "pulseaudio", "pavucontrol",
        "nitrogen", "dunst", "thunar",
        "python3", "python3-pip", "python3-venv", "python3-gpg",
        "fwupd", "policykit-1-gnome",
        "fonts-noto-color-emoji",
        "i3blocks", "vlc", "gpicview",
        "xfce4-terminal", "jq", "qbittorrent",
        "maim", "blueman", "codium",
        "xclip", "xz-utils", "keepassxc",
        "docker-ce", "docker-ce-cli", "containerd.io",
        "dbeaver-ce", "sublime-text", "sublime-merge",
        "zenity"
    )

def ensure_sudo():
    log_title('Ensuring SUDO')
    run(['sudo', 'printf', '%s', ''])
    log_subtitle('SUDO obtained')

def update_pciids():
    log_title('Update PCI Id database')
    run(['sudo', 'update-pciids'])

def get_apt_packages_for_devices():
    log_title('Selecting apt packages for devices')
    pci_list = run(['lspci'], stdout=PIPE, text=True).stdout.strip().splitlines()
    result = {
        'firmware-linux',
        'firmware-linux-free',
        'firmware-linux-nonfree',
        'firmware-misc-nonfree'
    }

    for pci in pci_list:
        if 'VGA' in pci:
            if 'AMD' in pci:
                result.add('firmware-amd-graphics')
        if 'Realtek' in pci:
            result.add('firmware-realtek')
        if 'Intel' in pci and 'Wireless' in pci:
            result.add('firmware-iwlwifi')

    result_list = list(result)
    result_list.sort()

    for item in result_list:
        log_subtitle(item)
    return result_list

def refresh_apt_packages():
    log_title('Refreshing APT packages')
    run(['sudo', 'apt-get', 'update'])

def ensure_apt_packages(*packages):
    installed_apt_packages = get_installed_apt_packages()
    packages_to_install = list(filter(lambda pkg: pkg not in installed_apt_packages, packages))
    if len(packages_to_install) == 0: return

    log_title('Installing APT packages')
    log_subtitle(', '.join(packages_to_install))
    run(['sudo', 'apt-get', 'install', '-y', *packages_to_install])

def get_installed_apt_packages():
    lines = run(['bash', '-c', 'dpkg --get-selections | grep -v deinstall'], stdout=PIPE, text=True)\
        .stdout.strip().split('\n')
    return [line.split('\t')[0] for line in lines]

@dataclass
class APTRepository():
    kind: str
    url: str
    arch: Optional[str] = None
    key: Optional[Tuple[str, str]] = None

def set_apt_repositories(*apt_repositories: List[APTRepository]):
    log_title('Setting APT repositories')
    apt_list_path = '/etc/apt/sources.list.d/sirikon.list'
    run(['sudo', 'bash', '-c', f'rm -f "{apt_list_path}"'])
    run(['sudo', 'touch', apt_list_path])
    for apt_repository in apt_repositories:

        keyring_file_path = '/usr/share/keyrings/' + apt_repository.key[0] + '-archive-keyring.gpg' \
            if apt_repository.key is not None else None

        if apt_repository.key is not None:
            name = apt_repository.key[0]
            url = apt_repository.key[1]
            if not path.isfile(keyring_file_path):
                log_subtitle(f'  Installing key {name}...')
                run(['bash', '-c', f'curl -fsSL {url} | sudo gpg --dearmor -o {keyring_file_path}'])

        kind = apt_repository.kind
        url = apt_repository.url
        params = []
        if apt_repository.arch is not None: params.append('arch=' + apt_repository.arch)
        if keyring_file_path is not None: params.append('signed-by=' + keyring_file_path)
        params_chunk = ' [' + ' '.join(params) + '] ' if len(params) > 0 else ' '

        line = f'{kind}{params_chunk}{url}'
        log_subtitle(line)
        run(['sudo', 'bash', '-c', f'echo "{line}" >> "{apt_list_path}"'])

def get_debian_version_name():
    return run(['lsb_release', '-cs'], stdout=PIPE, text=True).stdout.strip()

first_line = True
def log_title(title):
    global first_line
    if not first_line:
        print()
    first_line = False
    print(f'\033[1m\033[38;5;208m#\033[0m \033[1m{title}\033[0m')

def log_subtitle(subtitle):
    print('  ' + subtitle)

main()
