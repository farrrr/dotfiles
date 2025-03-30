#!/usr/bin/env bash

set -Eeuo pipefail

# 如果設置了 DOTFILES_DEBUG 環境變數，則啟用 debug 模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 設定 UI 相關選項
function defaults_ui() {
    # 在選單列顯示電池百分比
    defaults write ~/Library/Preferences/ByHost/com.apple.controlcenter.plist BatteryShowPercentage -bool true
}

# 設定鍵盤相關選項
function defaults_keyboard() {
    # 設定快速鍵盤重複率
    defaults write NSGlobalDomain KeyRepeat -int 2
    # 設定較短的鍵盤重複延遲
    defaults write NSGlobalDomain InitialKeyRepeat -int 25
}

# 設定觸控板相關選項
function defaults_trackpad() {
    # 設定觸控板靈敏度
    defaults write -g com.apple.trackpad.scaling 2

    # 啟用點擊觸控板進行點選
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

    # 啟用三指拖曳
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
}

# 設定控制中心相關選項
function defaults_controlcenter() {
    # 在選單列顯示藍牙圖示
    defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true
}

# 設定 Dock 相關選項
function defaults_dock() {
    # 自動隱藏和顯示 Dock
    defaults write com.apple.dock autohide -bool true
    # 設定 Dock 圖示大小為 30 像素
    defaults write com.apple.dock tilesize -int 30
    # 停用 Mission Control 重新排列
    defaults write com.apple.dock mru-spaces -bool false

    # 清除 Dock 中的所有圖示
    defaults write com.apple.dock persistent-apps -array ""
    defaults write com.apple.dock recent-apps -array ""
    defaults write com.apple.dock persistent-others -array ""

    # 定義 Dock 項目格式
    function dock_item() {
        local app_file_path="$1"
        printf '
        <dict>
            <key>tile-data</key>
                <dict>
                    <key>file-data</key>
                        <dict>
                            <key>_CFURLString</key><string>%s</string>
                            <key>_CFURLStringType</key><integer>0</integer>
                        </dict>
                </dict>
        </dict>', "${app_file_path}"
    }

    # 獲取系統設定應用程式路徑
    function get_system_app_path() {
        local system_preferences_path="/System/Applications/System Preferences.app/"
        local system_settings_path="/System/Applications/System Settings.app/"

        if [ -e "${system_preferences_path}" ]; then
            echo "${system_preferences_path}"
        elif [ -e "${system_settings_path}" ]; then
            # 適用於 Ventura 及更新版本
            echo "${system_settings_path}"
        else
            echo "找不到系統設定應用程式" >&2
            exit 1
        fi
    }

    # 設定 Dock 固定應用程式
    defaults write com.apple.dock persistent-apps -array \
        "$(dock_item /Applications/Google\ Chrome.app)" \
        "$(dock_item /Applications/Visual\ Studio\ Code.app)" \
        "$(dock_item /Applications/Spark.app)" \
        "$(dock_item /Applications/DingTalk.app)" \
        "$(dock_item /Applications/Ghostty.app)" \
        "$(dock_item "$(get_system_app_path)")"
}

# 設定輸入法相關選項
function defaults_input_sources() {
    # 啟用「根據文件自動切換輸入法」
    defaults write com.apple.HIToolbox AppleGlobalTextInputProperties -dict TextInputGlobalPropertyPerContextInput -bool true
}

# 設定 Finder 相關選項
function defaults_finder() {
    # 設定新 Finder 視窗預設開啟位置為家目錄
    defaults write com.apple.finder NewWindowTarget -string "PfHm"
    defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

    # 顯示所有檔案副檔名
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    # 停用更改檔案副檔名時的警告
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false
    # 顯示狀態列
    defaults write com.apple.finder ShowStatusBar -bool true
    # 顯示路徑列
    defaults write com.apple.finder ShowPathbar -bool true

    # 設定檔案排序方式
    defaults write com.apple.finder FXPreferredGroupBy -string "Name"
    defaults write com.apple.finder FXArrangeGroupViewBy -string "Name"

    # 避免在網路或 USB 磁碟上建立 .DS_Store 檔案
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    # 啟用「30 天後自動移除垃圾桶項目」
    defaults write com.apple.finder FXRemoveOldTrashItems -bool true
}

# 設定螢幕截圖相關選項
function defaults_screencapture() {
    # 設定螢幕截圖儲存位置
    defaults write com.apple.screencapture location -string "${HOME}/Pictures/"
    defaults write com.apple.screencapture name -string "ScreenShot"

    # 停用螢幕截圖縮圖
    defaults write com.apple.screencapture show-thumbnail -bool false
}

# 設定 Siri 和聽寫相關選項
function defaults_assistant() {
    # 停用 Siri
    defaults write com.apple.assistant.support "Assistant Enabled" -bool false
    # 停用聽寫功能
    defaults write com.apple.HIToolbox AppleDictationAutoEnable -bool false
}

# 重新啟動受影響的應用程式
function kill_affected_applications() {
    local apps=(
        "Activity Monitor"
        "Calendar"
        "cfprefsd"
        "Dock"
        "Finder"
        "SystemUIServer"
    )
    for app in "${apps[@]}"; do
        killall "${app}" || true
    done
}

# 主函數
function main() {
    defaults_ui
    defaults_dock
    defaults_finder
    defaults_keyboard
    defaults_trackpad
    defaults_assistant
    defaults_controlcenter
    defaults_input_sources
    defaults_screencapture

    kill_affected_applications
}

# 檢查腳本是否直接執行（而非被導入）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
