#!/usr/bin/env bash

set -Eeuo pipefail

# 如果設置了 DOTFILES_DEBUG 環境變數，則啟用 debug 模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 定義需要安裝的套件
readonly PACKAGES=(
    tmux
    reattach-to-user-namespace
    cmake
)

# 檢查是否已安裝 tmux
function is_tmux_installed() {
    command -v tmux &>/dev/null
}

# 安裝 tmux 及相關套件
function install_tmux() {
    echo "正在安裝 tmux 及相關套件..."

    # 檢查是否已安裝
    if is_tmux_installed; then
        echo "tmux 已安裝，版本："
        tmux -V
        return 0
    fi

    # 使用 Homebrew 安裝套件
    brew install "${PACKAGES[@]}"

    # 驗證安裝
    if is_tmux_installed; then
        echo "tmux 安裝成功！"
        tmux -V
    else
        echo "錯誤：tmux 安裝失敗" >&2
        return 1
    fi
}

# 卸載 tmux 及相關套件
function uninstall_tmux() {
    echo "正在卸載 tmux 及相關套件..."

    if ! is_tmux_installed; then
        echo "tmux 未安裝，無需卸載"
        return 0
    fi

    # 使用 Homebrew 卸載套件
    brew uninstall "${PACKAGES[@]}"

    # 驗證卸載
    if ! is_tmux_installed; then
        echo "tmux 卸載成功"
    else
        echo "警告：tmux 可能未完全卸載" >&2
    fi
}

# 主函數
function main() {
    echo "開始安裝 tmux..."
    install_tmux
    echo "tmux 安裝完成！"
}

# 檢查腳本是否直接執行（而非被導入）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
