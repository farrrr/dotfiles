#!/usr/bin/env bash

# 設定 Shell 安全選項
set -Eeuo pipefail

# 除錯模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 函式：安裝 Rosetta 2
function install_rosetta() {
    # 僅針對 Apple Silicon (arm64) 架構執行
    # 雖然上層 template 已做檢查，但腳本內部再次確認更保險
    if [[ "$(uname -m)" != "arm64" ]]; then
        return
    fi

    echo "🔍 正在檢查 Rosetta 2 環境..."

    # 檢查 Rosetta 是否已安裝
    # 透過檢查 /Library/Apple/usr/share/rosetta/rosetta 二進位檔是否存在
    local rosetta_path="/Library/Apple/usr/share/rosetta/rosetta"

    if [[ -f "${rosetta_path}" ]]; then
        echo "✅ Rosetta 2 已安裝"
    else
        echo "⬇️  未偵測到 Rosetta 2，正在安裝..."
        # 使用 softwareupdate 安裝
        # --install-rosetta: 安裝 Rosetta
        # --agree-to-license: 自動同意授權協議 (非互動模式)
        if softwareupdate --install-rosetta --agree-to-license; then
            echo "✅ Rosetta 2 安裝完成！"
        else
            echo "❌ Rosetta 2 安裝失敗，請嘗試手動執行 'softwareupdate --install-rosetta'"
            exit 1
        fi
    fi
}

function main() {
    install_rosetta
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
