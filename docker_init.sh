#!/usr/bin/env bash

# set -ex

clear

if curl -s -m 5 -o /dev/null -w "%{http_code}" www.google.com | grep -q "200"; then
    ghproxy="https:/"
    ghtype=false
else
    ghproxy="https://mirror.ghproxy.com/https:/"
    ghtype=true
fi

OS="$(uname -s)"
Arch="$(uname -m)"
Tag="$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)"

DockerInstall(){
    echo " ╷───────────────────────────╷"
    echo " │    OS ${OS}              │"
    echo " │    Arch ${Arch}             │"
    echo " │    Docker Version: ${Tag} │"
    echo " ╵–––––––––––––––––––––––––––╵"
    case "${OS}" in
        Linux)
            echo " Install Docker for Linux"
            if [ ghtype = true ]; then
                bash <(curl -fsSL https://get.docker.com) -s docker --mirror Aliyun
            else
                bash <(curl -fsSL https://get.docker.com) -s docker
            fi
            sudo systemctl enable docker
            sudo systemctl start docker
            sudo usermod -aG docker "$USER"
        ;;
        Darwin)
            echo " Docker Error: Docker Desktop https://www.docker.com/products/docker-desktop"
            if [ "${OS}" == "Darwin" ] && [ "${Arch}" == "arm64" ]; then
                Arch="aarch64"
            fi
        ;;
        *)
            echo " Unknown OS: ${OS}}"
            exit 1
        ;;
    esac
}

DockerComposeInstall(){
    echo " Downloading docker-compose..."
    sudo curl -Lo /usr/local/bin/docker-compose "${ghproxy}/github.com/docker/compose/releases/download/${Tag}/docker-compose-${OS}-${Arch}"
    sudo chmod +x /usr/local/bin/docker-compose
}

DockerInstall

DockerComposeInstall