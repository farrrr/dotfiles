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

function main() {
    install_apt_packages
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
