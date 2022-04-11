from typing import List, Optional, Tuple
from dataclasses import dataclass
from subprocess import run, PIPE
from os import path

from . import log


@dataclass
class Repository():
    kind: str
    url: str
    areas: List[str]
    arch: Optional[str] = None
    key: Optional[Tuple[str, str]] = None
    trusted: bool = False


@dataclass
class Pin():
    package: str
    release: str
    priority: int


def enable_i386():
    run(['dpkg', '--add-architecture', 'i386'])


def set_repositories(*apt_repositories: List[Repository]):
    apt_list = open('/etc/apt/sources.list.d/sirikon.list', 'w')

    for apt_repository in apt_repositories:
        ensure_keyring(apt_repository)
        repo_line = build_repo_line(apt_repository)
        apt_list.write(repo_line + '\n')

    apt_list.close()
    apt_already_refreshed = False


def ensure_keyring(apt_repository: Repository):
    if apt_repository.key is None:
        return

    keyring_file_path = get_keyring_file_path(apt_repository)
    if path.isfile(keyring_file_path):
        return

    name = apt_repository.key[0]
    url = apt_repository.key[1]
    log.subtitle(f'Installing key {name}...')
    run(['bash', '-c',
        f'curl -fsSL "{url}" | gpg --dearmor -o "{keyring_file_path}"'])


def get_keyring_file_path(apt_repository: Repository):
    return '/usr/share/keyrings/' + apt_repository.key[0] + '-archive-keyring.gpg' if apt_repository.key is not None \
        else None


def build_repo_line(apt_repository: Repository):
    kind = apt_repository.kind
    url = apt_repository.url
    keyring_file_path = get_keyring_file_path(apt_repository)
    params = []

    if apt_repository.arch is not None:
        params.append('arch=' + apt_repository.arch)
    if apt_repository.trusted:
        params.append('trusted=yes')
    if keyring_file_path is not None:
        params.append('signed-by=' + keyring_file_path)

    params_chunk = ' [' + ' '.join(params) + '] ' if len(params) > 0 else ' '
    areas_chunk = ' '.join(apt_repository.areas)

    return f'{kind}{params_chunk}{url} {areas_chunk}'


def set_pins(*pins: List[Pin]):
    apt_preferences = open('/etc/apt/preferences.d/99sirikon', 'w')

    for pin in pins:
        apt_preferences.write('\n'.join([
            'Package: ' + pin.package,
            'Pin: release ' + pin.release,
            'Pin-Priority: ' + str(pin.priority),
            '\n'
        ]))

    apt_preferences.close()
    global apt_already_refreshed
    apt_already_refreshed = False


apt_already_refreshed = False


def refresh_apt_packages():
    global apt_already_refreshed
    if apt_already_refreshed:
        return
    log.title('Refreshing APT packages')
    run(['apt-get', 'update'])
    apt_already_refreshed = True


def ensure_packages(*packages):
    installed_apt_packages = get_installed_apt_packages()
    packages_to_install = list(
        filter(lambda pkg: pkg not in installed_apt_packages, packages))
    if len(packages_to_install) == 0:
        return

    refresh_apt_packages()
    log.title('Ensuring APT packages')
    print('Packages to instal:' + (', '.join(packages_to_install)))
    run(['apt-get', 'install', '-y', *packages_to_install])


def get_installed_apt_packages():
    lines = run(['bash', '-c', 'dpkg --get-selections | grep -v deinstall'], stdout=PIPE, text=True)\
        .stdout.strip().split('\n')
    return [line.split('\t')[0] for line in lines]
