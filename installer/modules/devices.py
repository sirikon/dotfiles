from subprocess import run, PIPE

from . import log

def get_required_apt_packages():
    update_pciids()

    log.title('Selecting apt packages for devices')
    pci_list = get_pci_list()

    result = {
        'firmware-linux',
        'firmware-linux-free',
        'firmware-linux-nonfree',
        'firmware-misc-nonfree'
    }

    for pci in pci_list:
        if 'VGA' in pci and 'AMD' in pci:
            result.add('firmware-amd-graphics')
        if 'Realtek' in pci:
            result.add('firmware-realtek')
        if 'Atheros' in pci:
            result.add('firmware-atheros')
        if 'Intel' in pci and 'Wireless' in pci:
            result.add('firmware-iwlwifi')

    result_list = list(result)
    result_list.sort()

    for item in result_list:
        log.subtitle(item)

    return result_list


def configure_xorg_graphics_card():
    log.title('Configuring xorg graphics card')
    brand = get_graphics_card_brand()
    log.subtitle('Brand: ' + brand)

    filename = ''
    content = ''

    if brand == 'amd':
        filename = '20-amdgpu.conf'
        content = [
            'Section "Device"',
            '     Identifier "AMD"',
            '     Driver "amdgpu"',
            '     Option "TearFree" "true"',
            'EndSection',
            ''
        ]
    elif brand == 'intel':
        filename = '20-intel.conf'
        content = [
            'Section "Device"',
            '     Identifier "Intel Graphics"',
            '     Driver "intel"',
            '     Option "TearFree" "true"',
            'EndSection',
            ''
        ]
        
    with open(f'/etc/X11/xorg.conf.d/{filename}', 'w') as f:
        f.writelines(content)


def get_graphics_card_brand():
    pci_list = get_pci_list()
    for pci in pci_list:
        if 'VGA' in pci:
            if 'AMD' in pci: return 'amd'
            if 'Intel' in pci: return 'intel'


pciids_already_updated = False
def update_pciids():
    global pciids_already_updated
    if pciids_already_updated: return

    log.title('Update PCI Id database')
    run(['update-pciids'])
    pciids_already_updated = True



def get_pci_list():
    return run(['lspci'], stdout=PIPE, text=True).stdout.strip().splitlines()
