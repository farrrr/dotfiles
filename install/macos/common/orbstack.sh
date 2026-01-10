#!/usr/bin/env bash

# 設定 Shell 安全選項
set -Eeuo pipefail

# 除錯模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 函式：安裝 OrbStack
function install_orbstack() {
    echo "🔍 正在檢查 OrbStack..."

    # 檢查是否已安裝 (檢查 orb 指令)
    if command -v orb &>/dev/null; then
        echo "✅ OrbStack 已安裝。"
        return 0
    fi

    # 也可以檢查應用程式路徑
    if [[ -d "/Applications/OrbStack.app" ]]; then
        echo "✅ OrbStack.app 已存在。"
        return 0
    fi

    echo "⬇️  未偵測到 OrbStack，正在安裝..."

    if command -v brew &>/dev/null; then
        # 使用 Homebrew Cask 安裝
        if brew install --cask orbstack; then
             echo "✅ OrbStack 安裝完成！"
        else
             echo "❌ OrbStack 安裝失敗"
             exit 1
        fi
    else
        echo "❌ 未安裝 Homebrew，無法自動安裝 OrbStack"
        exit 1
    fi
}

function uninstall_orbstack() {
    echo "🗑️  正在移除 OrbStack..."
    brew uninstall --cask orbstack --force
}

function main() {
    install_orbstack
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
