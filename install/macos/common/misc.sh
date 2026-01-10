#!/usr/bin/env bash

# 設定 Shell 安全選項
set -Eeuo pipefail

# 除錯模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# -----------------------------------------------------------------------------
# 套件清單定義
# -----------------------------------------------------------------------------

# 核心工具 (Brew Packages)
# 注意：gh, ghq, go, jq 等工具已由 Mise 管理，故不在此列出
# 2026-01-10: 移除 zsh (已由 install-zshell.sh 處理)
readonly BREW_PACKAGES=(
    bat             # cat 的現代化替代品 (語法高亮、Git 整合)
    bat-extras      # bat 的額外腳本 (含 batgrep, batdiff 等)
    btop            # 資源監控儀表板 (比 top/htop 更現代化)
    curlie          # curl 的前端封裝 (結合 httpie 的介面)
    git-delta       # Git diff 語法高亮工具
    imagemagick     # 圖片處理工具 CLI
    neovim          # 現代化 Vim 編輯器
    prettyping      # ping 的美化輸出
    shellcheck      # Shell 腳本靜態分析工具
    unzip           # 解壓縮工具 (提供 zipinfo)
    vim             # 經典文字編輯器
    watchexec       # 監控檔案變更並自動執行指令
    wget            # 檔案下載工具
)

# 應用程式 (Cask Packages)
# 2026-01-10: 移除 1password (已由 install-op.sh 處理), ghostty (已由 install-ghostty.sh 處理)
readonly CASK_PACKAGES=(
    adobe-acrobat-reader  # PDF 閱讀器
    antigravity           # https://antigravity.google/ (需確認 Cask 是否存在)
    chatgpt               # OpenAI ChatGPT Desktop
    google-chrome         # Chrome 瀏覽器
    google-drive          # Google 雲端硬碟
    notion                # 筆記與協作工具
    raycast               # 系統啟動器 (替代 Spotlight)
    setapp                # Setapp 應用程式訂閱服務
    tower                 # Git GUI 用戶端
    visual-studio-code    # VS Code 編輯器
    wechat                # 微信
)

# -----------------------------------------------------------------------------
# 輔助函式
# -----------------------------------------------------------------------------

function is_brew_package_installed() {
    local package="$1"
    brew list "${package}" &>/dev/null
}

function install_brew_packages() {
    local missing_packages=()

    echo "🔍 檢查 Brew 套件..."
    for package in "${BREW_PACKAGES[@]}"; do
        if ! is_brew_package_installed "${package}"; then
            missing_packages+=("${package}")
        fi
    done

    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        echo "📦 正在安裝缺少的 Brew 套件: ${missing_packages[*]} ..."
        if "${CI:-false}"; then
            brew info "${missing_packages[@]}"
        else
            brew install "${missing_packages[@]}"
        fi
    else
        echo "✅ 所有 Brew 套件皆已安裝。"
    fi
}

function install_brew_cask_packages() {
    local missing_packages=()

    echo "🔍 檢查 Brew Cask 套件..."
    for package in "${CASK_PACKAGES[@]}"; do
        if ! is_brew_package_installed "${package}"; then
            missing_packages+=("${package}")
        fi
    done

    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        echo "📦 正在安裝缺少的 Cask 套件: ${missing_packages[*]} ..."
        if "${CI:-false}"; then
            brew info --cask "${missing_packages[@]}"
        else
            # 暫時忽略錯誤 (set +e) 以避免單一安裝失敗導致中斷
            set +e
            brew install --cask "${missing_packages[@]}"
            set -e
        fi
    else
        echo "✅ 所有 Cask 套件皆已安裝。"
    fi
}

function main() {
    # 僅在有 Homebrew 時執行
    if command -v brew &>/dev/null; then
        install_brew_packages
        install_brew_cask_packages
    else
        echo "⚠️  未偵測到 Homebrew，跳過 misc 安裝。"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
