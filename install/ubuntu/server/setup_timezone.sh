#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

function install_tzdata() {
    # 檢查 tzdata 狀態
    if ! dpkg-query -W -f='${Status}' tzdata 2>/dev/null | grep -q "install ok installed"; then
        echo "⬇️  安裝 tzdata..."
        DEBIAN_FRONTEND="noninteractive" sudo apt-get install -y tzdata
    fi
}

function configure_timezone() {
    local target_tz="${TZ:-Asia/Taipei}"
    local current_tz=""

    # 1. 嘗試使用 timedatectl (systemd)
    if command -v timedatectl &>/dev/null; then
        if timedatectl show --property=Timezone --value | grep -q "^${target_tz}$"; then
            echo "✅ 時區已設定為 ${target_tz}。"
            return
        fi
        echo "⚙️  使用 timedatectl 設定時區為 ${target_tz}..."
        if sudo timedatectl set-timezone "${target_tz}"; then
            return
        else
            echo "⚠️  timedatectl 失敗，嘗試手動設定..."
        fi
    fi

    # 2. 手動設定 (Fallback)
    # 檢查是否已經正確
    if [ -f /etc/timezone ]; then
        current_tz=$(cat /etc/timezone)
        if [ "$current_tz" == "$target_tz" ] && [ "$(readlink -f /etc/localtime)" == "/usr/share/zoneinfo/${target_tz}" ]; then
             echo "✅ 時區已設定為 ${target_tz}。"
             return
        fi
    fi

    echo "⚙️  手動設定時區為 ${target_tz}..."
    sudo ln -snf "/usr/share/zoneinfo/${target_tz}" /etc/localtime
    echo "${target_tz}" | sudo tee /etc/timezone > /dev/null

    # 重新配置 tzdata
    if command -v dpkg-reconfigure &>/dev/null; then
        DEBIAN_FRONTEND="noninteractive" sudo dpkg-reconfigure --frontend=noninteractive tzdata
    fi
}

function main() {
    install_tzdata
    configure_timezone
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
