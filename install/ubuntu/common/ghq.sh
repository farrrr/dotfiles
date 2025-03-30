#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 引入共用函式庫
source "$(dirname "${BASH_SOURCE[0]}")/../../common/utils.sh"

readonly GHQ_BIN="/usr/local/bin/ghq"
readonly GHQ_TMP_DIR="/tmp/ghq"
readonly GHQ_DIR_NAME="ghq_linux_amd64"
readonly GHQ_ZIP_NAME="${GHQ_DIR_NAME}.zip"
readonly GHQ_URL="https://github.com/x-motemen/ghq/releases/latest/download/${GHQ_ZIP_NAME}"

function check_ghq_installed() {
    if [ -x "$GHQ_BIN" ]; then
        return 0
    fi
    return 1
}

function install_ghq() {
    echo "開始安裝 ghq..."

    # 檢查是否已安裝
    if check_ghq_installed; then
        echo "ghq 已安裝，跳過"
        return 0
    fi

    # 建立暫存目錄
    local tmp_dir
    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "$tmp_dir"' EXIT

    # 下載並解壓縮
    echo "下載並安裝 ghq..."
    if ! wget -qO "${tmp_dir}/${GHQ_ZIP_NAME}" "$GHQ_URL" || \
       ! unzip -q "${tmp_dir}/${GHQ_ZIP_NAME}" -d "$tmp_dir" || \
       ! mkdir -p "${HOME%/}/.local/bin" || \
       ! mv -v "${tmp_dir}/${GHQ_DIR_NAME}/ghq" "$GHQ_BIN" || \
       ! chmod +x "$GHQ_BIN"; then
        echo "錯誤：安裝 ghq 失敗" >&2
        return 1
    fi

    echo "ghq 安裝成功！"
}

function verify_installation() {
    if ! [ -x "$GHQ_BIN" ] || ! "$GHQ_BIN" --version &> /dev/null; then
        echo "錯誤：ghq 未正確安裝" >&2
        return 1
    fi
}

function uninstall_ghq() {
    if [ -x "$GHQ_BIN" ]; then
        echo "移除 ghq..."
        rm -f "$GHQ_BIN"
    fi
}

function main() {
    install_ghq
    verify_installation
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
