#!/usr/bin/env bash

# 設定 Shell 安全選項
set -Eeuo pipefail

# 除錯模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 定義常數
readonly BIN_DIR="${HOME}/.local/bin"

# 函式：安裝 Starship
function install_starship() {
    echo "🔍 正在檢查 starship 環境..."

    # 檢查是否已安裝
    if command -v starship >/dev/null 2>&1; then
        echo "✅ starship 已安裝，版本：$(starship --version | head -n 1)"
        return 0
    fi

    echo "⬇️  未偵測到 starship，正在安裝..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS: 使用 Homebrew 安裝
        if command -v brew >/dev/null 2>&1; then
            echo "📦 [macOS] 透過 Homebrew 安裝 starship..."
            brew install starship
        else
            echo "⚠️  未偵測到 Homebrew，使用 Generic 方式安裝..."
            install_starship_generic
        fi
    else
        # Linux / Other: 使用 Generic 方式
        install_starship_generic
    fi

    echo "✅ starship 安裝完成！"
}

# 函式：通用安裝方式 (Official Installer)
function install_starship_generic() {
    echo "📦 [Generic] 透過官方腳本安裝 starship..."

    local install_url="https://starship.rs/install.sh"

    # 確保 bin 目錄存在
    if [[ ! -d "${BIN_DIR}" ]]; then
        mkdir -p "${BIN_DIR}"
    fi

    # 嘗試安裝到 ~/.local/bin 以避免 sudo (如果不需要 sudo 即可寫入)
    # 官方腳本支援 --bin-dir
    if curl -sS "${install_url}" | sh -s -- --yes --bin-dir "${BIN_DIR}"; then
        echo "✅ 安裝成功 (Installed to ${BIN_DIR})"
    else
        echo "⚠️  安裝到使用者目錄失敗，嘗試全域安裝 (可能需要 sudo)..."
        curl -sS "${install_url}" | sh -s -- --yes
    fi
}

function main() {
    install_starship
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
