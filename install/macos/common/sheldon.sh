#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

function check_sheldon_installed() {
    if brew list sheldon &>/dev/null; then
        return 0
    fi
    return 1
}

function install_sheldon() {
    echo "開始安裝 sheldon..."

    # 檢查是否已安裝
    if check_sheldon_installed; then
        echo "sheldon 已安裝，跳過"
        return 0
    fi

    # 使用 Homebrew 安裝
    echo "使用 Homebrew 安裝 sheldon..."
    if ! brew install sheldon; then
        echo "錯誤：安裝 sheldon 失敗" >&2
        return 1
    fi

    echo "sheldon 安裝成功！"
}

function verify_installation() {
    echo "驗證 sheldon 安裝..."

    if ! check_sheldon_installed; then
        echo "錯誤：sheldon 未正確安裝" >&2
        return 1
    fi

    # 檢查 sheldon 是否可以正常執行
    if ! sheldon --version &> /dev/null; then
        echo "錯誤：sheldon 無法正常執行" >&2
        return 1
    fi

    echo "sheldon 安裝驗證成功！"
}

function uninstall_sheldon() {
    echo "開始移除 sheldon..."

    if check_sheldon_installed; then
        echo "使用 Homebrew 移除 sheldon..."
        if ! brew uninstall sheldon; then
            echo "錯誤：移除 sheldon 失敗" >&2
            return 1
        fi
        echo "sheldon 移除成功！"
    else
        echo "sheldon 未安裝，跳過"
    fi
}

function main() {
    install_sheldon
    verify_installation
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi