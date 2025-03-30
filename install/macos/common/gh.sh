#!/usr/bin/env bash

set -Eeuo pipefail

# 如果設置了 DOTFILES_DEBUG 環境變數，則啟用 debug 模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 檢查是否已安裝 gh
function is_gh_installed() {
    command -v gh &>/dev/null
}

# 安裝 gh
function install_gh() {
    echo "正在安裝 GitHub CLI..."

    # 檢查是否已安裝
    if is_gh_installed; then
        echo "GitHub CLI 已安裝，版本："
        gh --version
        return 0
    fi

    # 使用 Homebrew 安裝 GitHub CLI
    brew install gh

    # 驗證安裝
    if is_gh_installed; then
        echo "GitHub CLI 安裝成功！"
        gh --version
    else
        echo "錯誤：GitHub CLI 安裝失敗" >&2
        return 1
    fi
}

# 卸載 gh
function uninstall_gh() {
    echo "正在卸載 GitHub CLI..."

    if ! is_gh_installed; then
        echo "GitHub CLI 未安裝，無需卸載"
        return 0
    fi

    # 使用 Homebrew 卸載 GitHub CLI
    brew uninstall gh

    # 驗證卸載
    if ! is_gh_installed; then
        echo "GitHub CLI 卸載成功"
    else
        echo "警告：GitHub CLI 可能未完全卸載" >&2
    fi
}

# 主函數
function main() {
    echo "開始安裝 GitHub CLI..."
    install_gh
    echo "GitHub CLI 安裝完成！"
}

# 檢查腳本是否直接執行（而非被導入）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
