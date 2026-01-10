#!/usr/bin/env bash

# 設定 Shell 安全選項
set -Eeuo pipefail

# 除錯模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 函式：安裝 Mac App Store CLI (mas)
function install_mas() {
    echo "🔍 正在檢查 Mac App Store CLI (mas)..."
    if ! command -v mas &>/dev/null; then
        echo "⬇️  未偵測到 mas，正在安裝..."
        if command -v brew &>/dev/null; then
            brew install mas
            echo "✅ mas 安裝完成"
        else
            echo "❌ 未安裝 Homebrew，無法安裝 mas"
            return 1
        fi
    else
        echo "✅ mas 已安裝"
    fi
}

# 函式：安裝 MAS 應用程式
function install_mas_apps() {
    # 應用程式清單 (App ID # App Name)
    # 若需安裝，請取消註解該行
    local apps=(
        # "490461369"   # Bandwidth+
        # "539883307"   # LINE
        # "1333542190"  # 1Password 7 (舊版)
        # "497799835"   # Xcode
        # "1475387142"  # Tailscale
        # "441258766"   # Magnet (視窗管理)
    )

    if [ ${#apps[@]} -eq 0 ]; then
        echo "ℹ️  沒有指定要安裝的 Mac App Store 應用程式 (清單為空)。"
        return 0
    fi

    echo "📦 正在安裝 Mac App Store 應用程式..."

    # 获取已安装列表以加速检查
    local installed_apps
    installed_apps=$(mas list)

    for app_id in "${apps[@]}"; do
        if echo "${installed_apps}" | grep -q "^${app_id} "; then
             echo "✅ App ID ${app_id} 已安裝"
        else
             echo "⬇️  正在安裝 App ID: ${app_id} ..."
             mas install "${app_id}" || echo "⚠️  警告：安裝 ${app_id} 失敗 (請確認是否已購買/登入)"
        fi
    done
}

function main() {
    install_mas

    # 僅在非 CI 環境下執行 (CI 通常無法登入 App Store)
    if ! "${CI:-false}"; then
        install_mas_apps
    else
        echo "⚙️  CI 環境偵測：跳過 MAS 應用程式安裝"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
