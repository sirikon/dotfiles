#!/usr/bin/env bash

# Add sbin to PATH
export PATH=/usr/local/sbin:/usr/sbin:/sbin:$PATH

# Add asdf
. ~/.asdf/asdf.sh
. ~/.asdf/completions/asdf.bash

function git_branch {
	branch=$(git branch 2>/dev/null | grep '^\*' | colrm 1 2)
	if [ "$branch" == "" ]; then
		echo ""
	else
		echo "[${branch}] "
	fi
}

function prompt-normal {
	PS1="\[\033[38;5;208m\]\u\[$(tput sgr0)\]\[\033[38;5;15m\] \[\033[38;5;248m\]\w \$(git_branch)\[$(tput sgr0)\]\[\033[38;5;214m\]\\$\[$(tput sgr0)\] "
	export PS1
}

function prompt-tiny {
	PS1="\[\033[38;5;214m\]\\$\[$(tput sgr0)\] "
	export PS1
}

function ll {
	ls -lah "${@}"
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
	cat "${productJson}" \
		| jq '.extensionsGallery.serviceUrl = "https://marketplace.visualstudio.com/_apis/public/gallery"' \
		| jq '.extensionsGallery.itemUrl = "https://marketplace.visualstudio.com/items"' \
		| jq -M \
		| sudo tee "${productJson}" > /dev/null
}

function upgrade-minecraft-launcher {(
	mkdir -p ~/Downloads/MinecraftLauncher
	cd ~/Downloads/MinecraftLauncher
	rm -f Minecraft.deb
	wget "https://launcher.mojang.com/download/Minecraft.deb"
	sudo apt install ./Minecraft.deb
)}

function upgrade-discord {(
	mkdir -p ~/Downloads/Discord
	cd ~/Downloads/Discord
	rm -f discord.deb
	wget -O discord.deb "https://discord.com/api/download?platform=linux&format=deb"
	sudo apt install ./discord.deb
)}

function my-commits-here {
	smerge search 'author:"Carlos Fdez. Llamas <hello@sirikon.me>"' .
}

function to-clipboard {
	xclip -sel clip
}

prompt-normal
