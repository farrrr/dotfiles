#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 引入共用函式庫
source "$(dirname "${BASH_SOURCE[0]}")/../../common/utils.sh"

readonly EZA_KEYRING="/etc/apt/keyrings/gierens.gpg"
readonly EZA_SOURCE="/etc/apt/sources.list.d/gierens.list"
readonly EZA_REPO="deb [signed-by=${EZA_KEYRING}] http://deb.gierens.de stable main"
readonly EZA_BIN="/usr/local/bin/eza"
readonly EZA_TMP_DIR="/tmp/eza"

function check_eza_installed() {
    if command -v eza &> /dev/null; then
        return 0
    fi
    return 1
}

function setup_repository() {
    echo "設定 eza 倉庫..."

    # 建立 keyrings 目錄
    if ! sudo mkdir -p /etc/apt/keyrings; then
        echo "錯誤：無法建立 keyrings 目錄" >&2
        return 1
    fi

    # 下載並設定 GPG 金鑰
    if ! wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o "$EZA_KEYRING"; then
        echo "錯誤：無法下載或設定 GPG 金鑰" >&2
        return 1
    fi

    # 設定倉庫來源
    if ! echo "$EZA_REPO" | sudo tee "$EZA_SOURCE"; then
        echo "錯誤：無法設定倉庫來源" >&2
        return 1
    fi

    # 設定檔案權限
    if ! sudo chmod 644 "$EZA_KEYRING" "$EZA_SOURCE"; then
        echo "錯誤：無法設定檔案權限" >&2
        return 1
    fi

    # 更新套件列表
    if ! sudo apt update; then
        echo "錯誤：無法更新套件列表" >&2
        return 1
    fi
}

function install_eza() {
    echo "開始安裝 eza..."

    # 檢查是否已安裝
    if check_eza_installed; then
        echo "eza 已安裝，跳過"
        return 0
    fi

    # 設定倉庫
    if ! setup_repository; then
        echo "錯誤：倉庫設定失敗" >&2
        return 1
    fi

    # 安裝 eza
    echo "正在安裝 eza..."
    if ! sudo apt install -y eza; then
        echo "錯誤：eza 安裝失敗" >&2
        return 1
    fi

    echo "eza 安裝成功！"
}

function verify_installation() {
    echo "驗證安裝..."

    if ! check_eza_installed; then
        echo "錯誤：eza 未正確安裝" >&2
        return 1
    fi

    echo "安裝驗證成功！"
}

function cleanup() {
    echo "清理暫存檔案..."
    sudo apt clean
    sudo apt autoremove -y
}

function uninstall_eza() {
    echo "開始移除 eza..."

    if check_eza_installed; then
        echo "正在移除 eza..."
        if ! sudo apt remove -y eza; then
            echo "錯誤：移除 eza 失敗" >&2
            return 1
        fi
        echo "eza 移除成功！"
    else
        echo "eza 未安裝，跳過"
    fi

    # 移除倉庫設定
    if [ -f "$EZA_SOURCE" ]; then
        echo "移除倉庫設定..."
        sudo rm -f "$EZA_SOURCE"
    fi
    if [ -f "$EZA_KEYRING" ]; then
        echo "移除 GPG 金鑰..."
        sudo rm -f "$EZA_KEYRING"
    fi

    cleanup
}

function main() {
    install_eza
    verify_installation
    uninstall_eza
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
