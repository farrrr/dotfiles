#!/usr/bin/env bash

set -Eeuo pipefail

# 如果設置了 DOTFILES_DEBUG 環境變數，則啟用 debug 模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 定義常量
readonly FZF_DIR="${HOME%/}/.fzf"
readonly FZF_URL="https://github.com/junegunn/fzf.git"

# 檢查是否已安裝 fzf
function is_fzf_installed() {
    command -v fzf >/dev/null 2>&1
}

# 克隆 fzf 倉庫
function clone_fzf() {
    echo "正在克隆 fzf 倉庫..."

    if [ ! -d "${FZF_DIR}" ]; then
        git clone "${FZF_URL}" "${FZF_DIR}"
    else
        echo "fzf 倉庫已存在，正在更新..."
        cd "${FZF_DIR}"
        git pull
        cd - >/dev/null
    fi
}

# 安裝 fzf
function install_fzf() {
    echo "正在安裝 fzf..."
    local install_fzf_path="${FZF_DIR%/}/install"

    # 安裝二進制檔案和自動完成腳本
    "${install_fzf_path}" --bin
    "${install_fzf_path}" --completion
}

# 卸載 fzf
function uninstall_fzf() {
    echo "正在卸載 fzf..."
    local uninstall_fzf_path="${FZF_DIR%/}/uninstall"

    if [ -f "${uninstall_fzf_path}" ]; then
        "${uninstall_fzf_path}"
    fi

    # 清理 fzf 目錄
    rm -rfv "${FZF_DIR}"

    # 清理可能存在的其他 fzf 檔案
    rm -fv "${HOME}/.fzf.bash"
    rm -fv "${HOME}/.fzf.zsh"
    rm -fv "${HOME}/.config/fzf"
}

# 主函數
function main() {
    echo "開始安裝 fzf..."

    # 檢查是否已安裝
    if is_fzf_installed; then
        echo "fzf 已安裝，版本："
        fzf --version
        return 0
    fi

    # 克隆並安裝
    clone_fzf
    install_fzf

    echo "fzf 安裝完成！"
}

# 檢查腳本是否直接執行（而非被導入）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
