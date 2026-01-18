#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 通用工具列表
readonly PACKAGES=(
    btop            # 資源監控儀表板
    bat             # cat 的現代化替代品
    curl            # 網頁傳輸工具
    neovim          # 現代化 Vim
    unzip           # Zip 解壓工具
    vim             # 文字編輯器
    wget            # 檔案下載工具
    iputils-ping    # ping command (prettyping depends on it)
)

function install_apt_packages() {
    echo "🔍 檢查 Ubuntu 通用套件..."

    # 這裡採用一次性安裝，讓 apt 處理依賴與已安裝檢查
    echo "⬇️  正在安裝: ${PACKAGES[*]}"

    # 避免在此處執行 update，假設 bootstrap 階段已做過，或允許 apt 自動處理
    # DEBIAN_FRONTEND=noninteractive 避免跳出互動視窗
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "${PACKAGES[@]}"
}

function install_gcloud_sdk() {
    echo "🔍 檢查 Google Cloud SDK..."
    if command -v gcloud &>/dev/null; then
        echo "✅ Google Cloud SDK 已安裝"
        return
    fi

    echo "⬇️  正在安裝 Google Cloud SDK..."

    # 安裝依賴
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y apt-transport-https ca-certificates gnupg

    # Add the gcloud CLI distribution URI as a package source
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

    # Import the Google Cloud public key
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

    # Update and install
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y google-cloud-cli
}

function main() {
    install_apt_packages
    install_gcloud_sdk
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
