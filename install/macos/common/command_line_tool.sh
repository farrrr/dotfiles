#!/usr/bin/env bash

# 設定 Shell 安全選項
set -Eeuo pipefail

# 除錯模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 函式：安裝 macOS Command Line Tools
function install_command_line_tool() {
    echo "🔍 正在檢查 Command Line Tools..."

    # 檢查是否已安裝 Command Line Tools
    # xcode-select -p 會回傳安裝路徑 (例如 /Library/Developer/CommandLineTools)
    if xcode-select -p &>/dev/null; then
        echo "✅ Command line developer tools 已安裝。"
        return 0
    fi

    echo "⬇️  未偵測到 CLT，正在觸發安裝..."

    # 觸發安裝視窗
    xcode-select --install

    echo "⚠️  Command Line Tools 安裝已觸發！"
    echo "👉 請在彈出的視窗中點擊 '安裝' 並同意授權協議..."
    echo "⏳ 等待安裝完成..."

    # 迴圈檢查直到安裝完成
    # 當 xcode-select -p 成功回傳路徑時，代表安裝完成
    until xcode-select -p &>/dev/null; do
        sleep 5
        echo -n "."
    done

    echo ""
    echo "✅ Command Line Tools 安裝完成！"
}

function main() {
    install_command_line_tool
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
