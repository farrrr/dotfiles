#!/usr/bin/env bash

set -Eeuo pipefail

# 如果設置了 DOTFILES_DEBUG 環境變數，則啟用 debug 模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 檢查是否已安裝 Go
function is_golang_installed() {
    command -v go &>/dev/null
}

# 安裝 Go
function install_golang() {
    echo "正在安裝 Go..."

    # 檢查是否已安裝
    if is_golang_installed; then
        echo "Go 已安裝，版本："
        go version
        return 0
    fi

    # 使用 Homebrew 安裝 Go
    brew install go

    # 驗證安裝
    if is_golang_installed; then
        echo "Go 安裝成功！"
        go version
    else
        echo "錯誤：Go 安裝失敗" >&2
        return 1
    fi
}

# 卸載 Go
function uninstall_golang() {
    echo "正在卸載 Go..."

    if ! is_golang_installed; then
        echo "Go 未安裝，無需卸載"
        return 0
    fi

    # 使用 Homebrew 卸載 Go
    brew uninstall go

    # 驗證卸載
    if ! is_golang_installed; then
        echo "Go 卸載成功"
    else
        echo "警告：Go 可能未完全卸載" >&2
    fi
}

# 主函數
function main() {
    echo "開始安裝 Go..."
    install_golang
    echo "Go 安裝完成！"
}

# 檢查腳本是否直接執行（而非被導入）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
