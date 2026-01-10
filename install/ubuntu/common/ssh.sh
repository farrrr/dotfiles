#!/usr/bin/env bash

set -Eeuo pipefail

# 除錯模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

readonly PACKAGES=(
    openssh-client
)

# 載入輔助函式
# source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"
# 註：因路徑不確定性，此處保持獨立或假設由 caller 確保環境

function is_installed() {
    command -v "$1" &>/dev/null
}

function install_openssh() {
    echo "🔍 檢查 SSH Client..."
    if is_installed ssh; then
        echo "✅ OpenSSH client 已安裝。"
        return 0
    fi

    echo "⬇️  正在安裝 OpenSSH Client..."
    sudo apt-get update
    sudo apt-get install -y "${PACKAGES[@]}"
}

function main() {
    install_openssh
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
