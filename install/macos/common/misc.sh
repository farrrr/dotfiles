#!/usr/bin/env bash

set -Eeuo pipefail

# 如果設置了 DOTFILES_DEBUG 環境變數，則啟用 debug 模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 定義需要安裝的 Homebrew 套件
readonly BREW_PACKAGES=(
    bats-core    # Bash 自動化測試系統
    gpg         # GNU 隱私保護工具
    imagemagick # 圖像處理工具
    jq          # JSON 處理工具
    htop        # 系統監控工具
    pinentry-mac # macOS 密碼輸入介面
    shellcheck  # Shell 腳本檢查工具
    vim         # 文字編輯器
    watchexec   # 檔案監視工具
    zsh         # Shell 環境
)

# 定義需要安裝的 Homebrew Cask 套件
readonly CASK_PACKAGES=(
    adobe-acrobat-reader    # PDF 閱讀器
    google-chrome          # 網頁瀏覽器
    google-drive          # 雲端儲存
    ngrok                 # 網路隧道工具
    visual-studio-code   # 程式碼編輯器
    tailscale           # VPN 服務
)

# 檢查 Homebrew 套件是否已安裝
function is_brew_package_installed() {
    local package="$1"
    brew list "${package}" &>/dev/null
}

# 安裝 Homebrew 套件
function install_brew_packages() {
    echo "正在檢查並安裝 Homebrew 套件..."
    local missing_packages=()

    # 檢查未安裝的套件
    for package in "${BREW_PACKAGES[@]}"; do
        if ! is_brew_package_installed "${package}"; then
            missing_packages+=("${package}")
            echo "發現未安裝的套件：${package}"
        fi
    done

    # 安裝缺失的套件
    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        echo "開始安裝 ${#missing_packages[@]} 個套件..."
        if "${CI:-false}"; then
            echo "CI 環境：僅顯示套件資訊"
            brew info "${missing_packages[@]}"
        else
            brew install --force "${missing_packages[@]}"
            echo "套件安裝完成！"
        fi
    else
        echo "所有 Homebrew 套件已安裝"
    fi
}

# 安裝 Homebrew Cask 套件
function install_brew_cask_packages() {
    echo "正在檢查並安裝 Homebrew Cask 套件..."
    local missing_packages=()

    # 檢查未安裝的套件
    for package in "${CASK_PACKAGES[@]}"; do
        if ! is_brew_package_installed "${package}"; then
            missing_packages+=("${package}")
            echo "發現未安裝的套件：${package}"
        fi
    done

    # 安裝缺失的套件
    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        echo "開始安裝 ${#missing_packages[@]} 個套件..."
        if "${CI:-false}"; then
            echo "CI 環境：僅顯示套件資訊"
            brew info --cask "${missing_packages[@]}"
        else
            brew install --cask --force "${missing_packages[@]}"
            echo "套件安裝完成！"
        fi
    else
        echo "所有 Homebrew Cask 套件已安裝"
    fi
}

# 設置 Google Chrome 為預設瀏覽器
function setup_google_chrome() {
    echo "正在設置 Google Chrome 為預設瀏覽器..."
    if [ -d "/Applications/Google Chrome.app" ]; then
        open "/Applications/Google Chrome.app" --args --make-default-browser
        echo "Google Chrome 已設置為預設瀏覽器"
    else
        echo "警告：找不到 Google Chrome 應用程式" >&2
    fi
}

# 主函數
function main() {
    echo "開始安裝系統套件..."
    install_brew_packages
    install_brew_cask_packages
    # setup_google_chrome  # 取消註解以啟用預設瀏覽器設置
    echo "系統套件安裝完成！"
}

# 檢查腳本是否直接執行（而非被導入）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
