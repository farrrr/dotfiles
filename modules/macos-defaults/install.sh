#!/bin/bash
# 設定 macOS 系統偏好
set -euo pipefail

source "${DOTFILES_DIR}/modules/_common.sh"

if [[ "${DOTFILES_OS}" != "darwin" ]]; then
    log_warn "macOS Defaults 僅適用於 macOS，跳過"
    exit 0
fi

log_info "套用 macOS 系統偏好設定..."

# --- 鍵盤 ---
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# --- 觸控板 ---
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2.5

# --- Finder ---
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# --- Dock ---
defaults write com.apple.dock tilesize -int 36
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.5

# --- 截圖 ---
defaults write com.apple.screencapture location -string "${HOME}/Desktop"
defaults write com.apple.screencapture type -string "png"

# --- 重新啟動受影響的應用程式 ---
for app in "Dock" "Finder"; do
    killall "${app}" &>/dev/null || true
done

log_ok "macOS 系統偏好設定完成（部分設定需要重新登入才生效）"
