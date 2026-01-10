#!/usr/bin/env bash

# 設定 Shell 安全選項
set -Eeuo pipefail

# 除錯模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 設定 Mise 安裝路徑變數
export MISE_INSTALL_PATH="${HOME}/.local/bin/mise"

# 函式：安裝或更新 Mise
function install_mise() {
    # 官方網站: https://mise.jdx.dev
    echo "🔍 正在檢查 mise 環境..."

    # 檢查是否已安裝 mise
    if command -v mise >/dev/null 2>&1; then
        echo "✅ mise 已安裝，正在執行自我更新..."
        # 執行 self-update，並自動確認 (-y)
        mise self-update -y
    else
        echo "⬇️  未偵測到 mise，正在安裝..."
        # 使用官方安裝腳本，並導向至 sh 執行
        # 預設會安裝至 ~/.local/bin/mise
        curl https://mise.run | sh

        echo "✅ mise 安裝完成！"
    fi
}

function main() {
    install_mise
}

# 確保腳本是被直接執行而非 sourced 時才執行 main
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
