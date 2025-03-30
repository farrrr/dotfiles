#!/usr/bin/env bash

set -Eeuo pipefail

# 如果設置了 DOTFILES_DEBUG 環境變數，則啟用 debug 模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 檢查是否已安裝 chezmoi
function is_chezmoi_installed() {
    command -v chezmoi &>/dev/null
}

# 安裝 chezmoi
function install_chezmoi() {
    echo "正在安裝 chezmoi..."

    # 檢查是否已安裝
    if is_chezmoi_installed; then
        echo "chezmoi 已安裝，版本："
        chezmoi --version
        return 0
    fi

    # 使用 Homebrew 安裝 chezmoi
    brew install chezmoi

    # 驗證安裝
    if is_chezmoi_installed; then
        echo "chezmoi 安裝成功！"
        chezmoi --version
    else
        echo "錯誤：chezmoi 安裝失敗" >&2
        return 1
    fi
}

# 卸載 chezmoi
function uninstall_chezmoi() {
    echo "正在卸載 chezmoi..."

    if ! is_chezmoi_installed; then
        echo "chezmoi 未安裝，無需卸載"
        return 0
    fi

    # 使用 Homebrew 卸載 chezmoi
    brew uninstall chezmoi

    # 驗證卸載
    if ! is_chezmoi_installed; then
        echo "chezmoi 卸載成功"
    else
        echo "警告：chezmoi 可能未完全卸載" >&2
    fi
}

# 主函數
function main() {
    echo "開始安裝 chezmoi..."
    install_chezmoi
    echo "chezmoi 安裝完成！"
}

# 檢查腳本是否直接執行（而非被導入）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
