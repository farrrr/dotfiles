#!/usr/bin/env bash

set -Eeuo pipefail

# 如果設置了 DOTFILES_DEBUG 環境變數，則啟用 debug 模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 檢查是否已安裝 uv
function is_uv_installed() {
    command -v uv >/dev/null 2>&1
}

# 安裝 uv
function install_uv() {
    echo "正在安裝 uv..."

    # 檢查是否已安裝
    if is_uv_installed; then
        echo "uv 已安裝，版本："
        uv --version
        return 0
    fi

    # 使用官方安裝腳本安裝 uv
    echo "使用官方安裝腳本安裝 uv..."
    curl -LsSf https://github.com/astral-sh/uv/releases/latest/download/uv-installer.sh | sh

    # 驗證安裝
    if is_uv_installed; then
        echo "uv 安裝成功！"
        uv --version
    else
        echo "錯誤：uv 安裝失敗" >&2
        return 1
    fi
}

# 卸載 uv
function uninstall_uv() {
    echo "正在卸載 uv..."

    if ! is_uv_installed; then
        echo "uv 未安裝，無需卸載"
        return 0
    fi

    # 清理快取
    echo "清理 uv 快取..."
    uv cache clean

    # 移除 Python 環境
    echo "移除 Python 環境..."
    rm -rf "$(uv python dir)"

    # 移除工具目錄
    echo "移除工具目錄..."
    rm -rf "$(uv tool dir)"

    # 移除二進制檔案
    echo "移除二進制檔案..."
    rm -f "${HOME}/.cargo/bin/uv" "${HOME}/.cargo/bin/uvx"

    echo "uv 卸載完成"
}

# 主函數
function main() {
    echo "開始安裝 uv..."
    install_uv
    echo "uv 安裝完成！"
}

# 檢查腳本是否直接執行（而非被導入）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
