#!/usr/bin/env bash

# Add sbin to PATH
export PATH=/usr/local/sbin:/usr/sbin:/sbin:$PATH

# Add asdf
. ~/.asdf/asdf.sh
. ~/.asdf/completions/asdf.bash

# Prevent virtualenv automatic prompt
export VIRTUAL_ENV_DISABLE_PROMPT=1

alias ll="ls -lahF"

function git_branch {
	branch=$(git branch 2>/dev/null | grep '^\*' | colrm 1 2)
	if [ "$branch" == "" ]; then
		echo ""
	else
		echo "[${branch}] "
	fi
}

function python_venv {
	if [ "$VIRTUAL_ENV" == "" ]; then
		echo ""
	else
		echo "[🐍$(basename ${VIRTUAL_ENV})] "
	fi
}

function prompt-normal {
	PS1="\[\033[38;5;208m\]\u\[$(tput sgr0)\]\[\033[38;5;15m\] \[\033[38;5;248m\]\w \$(git_branch)\$(python_venv)\[$(tput sgr0)\]\[\033[38;5;214m\]\\$\[$(tput sgr0)\] "
	export PS1
}

function prompt-tiny {
	PS1="\[\033[38;5;214m\]\\$\[$(tput sgr0)\] "
	export PS1
}

function docker-destroy {
	docker ps -aq | while IFS=$'\n' read -r containerId; do
		docker rm -f "$containerId"
	done
	docker volume prune -f
	docker network prune -f
}

function docker-prune {
	docker-destroy
	docker image prune -af
}

function used-ports {
	sudo lsof -i -P -n | grep LISTEN
}

function sm {
	smerge -n .
}

function patch-vscodium-marketplace {
	productJson="/usr/share/codium/resources/app/product.json"
	cat "${productJson}" |
		jq '.extensionsGallery.serviceUrl = "https://marketplace.visualstudio.com/_apis/public/gallery"' |
		jq '.extensionsGallery.itemUrl = "https://marketplace.visualstudio.com/items"' |
		jq -M |
		sudo tee "${productJson}" >/dev/null
}

function upgrade-minecraft-launcher { (
	mkdir -p ~/Downloads/MinecraftLauncher
	cd ~/Downloads/MinecraftLauncher
	rm -f Minecraft.deb
	wget "https://launcher.mojang.com/download/Minecraft.deb"
	sudo apt install ./Minecraft.deb
); }

function upgrade-discord { (
	mkdir -p ~/Downloads/Discord
	cd ~/Downloads/Discord
	rm -f discord.deb
	wget -O discord.deb "https://discord.com/api/download?platform=linux&format=deb"
	sudo apt install ./discord.deb
); }

function upgrade-flipper { (
	mkdir -p ~/Software/Flipper
	cd ~/Software/Flipper
	rm -rf *
	curl -L --output __flipper.zip "https://www.facebook.com/fbflipper/public/linux"
	unzip __flipper.zip
	rm __flipper.zip
	ln -s "$(pwd)/flipper" ~/bin/flipper
); }

function upgrade-appium { (
	mkdir -p ~/Software/Appium
	cd ~/Software/Appium
	rm -rf *
	latest_version=$(curl --silent "https://api.github.com/repos/appium/appium-desktop/releases/latest" | jq -r ".name")
	printf "%s\n\n" "Downloading Appium ${latest_version}"
	wget "https://github.com/appium/appium-desktop/releases/download/v${latest_version}/Appium-Server-GUI-linux-${latest_version}.AppImage"
	chmod +x "Appium-Server-GUI-linux-${latest_version}.AppImage"
	ln -s "$(pwd)/Appium-Server-GUI-linux-${latest_version}.AppImage" ~/bin/appium
); }

function backup-anbernic { (
	cd ~/Dropbox/Backup/Anbernic_Saves/ReGBA
	scp root@10.1.1.2:/media/data/local/home/.gpsp/* .
); }

function my-commits-here {
	smerge search 'author:"Carlos Fdez. Llamas <hello@sirikon.me>"' .
}

function to-clipboard {
	xclip -sel clip
}

prompt-normal
