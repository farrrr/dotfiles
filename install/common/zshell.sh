#!/usr/bin/env bash

# 設定 Shell 安全選項
set -Eeuo pipefail

# 除錯模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 函式：安裝 Zsh
function install_zsh() {
    echo "🔍 正在檢查 Zsh 環境..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if ! command -v brew >/dev/null 2>&1; then
            echo "⚠️  未偵測到 Homebrew，跳過 Zsh 安裝 (macOS 通常已內建 Zsh，但建議使用 Homebrew 版本)"
        else
            echo "📦 [macOS] 透過 Homebrew 安裝/更新 Zsh..."
            brew install zsh || true
        fi
    elif [[ -f /etc/debian_version ]]; then
        # Debian/Ubuntu
        echo "📦 [Linux] 透過 apt 安裝 Zsh..."
        if ! command -v zsh >/dev/null 2>&1; then
            sudo apt-get update && sudo apt-get install -y zsh
        else
            echo "✅ Zsh 已安裝"
        fi
    else
        echo "⚠️  不支援的作業系統，跳過 Zsh 安裝"
    fi
}

# 函式：設定預設 Shell
function set_default_shell() {
    local zsh_path
    zsh_path="$(command -v zsh)"

    # [macOS] 強制優先使用 Homebrew 安裝的 Zsh
    # 避免使用系統內建較舊版本的 /bin/zsh
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if [ -x "/opt/homebrew/bin/zsh" ]; then
            zsh_path="/opt/homebrew/bin/zsh"
        elif [ -x "/usr/local/bin/zsh" ]; then
            zsh_path="/usr/local/bin/zsh"
        fi
    fi

    if [ -z "$zsh_path" ]; then
        echo "❌ 找不到 Zsh 可執行檔，無法設定為預設 Shell"
        return
    fi

    echo "🔍 偵測到的 Zsh 路徑: $zsh_path"

    # 檢查是否已經是預設 Shell
    if [ "$SHELL" == "$zsh_path" ]; then
        echo "✅ Zsh 已經是您的預設 Shell"
        return
    fi

    # 檢查 Zsh 是否在 /etc/shells 中
    if ! grep -q "$zsh_path" /etc/shells; then
        echo "📝 將 $zsh_path 加入 /etc/shells..."
        # 需 sudo 權限
        echo "$zsh_path" | sudo tee -a /etc/shells >/dev/null
    fi

    echo "🔄 正在將預設 Shell 更改為 Zsh..."
    # 嘗試更改 Shell (可能會詢問密碼)
    if chsh -s "$zsh_path"; then
        echo "✅ 預設 Shell 已更改為 Zsh (請重新登入以生效)"
    else
        echo "⚠️  無法自動更改 Shell，請手動執行: chsh -s $zsh_path"
    fi
}

function main() {
    install_zsh
    set_default_shell
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
