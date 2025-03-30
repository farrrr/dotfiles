#!/usr/bin/env bash

set -Eeuo pipefail

# 如果設置了 DOTFILES_DEBUG 環境變數，則啟用 debug 模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 檢查是否為 macOS 系統
function is_macos() {
    [[ "$(uname)" == "Darwin" ]]
}

# 檢查命令列工具是否已安裝
function is_command_line_tool_installed() {
    local git_cmd_path="/Library/Developer/CommandLineTools/usr/bin/git"
    [[ -e "${git_cmd_path}" ]]
}

# 檢查 Xcode 是否已安裝
function is_xcode_installed() {
    [[ -d "/Applications/Xcode.app" ]]
}

# 安裝命令列工具
function install_command_line_tool() {
    if ! is_macos; then
        echo "此腳本僅適用於 macOS 系統" >&2
        exit 1
    fi

    if is_command_line_tool_installed; then
        echo "命令列工具已安裝"
        return 0
    fi

    if is_xcode_installed; then
        echo "Xcode 已安裝，無需安裝命令列工具"
        return 0
    fi

    echo "正在安裝命令列工具..."
    if ! xcode-select --install; then
        echo "啟動命令列工具安裝失敗" >&2
        exit 1
    fi

    echo "請等待安裝完成後按下任意鍵繼續..."
    IFS= read -r -n 1 -d ''
    # IFS= 防止前導空白被移除
    # -r 防止反斜線被當作跳脫字元
    # -n 1 只讀取一個字元
    # -d '' 使用空字串作為分隔符，允許讀取任何字元

    if ! is_command_line_tool_installed; then
        echo "命令列工具安裝失敗" >&2
        exit 1
    fi

    echo "命令列工具安裝成功"
}

# 主函數
function main() {
    install_command_line_tool
}

# 檢查腳本是否直接執行（而非被導入）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
