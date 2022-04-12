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

function upgrade-binmerge { (
	rm -rf ~/Software/binmerge
	mkdir -p ~/Software/binmerge
	git clone "https://github.com/putnam/binmerge.git" ~/Software/binmerge
	cd ~/Software/binmerge
	git reset --hard "7218522aac721f6b0dcc2efc1b38f7d286979c7a"
	rm -rf ~/bin/binmerge
	ln -s "$(pwd)/binmerge" ~/bin/binmerge
); }

function upgrade-firefox { (
	rm -rf ~/Software/firefox
	mkdir -p ~/Software/firefox
	cd ~/Software/firefox
	curl -Lo firefox.tar.bz2 \
		"https://download.mozilla.org/?product=firefox-latest-ssl&os=linux64&lang=en-US"
	tar -xvf firefox.tar.bz2
	sudo rm -rf /opt/firefox
	sudo mv ./firefox /opt/firefox
	sudo chown -R root:root /opt/firefox
	sudo rm -f /usr/local/bin/firefox
	sudo ln -s /opt/firefox/firefox /usr/local/bin/firefox
	sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /opt/firefox/firefox 200
	sudo update-alternatives --set x-www-browser /opt/firefox/firefox
); }

function upgrade-yq { (
	rm -rf ~/Software/yq
	mkdir -p ~/Software/yq
	cd ~/Software/yq
	latest_version=$(curl --silent "https://api.github.com/repos/mikefarah/yq/releases/latest" | jq -r ".tag_name")
	printf "%s\n\n" "Downloading yq ${latest_version}"
	curl -Lo yq "https://github.com/mikefarah/yq/releases/download/${latest_version}/yq_linux_amd64"
	chmod +x yq
	rm -rf ~/bin/yq
	ln -s "$(pwd)/yq" ~/bin/yq
); }

function upgrade-htmlq { (
	rm -rf ~/Software/htmlq
	mkdir -p ~/Software/htmlq
	cd ~/Software/htmlq
	latest_version=$(curl --silent "https://api.github.com/repos/mgdm/htmlq/releases/latest" | jq -r ".tag_name")
	printf "%s\n\n" "Downloading htmlq ${latest_version}"
	curl -Lo htmlq.tar.gz "https://github.com/mgdm/htmlq/releases/download/${latest_version}/htmlq-x86_64-linux.tar.gz"
	tar -xzf htmlq.tar.gz
	rm -rf ~/bin/htmlq
	ln -s "$(pwd)/htmlq" ~/bin/htmlq
); }

function upgrade-fnmt-tools { (
	rm -rf ~/Software/fnmt
	mkdir -p ~/Software/fnmt
	cd ~/Software/fnmt

	configurador_download_url=$(curl -sL "https://www.sede.fnmt.gob.es/descargas/descarga-software/instalacion-software-generacion-de-claves" | htmlq --attribute href 'a[href*="amd64.deb"]')
	printf "%s\n%s\n\n" "Downloading Configurador:" "${configurador_download_url}"
	curl -Lo configurador.deb "${configurador_download_url}"
	printf "%s\n" ""

	autofirma_download_url=$(curl -sL "https://firmaelectronica.gob.es/Home/Descargas.html" | htmlq --attribute href 'a[href$="AutoFirma_Linux.zip"]')
	printf "%s\n%s\n\n" "Downloading AutoFirma:" "${autofirma_download_url}"
	curl -Lo autofirma.zip "${autofirma_download_url}"
	printf "%s\n" ""

	sudo apt install ./configurador.deb
	printf "%s\n" ""

	unzip autofirma.zip
	sudo apt install ./AutoFirma*.deb
); }

function upgrade-dnie-tools { (
	rm -rf ~/Software/dnie
	mkdir -p ~/Software/dnie
	cd ~/Software/dnie

	deb_download_url="https://www.dnielectronico.es$(curl -sL 'https://www.dnielectronico.es/portaldnie/PRF1_Cons02.action?pag=REF_1112' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:99.0) Gecko/20100101 Firefox/99.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: cross-site' -H 'Cache-Control: max-age=0' -H 'TE: trailers' | htmlq --attribute href 'a[href*="amd64.deb"]')"
	printf "%s\n%s\n\n" "Downloading libpkcs11-dnie:" "${deb_download_url}"
	curl -Lo libpkcs11_dnie.deb "${deb_download_url}"
	printf "%s\n" ""

	pdf_download_url="https://www.dnielectronico.es$(curl -sL 'https://www.dnielectronico.es/portaldnie/PRF1_Cons02.action?pag=REF_1111' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:99.0) Gecko/20100101 Firefox/99.0' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,*/*;q=0.8' -H 'Accept-Language: en-US,en;q=0.5' -H 'Accept-Encoding: gzip, deflate, br' -H 'Referer: https://www.dnielectronico.es/portaldnie/PRF1_Cons02.action?pag=REF_1110' -H 'DNT: 1' -H 'Connection: keep-alive' -H 'Upgrade-Insecure-Requests: 1' -H 'Sec-Fetch-Dest: document' -H 'Sec-Fetch-Mode: navigate' -H 'Sec-Fetch-Site: same-origin' -H 'Sec-Fetch-User: ?1' -H 'TE: trailers' | htmlq --attribute href 'a[href*=".pdf"]' | tail -n1)"
	printf "%s\n%s\n\n" "Downloading PDF:" "${deb_download_url}"
	curl -Lo instructions.pdf "${pdf_download_url}"
	printf "%s\n" ""

	sudo apt install pcsc-tools
	sudo apt install ./libpkcs11_dnie.deb

	sudo rm /usr/local/share/ca-certificates/AC_RAIZ_DNIE_2.crt
	sudo cp /usr/share/libpkcs11-dnie/AC\ RAIZ\ DNIE\ 2.crt /usr/local/share/ca-certificates/AC_RAIZ_DNIE_2.crt
	sudo chmod 644 /usr/local/share/ca-certificates/AC_RAIZ_DNIE_2.crt
	
	sudo update-ca-certificates
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
