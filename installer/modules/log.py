first_line = True
def title(title):
    global first_line
    if not first_line:
        print()
    first_line = False
    print(f'\033[1m\033[38;5;208m#\033[0m \033[1m{title}\033[0m')

def subtitle(subtitle):
    print('  ' + subtitle)
