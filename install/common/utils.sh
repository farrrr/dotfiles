#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

function check_system_requirements() {
    # 檢查是否具有 sudo 權限
    if ! sudo -v; then
        echo "錯誤：需要 sudo 權限來安裝套件" >&2
        exit 1
    fi
}

function check_package_installed() {
    local package="$1"
    dpkg -l "$package" 2>/dev/null | grep -q "^ii"
}

function update_package_list() {
    echo "更新套件列表..."
    if ! sudo apt update; then
        echo "錯誤：無法更新套件列表" >&2
        return 1
    fi
}

function cleanup() {
    echo "清理暫存檔案..."
    sudo apt clean
    sudo apt autoremove -y
}