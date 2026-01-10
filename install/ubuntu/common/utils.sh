#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 函式：檢查系統需求 (Sudo 權限)
function check_system_requirements() {
    # 檢查是否具有 sudo 權限
    if ! sudo -v; then
        echo "❌ 錯誤：需要 sudo 權限來安裝套件" >&2
        exit 1
    fi
}

# 函式：檢查套件是否已安裝
function check_package_installed() {
    local package="$1"
    # 使用 dpkg 檢查 package status，grep 確保狀態為 'ii' (installed)
    dpkg -l "$package" 2>/dev/null | grep -q "^ii"
}

# 函式：更新套件清單
function update_package_list() {
    echo "🔄 更新套件列表..."
    if ! sudo apt-get update; then
        echo "❌ 錯誤：無法更新套件列表" >&2
        return 1
    fi
}

# 函式：清理暫存檔案
function cleanup() {
    echo "🧹 清理暫存檔案..."
    sudo apt-get clean
    sudo apt-get autoremove -y
}