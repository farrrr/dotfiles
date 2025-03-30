#!/bin/bash

# 檢查系統需求
function check_system_requirements() {
    if ! command -v brew &> /dev/null; then
        echo "錯誤：需要先安裝 Homebrew"
        exit 1
    fi
}

# 檢查是否已安裝
function check_starship_installed() {
    if command -v starship &> /dev/null; then
        echo "Starship 已安裝"
        return 0
    else
        return 1
    fi
}

# 安裝 Starship
function install_starship() {
    echo "正在安裝 Starship..."
    brew install starship
}

# 驗證安裝
function verify_installation() {
    if check_starship_installed; then
        echo "Starship 安裝成功"
        starship --version
        return 0
    else
        echo "Starship 安裝失敗"
        return 1
    fi
}

# 清理
function cleanup() {
    echo "清理中..."
    # 移除不必要的依賴
    brew autoremove
    brew cleanup
}

# 移除 Starship
function uninstall_starship() {
    echo "正在移除 Starship..."
    brew uninstall starship
    cleanup
}

# 主函數
function main() {
    echo "開始安裝 Starship..."

    # 檢查系統需求
    check_system_requirements

    # 檢查是否已安裝
    if check_starship_installed; then
        echo "Starship 已經安裝，跳過安裝步驟"
        return 0
    fi

    # 安裝 Starship
    install_starship

    # 驗證安裝
    if ! verify_installation; then
        echo "安裝失敗"
        exit 1
    fi

    # 清理
    cleanup

    echo "Starship 安裝完成"
}

# 執行主函數
main