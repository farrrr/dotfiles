#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

readonly PACKAGES=(
    docker-ce
    docker-ce-cli
    containerd.io
    docker-buildx-plugin
    docker-compose-plugin
)

function is_installed() {
    command -v "$1" &>/dev/null
}

function uninstall_old_docker() {
    echo "🧹 移除舊版 Docker (若存在)..."
    # 忽略移除錯誤
    sudo apt-get remove -y docker docker-engine docker.io containerd runc || true
}

function setup_repository() {
    echo "⚙️  設定 Docker 倉庫..."

    # 安裝前置依賴
    sudo apt-get update
    sudo apt-get install -y \
        ca-certificates \
        curl \
        gnupg \
        lsb-release

    # 新增 Docker 官方 GPG key
    sudo mkdir -p /etc/apt/keyrings
    if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    fi
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # 設定 Repository
    echo \
        "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
        $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null

    sudo apt-get update
}

function install_docker_engine() {
    if is_installed docker; then
        echo "✅ Docker Engine 已安裝。"
    else
        echo "⬇️  正在安裝 Docker Engine..."
        sudo apt-get install -y "${PACKAGES[@]}"
    fi

    # Post-installation: 設定非 Root 使用者權限
    if ! getent group docker >/dev/null; then
        echo "creating docker group..."
        sudo groupadd docker
    fi

    if ! groups "$USER" | grep -q "\bdocker\b"; then
        echo "Adding $USER to the docker group..."
        sudo usermod -aG docker "$USER"
        echo "⚠️  使用者已加入 docker 群組。請登出再登入以生效。"
    fi
}

function main() {
    if is_installed docker; then
        echo "✅ Docker 已安裝，檢查使用者權限..."
        install_docker_engine # 僅執行群組檢查
        return
    fi

    uninstall_old_docker
    setup_repository
    install_docker_engine
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
