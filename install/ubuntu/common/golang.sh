#!/usr/bin/env bash

set -Eeuo pipefail

# 如果設置了 DOTFILES_DEBUG 環境變數，則啟用 debug 模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 檢查 Go 是否已安裝
function is_golang_installed() {
    command -v go &>/dev/null
}

# 獲取最新版本的 Go
function get_latest_version() {
    local version
    version="$(curl -s https://go.dev/VERSION?m=text | head -n 1)"
    if [[ -z "${version}" ]]; then
        echo "無法獲取 Go 版本資訊" >&2
        exit 1
    fi
    echo "${version}"
}

# 安裝 Go
function install_golang() {
    if is_golang_installed; then
        echo "Go 已安裝"
        return 0
    fi

    echo "正在安裝 Go..."
    local tmp_file
    tmp_file="$(mktemp /tmp/golang-XXXXXXXXXX)"

    # 下載 Go
    if ! curl -fSL "https://go.dev/dl/$(get_latest_version).linux-amd64.tar.gz" -o "${tmp_file}"; then
        echo "下載 Go 失敗" >&2
        rm -f "${tmp_file}"
        exit 1
    fi

    # 安裝 Go
    if ! sudo tar -C /usr/local -xzf "${tmp_file}"; then
        echo "安裝 Go 失敗" >&2
        rm -f "${tmp_file}"
        exit 1
    fi

    # 清理暫存檔
    rm -f "${tmp_file}"

    if ! is_golang_installed; then
        echo "Go 安裝完成但無法驗證" >&2
        exit 1
    fi

    echo "Go 安裝成功"
}

# 解除安裝 Go
function uninstall_golang() {
    if ! is_golang_installed; then
        echo "Go 未安裝" >&2
        return 0
    fi

    echo "正在解除安裝 Go..."
    if ! sudo rm -rf /usr/local/go; then
        echo "解除安裝 Go 失敗" >&2
        exit 1
    fi

    if is_golang_installed; then
        echo "Go 解除安裝完成但無法驗證" >&2
        exit 1
    fi

    echo "Go 解除安裝成功"
}

# 主函數
function main() {
    install_golang
}

# 檢查腳本是否直接執行（而非被導入）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
