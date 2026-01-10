#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

function is_installed() {
    command -v "$1" &>/dev/null
}

function install_git_credential_manager() {
    if is_installed git-credential-manager; then
        echo "✅ Git Credential Manager 已安裝。"
        return
    fi

    echo "🔍 正在取得最新版 Git Credential Manager..."

    # 判斷架構
    local arch
    arch=$(dpkg --print-architecture)
    if [[ "$arch" != "amd64" && "$arch" != "arm64" ]]; then
        echo "❌ 錯誤：不支援的架構: $arch"
        exit 1
    fi

    # 透過 GitHub API 取得下載連結
    local download_url
    download_url=$(curl -s https://api.github.com/repos/git-ecosystem/git-credential-manager/releases/latest | \
        grep "browser_download_url.*gcm-linux_${arch}.*\.deb" | \
        cut -d '"' -f 4 | head -n 1)

    if [[ -z "$download_url" ]]; then
        echo "❌ 錯誤：無法取得 $arch 的 GCM 下載連結。"
        exit 1
    fi

    echo "⬇️  下載 GCM: $download_url..."
    local gcm_deb="gcm.deb"
    wget -O "$gcm_deb" "$download_url"

    echo "📦 安裝 GCM..."
    sudo dpkg -i "$gcm_deb"
    rm -v "$gcm_deb"

    echo "⚙️  設定 GCM..."
    git-credential-manager configure
}

function uninstall_git_credential_manager() {
    git-credential-manager unconfigure
    sudo dpkg -r gcm
}

function main() {
    install_git_credential_manager
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
