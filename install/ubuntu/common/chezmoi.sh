#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 引入共用函式庫
source "$(dirname "${BASH_SOURCE[0]}")/../../common/utils.sh"

readonly CHEZMOI_BIN="/usr/local/bin/chezmoi"
readonly CHEZMOI_TMP_DIR="/tmp/chezmoi"
readonly CHEZMOI_VERSION="2.47.0"

function check_chezmoi_installed() {
    if [ -x "$CHEZMOI_BIN" ]; then
        local installed_version
        installed_version=$("$CHEZMOI_BIN" version | cut -d' ' -f3)
        if [ "$installed_version" = "$CHEZMOI_VERSION" ]; then
            return 0
        fi
    fi
    return 1
}

function install_chezmoi() {
    echo "開始安裝 chezmoi..."

    # 如果已安裝且版本正確，則跳過
    if check_chezmoi_installed; then
        echo "chezmoi $CHEZMOI_VERSION 已安裝，跳過"
        return 0
    fi

    # 下載並安裝
    echo "正在下載並安裝 chezmoi $CHEZMOI_VERSION..."
    if ! sudo sh -c "$(curl -fsLS get.chezmoi.io)" -- -b /usr/local/bin; then
        echo "錯誤：安裝 chezmoi 失敗" >&2
        return 1
    fi

    # 驗證安裝
    if ! check_chezmoi_installed; then
        echo "錯誤：chezmoi 安裝驗證失敗" >&2
        return 1
    fi

    echo "chezmoi 安裝成功！"
}

function verify_installation() {
    echo "驗證 chezmoi 安裝..."

    if ! [ -x "$CHEZMOI_BIN" ]; then
        echo "錯誤：chezmoi 執行檔不存在" >&2
        return 1
    fi

    if ! "$CHEZMOI_BIN" version &> /dev/null; then
        echo "錯誤：chezmoi 無法正常執行" >&2
        return 1
    fi

    echo "chezmoi 安裝驗證成功！"
}

function uninstall_chezmoi() {
    echo "開始移除 chezmoi..."

    if [ -x "$CHEZMOI_BIN" ]; then
        echo "正在移除 chezmoi..."
        if ! sudo rm -fv "$CHEZMOI_BIN"; then
            echo "錯誤：移除 chezmoi 失敗" >&2
            return 1
        fi
        echo "chezmoi 移除成功！"
    else
        echo "chezmoi 未安裝，跳過"
    fi
}

function main() {
    install_chezmoi
    verify_installation
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
