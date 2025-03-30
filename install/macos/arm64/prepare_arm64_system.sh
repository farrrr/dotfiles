#!/usr/bin/env bash

set -Eeuo pipefail

# 如果設置了 DOTFILES_DEBUG 環境變數，則啟用 debug 模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 檢查是否為 ARM64 架構
function is_arm64() {
    [[ "$(uname -m)" == "arm64" ]]
}

# 檢查 Rosetta 是否已安裝
function is_rosetta_installed() {
    local rosetta_path="/Library/Apple/usr/share/rosetta/rosetta"
    [[ -f "${rosetta_path}" ]]
}

# 安裝 Rosetta
function install_rosetta() {
    if ! is_arm64; then
        echo "此腳本僅適用於 ARM64 架構的 Mac" >&2
        exit 1
    fi

    if is_rosetta_installed; then
        return 0
    fi

    echo "正在安裝 Rosetta..."
    if ! softwareupdate --install-rosetta --agree-to-license; then
        echo "安裝 Rosetta 失敗" >&2
        exit 1
    fi

    if ! is_rosetta_installed; then
        echo "Rosetta 安裝完成但無法驗證" >&2
        exit 1
    fi

    echo "Rosetta 安裝成功"
}

# 主函數
function main() {
    install_rosetta
}

# 檢查腳本是否直接執行（而非被導入）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
