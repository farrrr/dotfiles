#!/bin/sh
# Far's Dotfiles 一鍵安裝腳本
# 用法：curl -sL https://raw.githubusercontent.com/farrrr/dotfiles/main/install.sh | sh
set -e

REPO="farrrr/dotfiles"
BINARY="dotfiles-installer"

# 偵測 OS 與架構
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')

URL="https://github.com/${REPO}/releases/latest/download/${BINARY}-${OS}-${ARCH}"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "下載 installer..."
curl -sL "$URL" -o "${TMPDIR}/${BINARY}"
chmod +x "${TMPDIR}/${BINARY}"

echo "啟動安裝..."
"${TMPDIR}/${BINARY}"
