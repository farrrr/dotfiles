#!/usr/bin/env bash

# 設定 Shell 安全選項
set -Eeuo pipefail

# 除錯模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 設定安裝路徑 (僅 Linux 用)
readonly BIN_DIR="${HOME}/.local/bin"

# 函式：安裝 Sheldon
function install_sheldon() {
    echo "🔍 正在檢查 sheldon 環境..."

    if command -v sheldon >/dev/null 2>&1; then
        echo "✅ sheldon 已安裝。"
    else
        echo "⬇️  未偵測到 sheldon，正在安裝..."

        if [[ "$OSTYPE" == "darwin"* ]]; then
            # macOS: 優先使用 Homebrew
            if command -v brew >/dev/null 2>&1; then
                echo "📦 [macOS] 透過 Homebrew 安裝 sheldon..."
                brew install sheldon
            else
                echo "⚠️  未偵測到 Homebrew，嘗試使用通用腳本安裝..."
                install_sheldon_generic
            fi
        else
            # Linux / Generic
            install_sheldon_generic
        fi
    fi
}

# 函式：通用安裝 (使用官方安裝腳本)
function install_sheldon_generic() {
    # 確保 bin 目錄存在
    mkdir -p "${BIN_DIR}"
    echo "📦 [Generic] 下載並安裝 sheldon 至 ${BIN_DIR}..."

    # 使用官方腳本安裝 pre-built binary
    # --repo: 指定倉庫
    # --to: 指定安裝目錄
    # --force: 強制覆蓋
    curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | \
        bash -s -- --repo rossmacarthur/sheldon --to "${BIN_DIR}" --force

    echo "✅ sheldon 安裝完成！"
}

# 函式：移除 Sheldon (供參考)
function uninstall_sheldon() {
    rm "${BIN_DIR}/sheldon"
}

function main() {
    install_sheldon
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
