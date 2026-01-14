#!/usr/bin/env bash

# 設定 Shell 安全選項
set -Eeuo pipefail

# 除錯模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 定義常數
readonly BIN_DIR="${HOME}/.local/bin"

# 函式：安裝 Oh My Posh
function install_oh_my_posh() {
    echo "🔍 正在檢查 oh-my-posh 環境..."

    # 檢查是否已安裝
    if command -v oh-my-posh >/dev/null 2>&1; then
        echo "✅ oh-my-posh 已安裝，版本：$(oh-my-posh --version | head -n 1)"
        return 0
    fi

    echo "⬇️  未偵測到 oh-my-posh，正在安裝..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS: 使用 Homebrew 安裝
        if command -v brew >/dev/null 2>&1; then
            echo "📦 [macOS] 透過 Homebrew 安裝 oh-my-posh..."
            brew install jandedobbeleer/oh-my-posh/oh-my-posh
        else
            echo "⚠️  未偵測到 Homebrew，使用 Generic 方式安裝..."
            install_oh_my_posh_generic
        fi
    else
        # Linux / Other: 使用 Generic 方式
        install_oh_my_posh_generic
    fi

    echo "✅ oh-my-posh 安裝完成！"
}

# 函式：通用安裝方式 (Official Installer)
function install_oh_my_posh_generic() {
    echo "📦 [Generic] 透過官方腳本安裝 oh-my-posh..."

    # 確保 bin 目錄存在
    if [[ ! -d "${BIN_DIR}" ]]; then
        mkdir -p "${BIN_DIR}"
    fi

    # 官方安裝指令
    # 參考: https://ohmyposh.dev/docs/installation/linux
    if curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "${BIN_DIR}"; then
        echo "✅ 安裝成功 (Installed to ${BIN_DIR})"
    else
        echo "❌ 安裝失敗"
        return 1
    fi
}

function main() {
    install_oh_my_posh
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
