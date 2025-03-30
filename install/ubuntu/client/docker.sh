#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 引入共用函式庫
source "$(dirname "${BASH_SOURCE[0]}")/../../common/utils.sh"

readonly PACKAGES=(
    docker-ce
    docker-ce-cli
    containerd.io
    docker-compose-plugin
)

readonly DOCKER_KEYRING="/etc/apt/keyrings/docker.gpg"
readonly DOCKER_SOURCE="/etc/apt/sources.list.d/docker.list"

function check_docker_installed() {
    if command -v docker &> /dev/null && command -v docker compose &> /dev/null; then
        return 0
    fi
    return 1
}

function uninstall_old_docker() {
    echo "移除舊版 Docker 套件..."
    local packages=(
        "docker"
        "docker-engine"
        "docker.io"
        "containerd"
        "runc"
    )
    local failed_packages=()

    for package in "${packages[@]}"; do
        if check_package_installed "$package"; then
            echo "正在移除 $package..."
            if ! sudo apt-get remove -y "$package"; then
                failed_packages+=("$package")
                echo "警告：移除 $package 失敗" >&2
            fi
        fi
    done

    if [ ${#failed_packages[@]} -ne 0 ]; then
        echo "以下套件移除失敗：" >&2
        printf '%s\n' "${failed_packages[@]}" >&2
        return 1
    fi
}

function setup_repository() {
    echo "設定 Docker 倉庫..."

    # 更新套件列表並安裝必要套件
    if ! update_package_list; then
        return 1
    fi

    local required_packages=(
        ca-certificates
        curl
        gnupg
        lsb-release
    )

    for package in "${required_packages[@]}"; do
        if ! check_package_installed "$package"; then
            echo "安裝必要套件 $package..."
            if ! sudo apt-get install -y "$package"; then
                echo "錯誤：安裝 $package 失敗" >&2
                return 1
            fi
        fi
    done

    # 建立 keyrings 目錄
    if ! sudo mkdir -p /etc/apt/keyrings; then
        echo "錯誤：無法建立 keyrings 目錄" >&2
        return 1
    fi

    # 下載並設定 Docker GPG 金鑰
    if ! curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o "$DOCKER_KEYRING"; then
        echo "錯誤：無法下載或設定 Docker GPG 金鑰" >&2
        return 1
    fi

    # 設定倉庫來源
    local repo_url="deb [arch=$(dpkg --print-architecture) signed-by=${DOCKER_KEYRING}] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    if ! echo "$repo_url" | sudo tee "$DOCKER_SOURCE" >/dev/null; then
        echo "錯誤：無法設定 Docker 倉庫來源" >&2
        return 1
    fi

    # 更新套件列表
    if ! update_package_list; then
        return 1
    fi
}

function install_docker_engine() {
    echo "安裝 Docker Engine..."

    local failed_packages=()
    for package in "${PACKAGES[@]}"; do
        if ! check_package_installed "$package"; then
            echo "正在安裝 $package..."
            if ! sudo apt-get install -y "$package"; then
                failed_packages+=("$package")
                echo "錯誤：安裝 $package 失敗" >&2
            fi
        else
            echo "套件 $package 已安裝，跳過"
        fi
    done

    if [ ${#failed_packages[@]} -ne 0 ]; then
        echo "以下套件安裝失敗：" >&2
        printf '%s\n' "${failed_packages[@]}" >&2
        return 1
    fi
}

function verify_installation() {
    echo "驗證 Docker 安裝..."

    # 檢查 Docker 命令是否可用
    if ! command -v docker &> /dev/null; then
        echo "錯誤：Docker 未正確安裝" >&2
        return 1
    fi

    # 檢查 Docker Compose 命令是否可用
    if ! command -v docker compose &> /dev/null; then
        echo "錯誤：Docker Compose 未正確安裝" >&2
        return 1
    fi

    # 檢查 Docker 服務狀態
    if ! systemctl is-active --quiet docker; then
        echo "錯誤：Docker 服務未運行" >&2
        return 1
    fi

    # 測試 Docker 功能
    if ! docker run --rm hello-world &> /dev/null; then
        echo "錯誤：Docker 無法正常運行" >&2
        return 1
    fi

    echo "Docker 安裝驗證成功！"
}

function uninstall_docker_engine() {
    echo "開始移除 Docker Engine..."

    if check_docker_installed; then
        # 停止 Docker 服務
        echo "停止 Docker 服務..."
        sudo systemctl stop docker

        # 移除 Docker 套件
        local failed_packages=()
        for package in "${PACKAGES[@]}"; do
            if check_package_installed "$package"; then
                echo "正在移除 $package..."
                if ! sudo apt-get remove -y "$package"; then
                    failed_packages+=("$package")
                    echo "錯誤：移除 $package 失敗" >&2
                fi
            fi
        done

        if [ ${#failed_packages[@]} -ne 0 ]; then
            echo "以下套件移除失敗：" >&2
            printf '%s\n' "${failed_packages[@]}" >&2
            return 1
        fi

        # 移除 Docker 倉庫設定
        if [ -f "$DOCKER_SOURCE" ]; then
            echo "移除 Docker 倉庫設定..."
            sudo rm -f "$DOCKER_SOURCE"
        fi
        if [ -f "$DOCKER_KEYRING" ]; then
            echo "移除 Docker GPG 金鑰..."
            sudo rm -f "$DOCKER_KEYRING"
        fi

        cleanup
        echo "Docker Engine 移除成功！"
    else
        echo "Docker 未安裝，跳過"
    fi
}

function main() {
    check_system_requirements
    uninstall_old_docker
    setup_repository
    install_docker_engine
    verify_installation
    cleanup
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
