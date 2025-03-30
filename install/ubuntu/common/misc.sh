#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 引入共用函式庫
source "$(dirname "${BASH_SOURCE[0]}")/../../common/utils.sh"

readonly PACKAGES=(
    busybox
    curl
    gpg
    jq
    htop
    shellcheck
    unzip
    vim
    wget
    zsh
)

function update_package_list() {
    echo "更新套件列表..."
    if ! sudo apt-get update; then
        echo "錯誤：無法更新套件列表" >&2
        exit 1
    fi
}

function install_apt_packages() {
    local failed_packages=()

    echo "開始安裝套件..."
    for package in "${PACKAGES[@]}"; do
        if check_package_installed "$package"; then
            echo "套件 $package 已安裝，跳過"
            continue
        fi

        echo "正在安裝 $package..."
        if ! sudo apt-get install -y "$package"; then
            failed_packages+=("$package")
            echo "警告：安裝 $package 失敗" >&2
        fi
    done

    if [ ${#failed_packages[@]} -ne 0 ]; then
        echo "以下套件安裝失敗：" >&2
        printf '%s\n' "${failed_packages[@]}" >&2
        return 1
    fi
}

function verify_installations() {
    echo "驗證安裝..."
    local missing_packages=()

    for package in "${PACKAGES[@]}"; do
        if ! command -v "$package" &> /dev/null; then
            missing_packages+=("$package")
            echo "警告：$package 未正確安裝" >&2
        fi
    done

    if [ ${#missing_packages[@]} -ne 0 ]; then
        echo "以下套件未正確安裝：" >&2
        printf '%s\n' "${missing_packages[@]}" >&2
        return 1
    fi
}

function main() {
    update_package_list
    install_apt_packages
    verify_installations
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
