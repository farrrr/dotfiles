#!/usr/bin/env bash

set -Eeuo pipefail

# 如果設置了 DOTFILES_DEBUG 環境變數，則啟用 debug 模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 檢查是否已安裝 eza
function is_eza_installed() {
    command -v eza &>/dev/null
}

# 安裝 eza
function install_eza() {
    echo "正在安裝 eza..."

    # 檢查是否已安裝
    if is_eza_installed; then
        echo "eza 已安裝，版本："
        eza --version
        return 0
    fi

    # 使用 Homebrew 安裝 eza
    brew install eza

    # 驗證安裝
    if is_eza_installed; then
        echo "eza 安裝成功！"
        eza --version
    else
        echo "錯誤：eza 安裝失敗" >&2
        return 1
    fi
}

# 卸載 eza
function uninstall_eza() {
    echo "正在卸載 eza..."

    if ! is_eza_installed; then
        echo "eza 未安裝，無需卸載"
        return 0
    fi

    # 使用 Homebrew 卸載 eza
    brew uninstall eza

    # 驗證卸載
    if ! is_eza_installed; then
        echo "eza 卸載成功"
    else
        echo "警告：eza 可能未完全卸載" >&2
    fi
}

# 主函數
function main() {
    echo "開始安裝 eza..."
    install_eza
    echo "eza 安裝完成！"
}

# 檢查腳本是否直接執行（而非被導入）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
