#!/usr/bin/env bash

# 設定 Shell 安全選項
set -Eeuo pipefail

# 除錯模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 函式：安裝 1Password CLI
function install_op() {
    echo "🔍 正在檢查 1Password CLI (op)..."

    # 檢查是否已安裝 op
    if command -v op >/dev/null 2>&1; then
        echo "✅ 1Password CLI (op) 已安裝"
        return
    fi

    echo "⬇️  未偵測到 op，正在安裝..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        if ! command -v brew >/dev/null 2>&1; then
            echo "⚠️  未偵測到 Homebrew，跳過 1Password CLI 安裝"
        else
            echo "📦 [macOS] 透過 Homebrew Cask 安裝 1Password CLI..."
            brew install --cask 1password-cli
        fi
    elif [[ -f /etc/debian_version ]]; then
        # Debian/Ubuntu
        echo "📦 [Linux] 設定 1Password 官方倉庫並安裝..."

        # 1. 加入 GPG Key
        echo "   - 下載 GPG Key..."
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
            sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

        # 2. 加入 Apt Repository
        echo "   - 加入 Apt 來源..."
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/$(dpkg --print-architecture) stable main" | \
            sudo tee /etc/apt/sources.list.d/1password.list

        # 3. 設定 debsig-verify 策略 (用於驗證 .deb 簽署)
        echo "   - 設定簽章驗證策略..."
        sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
        curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol | \
            sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol
        sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
            sudo gpg --dearmor --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg

        # 4. 安裝
        echo "   - 執行 apt update 並安裝..."
        sudo apt-get update && sudo apt-get install -y 1password-cli
    else
        echo "⚠️  不支援的作業系統，跳過 1Password CLI 安裝"
    fi
}

# 函式：檢查並登入 1Password
function check_and_signin() {
    # 確保 op 已安裝
    if ! command -v op >/dev/null 2>&1; then
        return
    fi

    echo "🔐 正在檢查 1Password 登入狀態..."

    # op whoami 回傳非 0 代表未登入
    if ! op whoami >/dev/null 2>&1; then
        echo "⚠️  未偵測到登入狀態，正在嘗試登入..."
        echo "   (若為桌面版，請留意系統跳出的授權/指紋提示)"

        # 嘗試登入 (eval 確保環境變數設定正確，雖然 op signin 主要用於輸出 token，但在整合模式下通常只需觸發授權)
        # 為了相容性，我們嘗試直接執行 op signin 讓使用者互動，或者僅觸發 GUI
        if eval $(op signin); then
             echo "✅ 1Password 登入成功！"
        else
             echo "❌ 1Password 登入失敗 (或使用者取消)，請稍後手動執行 'op signin'"
        fi
    else
        echo "✅ 1Password 已登入"
    fi
}

function main() {
    install_op
    check_and_signin
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
