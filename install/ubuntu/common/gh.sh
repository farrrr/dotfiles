#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 引入共用函式庫
source "$(dirname "${BASH_SOURCE[0]}")/../../common/utils.sh"

readonly GH_KEYRING="/usr/share/keyrings/githubcli-archive-keyring.gpg"
readonly GH_SOURCE="/etc/apt/sources.list.d/github-cli.list"

function check_gh_installed() {
    if command -v gh &> /dev/null; then
        return 0
    fi
    return 1
}

function setup_repository() {
    echo "設定 GitHub CLI 倉庫..."

    # 下載並設定 GPG 金鑰
    if ! curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of="$GH_KEYRING"; then
        echo "錯誤：無法下載或設定 GPG 金鑰" >&2
        return 1
    fi

    # 設定金鑰權限
    if ! sudo chmod go+r "$GH_KEYRING"; then
        echo "錯誤：無法設定金鑰權限" >&2
        return 1
    fi

    # 設定倉庫來源
    local repo_url="deb [arch=$(dpkg --print-architecture) signed-by=${GH_KEYRING}] https://cli.github.com/packages stable main"
    if ! echo "$repo_url" | sudo tee "$GH_SOURCE" >/dev/null; then
        echo "錯誤：無法設定倉庫來源" >&2
        return 1
    fi

    # 更新套件列表
    if ! sudo apt update; then
        echo "錯誤：無法更新套件列表" >&2
        return 1
    fi
}

function install_gh() {
    echo "開始安裝 GitHub CLI..."

    # 檢查是否已安裝
    if check_gh_installed; then
        echo "GitHub CLI 已安裝，跳過"
        return 0
    fi

    # 確保 curl 已安裝
    if ! command -v curl &> /dev/null; then
        echo "安裝 curl..."
        if ! sudo apt install -y curl; then
            echo "錯誤：無法安裝 curl" >&2
            return 1
        fi
    fi

    # 設定倉庫
    if ! setup_repository; then
        echo "錯誤：倉庫設定失敗" >&2
        return 1
    fi

    # 安裝 GitHub CLI
    echo "安裝 GitHub CLI..."
    if ! sudo apt install -y gh; then
        echo "錯誤：GitHub CLI 安裝失敗" >&2
        return 1
    fi

    echo "GitHub CLI 安裝成功！"
}

function verify_installation() {
    echo "驗證安裝..."

    if ! check_gh_installed; then
        echo "錯誤：GitHub CLI 未正確安裝" >&2
        return 1
    fi

    if ! gh --version &> /dev/null; then
        echo "錯誤：GitHub CLI 無法正常執行" >&2
        return 1
    fi

    echo "安裝驗證成功！"
}

function uninstall_gh() {
    echo "開始移除 GitHub CLI..."

    if check_gh_installed; then
        echo "移除 GitHub CLI..."
        if ! sudo apt remove -y gh; then
            echo "錯誤：移除 GitHub CLI 失敗" >&2
            return 1
        fi
        echo "GitHub CLI 移除成功！"
    else
        echo "GitHub CLI 未安裝，跳過"
    fi

    # 移除倉庫設定
    if [ -f "$GH_SOURCE" ]; then
        echo "移除倉庫設定..."
        sudo rm -f "$GH_SOURCE"
    fi
    if [ -f "$GH_KEYRING" ]; then
        echo "移除 GPG 金鑰..."
        sudo rm -f "$GH_KEYRING"
    fi

    cleanup
}

function main() {
    check_system_requirements
    install_gh
    verify_installation
    cleanup
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
