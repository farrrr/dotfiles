#!/usr/bin/env bash

set -Eeuo pipefail

# 如果設置了 DOTFILES_DEBUG 環境變數，則啟用 debug 模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 檢查是否已安裝 ghq
function is_ghq_installed() {
    command -v ghq &>/dev/null
}

# 安裝 ghq
function install_ghq() {
    echo "正在安裝 ghq..."

    # 檢查是否已安裝
    if is_ghq_installed; then
        echo "ghq 已安裝，版本："
        ghq --version
        return 0
    fi

    # 使用 Homebrew 安裝 ghq
    brew install ghq

    # 驗證安裝
    if is_ghq_installed; then
        echo "ghq 安裝成功！"
        ghq --version
    else
        echo "錯誤：ghq 安裝失敗" >&2
        return 1
    fi
}

# 卸載 ghq
function uninstall_ghq() {
    echo "正在卸載 ghq..."

    if ! is_ghq_installed; then
        echo "ghq 未安裝，無需卸載"
        return 0
    fi

    # 使用 Homebrew 卸載 ghq
    brew uninstall ghq

    # 驗證卸載
    if ! is_ghq_installed; then
        echo "ghq 卸載成功"
    else
        echo "警告：ghq 可能未完全卸載" >&2
    fi
}

# 主函數
function main() {
    echo "開始安裝 ghq..."
    install_ghq
    echo "ghq 安裝完成！"
}

# 檢查腳本是否直接執行（而非被導入）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
