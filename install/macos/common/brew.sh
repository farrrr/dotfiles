#!/usr/bin/env bash

set -Eeuo pipefail

# 如果設置了 DOTFILES_DEBUG 環境變數，則啟用 debug 模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 檢查 Homebrew 是否已安裝
function is_homebrew_exists() {
    command -v brew &>/dev/null
}

# 安裝 Homebrew
function install_homebrew() {
    if is_homebrew_exists; then
        echo "Homebrew 已安裝"
        return 0
    fi

    echo "正在安裝 Homebrew..."
    if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        echo "Homebrew 安裝失敗" >&2
        exit 1
    fi

    if ! is_homebrew_exists; then
        echo "Homebrew 安裝完成但無法驗證" >&2
        exit 1
    fi

    echo "Homebrew 安裝成功"
}

# 停用 Homebrew 分析功能
function opt_out_of_analytics() {
    if ! is_homebrew_exists; then
        echo "Homebrew 未安裝，無法停用分析功能" >&2
        return 1
    fi

    if ! brew analytics off; then
        echo "停用 Homebrew 分析功能失敗" >&2
        return 1
    fi

    echo "已停用 Homebrew 分析功能"
}

# 主函數
function main() {
    install_homebrew
    opt_out_of_analytics
}

# 檢查腳本是否直接執行（而非被導入）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
