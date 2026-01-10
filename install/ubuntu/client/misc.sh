#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# Ubuntu Client 專用套件 (例如桌面環境工具、開發庫等)
# 目前為空，保留供日後擴充
readonly PACKAGES=(
    # build-essential
    # libssl-dev
)

function install_misc() {
    echo "🔍 檢查 Ubuntu Client 專用套件..."

    if [ ${#PACKAGES[@]} -eq 0 ]; then
        echo "ℹ️  沒有指定 Ubuntu Client 專用套件。"
        return 0
    fi

    echo "⬇️  正在安裝: ${PACKAGES[*]}"
    sudo apt-get install -y "${PACKAGES[@]}"
}

function main() {
    install_misc
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
