from subprocess import run, PIPE
from .modules import apt, devices

def main():
    apt.ensure_packages(
        'apt-transport-https', 'ca-certificates', 'curl', 'git',
        'gnupg', 'lsb-release', 'debian-archive-keyring'
    )

    apt.set_repositories(
        # Debian extras
        apt.Repository('deb', 'http://deb.debian.org/debian', ['bullseye', 'contrib', 'non-free']),
        apt.Repository('deb-src', 'http://deb.debian.org/debian', ['bullseye', 'contrib', 'non-free']),
        apt.Repository('deb', 'http://deb.debian.org/debian-security/', ['bullseye-security', 'contrib', 'non-free']),
        apt.Repository('deb-src', 'http://deb.debian.org/debian-security/', ['bullseye-security', 'contrib', 'non-free']),

        apt.Repository('deb', 'http://deb.debian.org/debian', ['buster', 'main']),
        apt.Repository('deb-src', 'http://deb.debian.org/debian', ['buster', 'main']),

        apt.Repository('deb', 'http://deb.debian.org/debian', ['unstable', 'main']),
        apt.Repository('deb-src', 'http://deb.debian.org/debian', ['unstable', 'main']),

        # Others
        apt.Repository('deb', 'https://dbeaver.io/debs/dbeaver-ce', ['/'],
            key=('dbeaver', 'https://dbeaver.io/debs/dbeaver.gpg.key')),

        apt.Repository('deb', 'https://download.sublimetext.com/', ['apt/stable/'],
            key=('sublimehq', 'https://download.sublimetext.com/sublimehq-pub.gpg')),

        apt.Repository('deb', 'https://download.docker.com/linux/debian', [get_debian_version_name(), 'stable'],
            key=('docker', 'https://download.docker.com/linux/debian/gpg')),

        apt.Repository('deb', 'https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs', ['vscodium', 'main'],
            key=('vscodium', 'https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg')),

        apt.Repository('deb', 'http://repository.spotify.com', ['stable', 'non-free'],
            key=('spotify', 'https://download.spotify.com/debian/pubkey_0D811D58.gpg')),

        apt.Repository('deb', 'https://download.virtualbox.org/virtualbox/debian', [get_debian_version_name(), 'contrib'],
            key=('virtualbox', 'https://www.virtualbox.org/download/oracle_vbox_2016.asc'), arch='amd64'),

        apt.Repository('deb', 'https://download.konghq.com/insomnia-ubuntu/', ['default', 'all'],
            trusted=True, arch='amd64')
    )

    apt.set_pins(
        apt.Pin(package='*', release='o=Debian,n=buster', priority=1),
        apt.Pin(package='*', release='o=Debian,a=unstable', priority=1),
        apt.Pin(package='libnss3', release='o=Debian,a=unstable', priority=500),
        apt.Pin(package='*', release='o=packagecloud.io/slacktechnologies/slack', priority=1),
        apt.Pin(package='*', release='l=insomnia-ubuntu', priority=1)
    )

    apt.ensure_packages(
        *devices.get_required_apt_packages(),
        "xorg", "i3", "lightdm",
        "network-manager", "network-manager-gnome",
        "firefox", "chromium", "vim", "arandr",
        "pulseaudio", "pavucontrol", "spotify-client",
        "nitrogen", "dunst", "thunar",
        "python3", "python3-pip", "python3-venv", "python3-gpg",
        "fwupd", "policykit-1-gnome",
        "fonts-noto-color-emoji", "linux-headers-amd64",
        "i3blocks", "vlc", "gpicview",
        "xfce4-terminal", "jq", "qbittorrent",
        "maim", "blueman", "codium", "insomnia",
        "xclip", "xz-utils", "keepassxc",
        "docker-ce", "docker-ce-cli", "containerd.io",
        "dbeaver-ce", "sublime-text", "sublime-merge",
        "zenity", "xss-lock", "virtualbox-6.1"
    )

    devices.configure_xorg_graphics_card()


def get_debian_version_name():
    return run(['lsb_release', '-cs'], stdout=PIPE, text=True).stdout.strip()

main()
