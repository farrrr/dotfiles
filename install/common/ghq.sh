#!/usr/bin/env bash

set -Eeuo pipefail

# 如果設置了 DOTFILES_DEBUG 環境變數，則啟用 debug 模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 設定 ghq 目錄
readonly GHQ_DIR="${HOME%/}/codebase"

# 設置 ghq 目錄
function setup_ghq_dir() {
    echo "正在設置 ghq 目錄..."

    # 創建 ghq 目錄
    if [ ! -d "${GHQ_DIR}" ]; then
    mkdir -p "${GHQ_DIR}"
        echo "已創建 ghq 目錄：${GHQ_DIR}"
    else
        echo "ghq 目錄已存在：${GHQ_DIR}"
    fi
}

# 主函數
function main() {
    echo "開始設置 ghq 環境..."
    setup_ghq_dir
    echo "ghq 環境設置完成！"
}

# 檢查腳本是否直接執行（而非被導入）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
