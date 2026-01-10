#!/usr/bin/env bash

# 設定 Shell 安全選項
set -Eeuo pipefail

# 除錯模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 定義常數
readonly FZF_DIR="${HOME}/.fzf"
readonly FZF_URL="https://github.com/junegunn/fzf.git"

# 函式：安裝 FZF
function install_fzf() {
    echo "🔍 正在檢查 fzf 環境..."

    # 檢查是否已安裝
    if command -v fzf >/dev/null 2>&1; then
        echo "✅ fzf 已安裝，版本：$(fzf --version | awk '{print $1}')"
        return 0
    fi

    echo "⬇️  未偵測到 fzf，正在安裝..."

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS: 使用 Homebrew 安裝
        if command -v brew >/dev/null 2>&1; then
            echo "📦 [macOS] 透過 Homebrew 安裝 fzf..."
            brew install fzf

            # 安裝按鍵綁定與自動補全 (Homebrew 版通常需要手動觸發 install 腳本)
            local brew_prefix
            brew_prefix="$(brew --prefix)"
            local fzf_install_script="${brew_prefix}/opt/fzf/install"

            if [[ -f "${fzf_install_script}" ]]; then
                echo "⚙️  正在設定 fzf 按鍵綁定與自動補全..."
                # --all: 啟用所有功能 (key-bindings, completion, update-rc)
                # --no-update-rc: 如果不想讓它自動修改 rc 檔，可加此參數。
                # 這裡我們先不加 --no-update-rc，讓它幫忙設定，或者由 dotfiles 統一管理。
                # 考慮到 dotfiles 會覆蓋 .zshrc，這裡最好只產生 .fzf.zsh/.bash 而不修改主要 rc
                "${fzf_install_script}" --all --no-update-rc --key-bindings --completion
            fi
        else
            echo "⚠️  未偵測到 Homebrew，使用 Generic 方式安裝..."
            install_fzf_generic
        fi
    else
        # Linux / Other: 使用 Generic 方式 (Git Clone)
        install_fzf_generic
    fi

    echo "✅ fzf 安裝完成！"
}

# 函式：通用安裝方式 (Git Clone)
function install_fzf_generic() {
    echo "📦 [Generic] 透過 Git Cloning 安裝 fzf..."

    if [ ! -d "${FZF_DIR}" ]; then
        git clone --depth 1 "${FZF_URL}" "${FZF_DIR}"
    else
        echo "🔄 fzf 倉庫已存在，正在更新..."
        git -C "${FZF_DIR}" pull
    fi

    echo "⚙️  執行安裝腳本..."
    # --bin: 加入 symlink 到 /usr/local/bin 或 .fzf/bin
    # --completion: 產生自動補全
    # --no-update-rc: 不修改 User 的 Shell Config (由我們自己的 dotfiles 管理)
    "${FZF_DIR}/install" --bin --completion --no-update-rc
}

function main() {
    install_fzf
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
