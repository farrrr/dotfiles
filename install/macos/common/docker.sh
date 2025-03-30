#!/usr/bin/env bash

set -Eeuo pipefail

# 如果設置了 DOTFILES_DEBUG 環境變數，則啟用 debug 模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 檢查是否已安裝 OrbStack
function is_orbstack_installed() {
    command -v orb &>/dev/null
}

# 安裝 OrbStack
function install_orbstack() {
    echo "正在安裝 OrbStack..."

    # 檢查是否已安裝
    if is_orbstack_installed; then
        echo "OrbStack 已安裝，版本："
        orb version
        return 0
    fi

    # 使用 Homebrew 安裝 OrbStack
    brew install --cask orbstack

    # 驗證安裝
    if is_orbstack_installed; then
        echo "OrbStack 安裝成功！"
        orb version
    else
        echo "錯誤：OrbStack 安裝失敗" >&2
        return 1
    fi
}

# 卸載 OrbStack
function uninstall_orbstack() {
    echo "正在卸載 OrbStack..."

    if ! is_orbstack_installed; then
        echo "OrbStack 未安裝，無需卸載"
        return 0
    fi

    # 使用 Homebrew 卸載 OrbStack
    brew uninstall --cask orbstack --force

    # 驗證卸載
    if ! is_orbstack_installed; then
        echo "OrbStack 卸載成功"
    else
        echo "警告：OrbStack 可能未完全卸載" >&2
    fi
}

# 主函數
function main() {
    echo "開始安裝 OrbStack..."
    install_orbstack
    echo "OrbStack 安裝完成！"
}

# 檢查腳本是否直接執行（而非被導入）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
