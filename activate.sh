#!/usr/bin/env bash

PATH="$(realpath "$(dirname "${BASH_SOURCE[0]}")")/bin:${PATH}"
export PATH

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

function install-n {
	curl -L "https://git.io/n-install" | bash
}

function used-ports {
	sudo lsof -i -P -n | grep LISTEN
}

function backup-bilbaoswcraft-newsletter-db {
	scp root@116.203.231.200:/var/lib/buletina/data.db ~/Dropbox/Backup/BilbaoSWCraft_Newsletter/data.db
	subscription_count=$(sqlite3 ~/Dropbox/Backup/BilbaoSWCraft_Newsletter/data.db "SELECT COUNT(1) FROM subscriptions;")
	printf "%s\n" "Subscription count: ${subscription_count}"
}

function patch-vscodium-marketplace {
	productJson="/usr/share/codium/resources/app/product.json"
	cat "${productJson}" \
		| jq '.extensionsGallery.serviceUrl = "https://marketplace.visualstudio.com/_apis/public/gallery"' \
		| jq '.extensionsGallery.itemUrl = "https://marketplace.visualstudio.com/items"' \
		| jq -M \
		| sudo tee "${productJson}" > /dev/null
}

prompt-normal
