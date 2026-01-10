#!/usr/bin/env bash

# 設定 Shell 安全選項
set -Eeuo pipefail

# 除錯模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 函式：安裝 Ghostty
function install_ghostty() {
    echo "🔍 正在檢查 Ghostty..."

    # Check if Ghostty is already installed
    if [[ -d "/Applications/Ghostty.app" ]]; then
        echo "✅ Ghostty 已安裝。"
        return 0
    fi

    echo "⬇️  未偵測到 Ghostty，正在安裝..."

    if command -v brew &>/dev/null; then
        echo "📦 使用 Homebrew Cask 安裝 Ghostty..."
        if brew install --cask ghostty; then
             echo "✅ Ghostty 安裝完成！"
        else
             echo "❌ Ghostty 安裝失敗"
             exit 1
        fi
    else
        echo "❌ 未安裝 Homebrew，無法自動安裝 Ghostty"
        exit 1
    fi
}

function uninstall_ghostty() {
    echo "🗑️  正在移除 Ghostty..."
    brew uninstall --cask ghostty --force
}

function main() {
    install_ghostty
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
