#!/usr/bin/env bash

# 設定 Shell 安全選項
set -Eeuo pipefail

# 除錯模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 函式：安裝/更新 Homebrew
function install_homebrew() {
    echo "🔍 正在檢查 Homebrew 環境..."

    if ! command -v brew &>/dev/null; then
        echo "⬇️  未偵測到 Homebrew，正在安裝..."

        # 使用官方安裝腳本
        # NONINTERACTIVE=1: 非互動模式 (自動同意)
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        echo "⚙️  正在設定 Homebrew shellenv..."

        # 根據 CPU 架構決定路徑
        local brew_prefix
        if [[ "$(uname -m)" == "arm64" ]]; then
             brew_prefix="/opt/homebrew"
        else
             brew_prefix="/usr/local"
        fi

        # 嘗試載入 shellenv 以便當前 Session 可使用 brew
        if [[ -f "${brew_prefix}/bin/brew" ]]; then
            eval "$(${brew_prefix}/bin/brew shellenv)"
            echo "✅ Homebrew 安裝完成！"
        else
            echo "⚠️  無法自動定位 Homebrew 路徑，請手動確認安裝結果。"
        fi

    else
        echo "✅ Homebrew 已安裝，正在檢查更新..."

        # 避免 brew update 輸出過多提示 (如 "Run brew help to get started")
        export HOMEBREW_NO_ENV_HINTS=1

        if brew update; then
             echo "✅ Homebrew 更新完成"
        else
             echo "⚠️  Homebrew 更新遇到問題 (可忽略)"
        fi
    fi
}

# 函式：關閉 Analytics (隱私保護)
function opt_out_of_analytics() {
    if command -v brew &>/dev/null; then
        echo "🛡️  關閉 Homebrew Analytics..."
        brew analytics off
    fi
}

function main() {
    install_homebrew
    opt_out_of_analytics
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
