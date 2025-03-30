#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

function is_mas_installed() {
    command -v mas &>/dev/null
}

function install_mas() {
    echo "正在安裝 mas..."

    if is_mas_installed; then
        echo "mas 已安裝，版本："
        mas version
        return 0
    fi

        brew install mas

    if is_mas_installed; then
        echo "mas 安裝成功！"
        mas version
    else
        echo "錯誤：mas 安裝失敗" >&2
        return 1
    fi
}

function install_mas_app() {
    local app_id="$1"
    local app_name="$2"

    echo "正在安裝 ${app_name}..."
    if mas install "${app_id}"; then
        echo "${app_name} 安裝成功！"
    else
        echo "錯誤：${app_name} 安裝失敗" >&2
    fi
}

function main() {
    echo "開始安裝 Mac App Store 應用程式..."

    install_mas

    declare -A apps=(
        ["LINE"]="539883307"
    )

    if ! "${CI:-false}"; then
        for app_name in "${!apps[@]}"; do
            install_mas_app "${apps[$app_name]}" "${app_name}"
        done
    fi

    echo "Mac App Store 應用程式安裝完成！"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
