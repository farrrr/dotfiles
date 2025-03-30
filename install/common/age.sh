#!/usr/bin/env bash

set -Eeuo pipefail

# 如果設置了 DOTFILES_DEBUG 環境變數，則啟用 debug 模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 檢查 age 是否已安裝
function is_age_installed() {
    command -v "age" &>/dev/null
}

# 獲取 chezmoi 的家目錄路徑
function get_chezmoi_home_dir() {
    local home_dir
    home_dir=$(chezmoi data | jq -r '.chezmoi.homeDir')
    echo -n "${home_dir}"
}

# 獲取 chezmoi 的源目錄路徑
function get_chezmoi_source_dir() {
    local source_dir
    source_dir=$(chezmoi data | jq -r '.chezmoi.sourceDir')
    echo -n "${source_dir}"
}

# 解密 age 私鑰
function decrypt_age_private_key() {
    local age_dir
    local age_src_key
    local age_dst_key

    # CI 環境中沒有 tty，直接返回
    if "${CI:-false}"; then
        return 0
    fi

    if ! is_age_installed; then
        echo "需要安裝 age (https://github.com/FiloSottile/age) 來解密檔案" >&2
        exit 1
    fi

    age_dir="$(get_chezmoi_home_dir)/.config/age"
    age_src_key="$(get_chezmoi_source_dir)/.key.txt.age"
    age_dst_key="${age_dir}/key.txt"

    # 如果目標檔案已存在，則跳過解密
    if [ -f "${age_dst_key}" ]; then
        return 0
    fi

    # 建立目標目錄
    mkdir -p "${age_dir}"

    # 解密私鑰
    if ! age --decrypt --output "${age_dst_key}" "${age_src_key}"; then
        echo "解密失敗" >&2
        exit 1
    fi

    # 設定適當的檔案權限
    chmod 600 "${age_dst_key}"
}

# 主函數
function main() {
    decrypt_age_private_key
}

# 檢查腳本是否直接執行（而非被導入）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
