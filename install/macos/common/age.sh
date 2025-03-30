#!/usr/bin/env bash

set -Eeuo pipefail

# 如果設置了 DOTFILES_DEBUG 環境變數，則啟用 debug 模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 檢查 age 是否已安裝
function is_age_installed() {
    command -v age &>/dev/null
}

# 檢查 jq 是否已安裝
function is_jq_installed() {
    command -v jq &>/dev/null
}

# 安裝 age
function install_age() {
    if ! is_age_installed; then
        if ! brew install age; then
            echo "安裝 age 失敗" >&2
            exit 1
        fi
    fi
}

# 安裝 jq
function install_jq() {
    if ! is_jq_installed; then
        if ! brew install jq; then
            echo "安裝 jq 失敗" >&2
            exit 1
        fi
    fi
}

# 解除安裝 age
function uninstall_age() {
    if is_age_installed; then
        if ! brew uninstall age; then
            echo "解除安裝 age 失敗" >&2
            exit 1
        fi
    fi
}

# 解除安裝 jq
function uninstall_jq() {
    if is_jq_installed; then
        if ! brew uninstall jq; then
            echo "解除安裝 jq 失敗" >&2
            exit 1
        fi
    fi
}

# 主函數
function main() {
    install_age
    install_jq
}

# 檢查腳本是否直接執行（而非被導入）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
