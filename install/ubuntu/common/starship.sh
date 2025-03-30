#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 引入共用函式庫
source "$(dirname "${BASH_SOURCE[0]}")/../../common/utils.sh"

readonly STARSHIP_BIN="/usr/local/bin/starship"

function check_starship_installed() {
    if command -v starship &> /dev/null; then
        return 0
    fi
    return 1
}

function install_starship() {
    echo "開始安裝 starship..."

    # 檢查是否已安裝
    if check_starship_installed; then
        echo "starship 已安裝，跳過"
        return 0
    fi

    # 下載並安裝 starship
    echo "下載並安裝 starship..."
    if ! curl -sS https://starship.rs/install.sh | sh; then
        echo "錯誤：安裝 starship 失敗" >&2
        return 1
    fi

    echo "starship 安裝成功！"
}

function verify_installation() {
    echo "驗證 starship 安裝..."

    if ! check_starship_installed; then
        echo "錯誤：starship 未正確安裝" >&2
        return 1
    fi

    # 檢查 starship 是否可以正常執行
    if ! starship --version &> /dev/null; then
        echo "錯誤：starship 無法正常執行" >&2
        return 1
    fi

    echo "starship 安裝驗證成功！"
}

function uninstall_starship() {
    echo "開始移除 starship..."

    if check_starship_installed; then
        # 移除 starship
        if ! rm -f "${STARSHIP_BIN}"; then
            echo "錯誤：移除 starship 失敗" >&2
            return 1
        fi

        # 移除 starship 快取目錄
        if [[ -d "${HOME}/.cache/starship" ]]; then
            if ! rm -rf "${HOME}/.cache/starship"; then
                echo "錯誤：移除 starship 快取目錄失敗" >&2
                return 1
            fi
        fi

        echo "starship 移除成功！"
    else
        echo "starship 未安裝，跳過"
    fi
}

function main() {
    check_system_requirements
    install_starship
    verify_installation
    cleanup
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi