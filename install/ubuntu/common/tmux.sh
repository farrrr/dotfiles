#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 引入共用函式庫
source "$(dirname "${BASH_SOURCE[0]}")/../../common/utils.sh"

readonly PACKAGES=(
    tmux
    xsel
    cmake
)

function install_tmux() {
    echo "開始安裝 tmux 相關套件..."

    # 更新套件列表
    if ! update_package_list; then
        return 1
    fi

    # 安裝套件
    local failed_packages=()
    for package in "${PACKAGES[@]}"; do
        if check_package_installed "$package"; then
            echo "套件 $package 已安裝，跳過"
            continue
        fi

        echo "正在安裝 $package..."
        if ! sudo apt install -y "$package"; then
            failed_packages+=("$package")
            echo "錯誤：安裝 $package 失敗" >&2
        fi
    done

    if [ ${#failed_packages[@]} -ne 0 ]; then
        echo "以下套件安裝失敗：" >&2
        printf '%s\n' "${failed_packages[@]}" >&2
        return 1
    fi

    echo "tmux 相關套件安裝成功！"
}

function verify_installation() {
    echo "驗證安裝..."

    local missing_packages=()
    for package in "${PACKAGES[@]}"; do
        if ! check_package_installed "$package"; then
            missing_packages+=("$package")
            echo "錯誤：$package 未正確安裝" >&2
        fi
    done

    if [ ${#missing_packages[@]} -ne 0 ]; then
        echo "以下套件未正確安裝：" >&2
        printf '%s\n' "${missing_packages[@]}" >&2
        return 1
    fi

    # 檢查 tmux 是否可以正常執行
    if ! tmux -V &> /dev/null; then
        echo "錯誤：tmux 無法正常執行" >&2
        return 1
    fi

    echo "安裝驗證成功！"
}

function uninstall_tmux() {
    echo "開始移除 tmux 相關套件..."

    local failed_packages=()
    for package in "${PACKAGES[@]}"; do
        if check_package_installed "$package"; then
            echo "正在移除 $package..."
            if ! sudo apt remove -y "$package"; then
                failed_packages+=("$package")
                echo "錯誤：移除 $package 失敗" >&2
            fi
        else
            echo "套件 $package 未安裝，跳過"
        fi
    done

    if [ ${#failed_packages[@]} -ne 0 ]; then
        echo "以下套件移除失敗：" >&2
        printf '%s\n' "${failed_packages[@]}" >&2
        return 1
    fi

    cleanup
    echo "tmux 相關套件移除成功！"
}

function main() {
    check_system_requirements
    install_tmux
    verify_installation
    cleanup
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
