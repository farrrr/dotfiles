#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 引入共用函式庫
source "$(dirname "${BASH_SOURCE[0]}")/../../common/utils.sh"

readonly BIN_DIR="${HOME}/.local/bin/common"
readonly SHELDON_BIN="${BIN_DIR}/sheldon"

function check_sheldon_installed() {
    if [[ -x "${SHELDON_BIN}" ]]; then
        return 0
    fi
    return 1
}

function install_sheldon() {
    echo "開始安裝 sheldon..."

    # 檢查必要工具
    if ! command -v curl &> /dev/null; then
        echo "錯誤：需要 curl 來安裝 sheldon" >&2
        return 1
    fi

    # 建立安裝目錄
    if ! mkdir -p "${BIN_DIR}"; then
        echo "錯誤：無法建立安裝目錄 ${BIN_DIR}" >&2
        return 1
    fi

    # 設定 GitHub Token
    if [[ -n "${DOTFILES_GITHUB_PAT:-}" ]]; then
        export GITHUB_TOKEN=${DOTFILES_GITHUB_PAT}
    fi

    # 下載並安裝 sheldon
    echo "下載並安裝 sheldon..."
    if ! curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | bash -s -- --repo rossmacarthur/sheldon --to "${BIN_DIR}" --force; then
        echo "錯誤：安裝 sheldon 失敗" >&2
        return 1
    fi

    # 設定執行權限
    if ! chmod +x "${SHELDON_BIN}"; then
        echo "錯誤：無法設定 sheldon 執行權限" >&2
        return 1
    fi

    echo "sheldon 安裝成功！"
}

function verify_installation() {
    echo "驗證 sheldon 安裝..."

    if ! check_sheldon_installed; then
        echo "錯誤：sheldon 未正確安裝" >&2
        return 1
    fi

    # 檢查 sheldon 是否可以正常執行
    if ! "${SHELDON_BIN}" --version &> /dev/null; then
        echo "錯誤：sheldon 無法正常執行" >&2
        return 1
    fi

    echo "sheldon 安裝驗證成功！"
}

function uninstall_sheldon() {
    echo "開始移除 sheldon..."

    if check_sheldon_installed; then
        # 移除 sheldon 執行檔
        if ! rm -f "${SHELDON_BIN}"; then
            echo "錯誤：無法移除 sheldon 執行檔" >&2
            return 1
        fi

        # 如果目錄為空，則移除目錄
        if [[ -d "${BIN_DIR}" ]] && [[ -z "$(ls -A "${BIN_DIR}")" ]]; then
            if ! rm -r "${BIN_DIR}"; then
                echo "錯誤：無法移除空目錄 ${BIN_DIR}" >&2
                return 1
            fi
        fi

        echo "sheldon 移除成功！"
    else
        echo "sheldon 未安裝，跳過"
    fi
}

function main() {
    install_sheldon
    verify_installation
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi