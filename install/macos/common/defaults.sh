#!/usr/bin/env bash

# 設定 Shell 安全選項
set -Eeuo pipefail

# 除錯模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# -----------------------------------------------------------------------------
# macOS 系統預設值 (Defaults) 設定腳本
# -----------------------------------------------------------------------------

function defaults_ui() {
    echo "⚙️  設定 UI/UX 偏好..."

    # 外觀: 深色模式 (Dark Mode)
    defaults write NSGlobalDomain AppleInterfaceStyle -string "Dark"

    # 關閉開機音效
    # sudo nvram SystemAudioVolume=" "

    # 在登入畫面點擊時鐘顯示 IP/Hostname 等資訊
    sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

    # 關閉 "應用程式下載自網際網路" 的提示 (Quarantine)
    defaults write com.apple.LaunchServices LSQuarantine -bool false

    # 透過各種方式關閉螢幕保護程式 (僅供參考，視需求開啟)
    defaults -currentHost write com.apple.screensaver idleTime -int 0
}

function defaults_keyboard() {
    echo "⌨️  設定鍵盤偏好..."

    # 設定按鍵重複速度 (KeyRepeat: 越小越快, InitialKeyRepeat: 首次重複延遲)
    # KeyRepeat: 1 (15ms) - 2 (30ms) is common.
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15

    # 關閉 "自然" 捲動 (還原傳統捲動方向)
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

    # 啟用全鍵盤控制 (Tab 鍵可切換所有控制項)
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
}

function defaults_trackpad() {
    echo "🖱️  設定觸控板偏好..."

    # 啟用輕觸點擊 (Tap to click)
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

    # 啟用三指拖移 (3-finger drag)
    # 註：在較新 macOS 版本中，此選項被移至 Accessibility，可能需要特殊權限或不同指令
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
}

function defaults_controlcenter() {
    echo "🎛️  設定控制中心..."
    # 顯示藍牙圖示
    defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true
}

function defaults_dock() {
    echo "⚓️  設定 Dock..."

    # 自動隱藏 Dock
    defaults write com.apple.dock autohide -bool true

    # 將視窗縮小進應用程式圖像中 (Minimize windows into application icon)
    defaults write com.apple.dock minimize-to-application -bool true

    # 按一下背景圖片來顯示桌面：僅在「幕前調度」 (Stage Manager Only)
    # 這意味著在標準模式下，點擊桌布不會顯示桌面
    defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false

    # 設定圖示大小 (30px)
    defaults write com.apple.dock tilesize -int 30

    # 禁止 Mission Control 自動重新排列 Spaces
    defaults write com.apple.dock mru-spaces -bool false

    # 清空 Dock 固定應用程式 (重置為僅包含下列指定項目)
    defaults write com.apple.dock persistent-apps -array ""
    defaults write com.apple.dock recent-apps -array ""
    defaults write com.apple.dock persistent-others -array ""

    # 輔助函式：產生 Dock Item XML
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

    # 輔助函式：取得系統設定 App 路徑 (相容不同 macOS 版本)
    function get_system_app_path() {
        local system_preferences_path="/System/Applications/System Preferences.app/"
        local system_settings_path="/System/Applications/System Settings.app/"

        if [ -e "${system_preferences_path}" ]; then
            echo "${system_preferences_path}"
        elif [ -e "${system_settings_path}" ]; then
            echo "${system_settings_path}"
        else
            echo "⚠️  無法找到 System Settings App" >&2
        fi
    }

    # 設定 Dock 項目 (依序加入)
    defaults write com.apple.dock persistent-apps -array \
        "$(dock_item /Applications/Google\ Chrome.app)" \
        "$(dock_item /Applications/Visual\ Studio\ Code.app)" \
        "$(dock_item /Applications/Ghostty.app)" \
        "$(dock_item "$(get_system_app_path)")"
}

function defaults_finder() {
    echo "🔍 設定 Finder..."

    # 新視窗預設開啟 Home 目錄
    defaults write com.apple.finder NewWindowTarget -string "PfHm"
    defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

    # 顯示所有副檔名
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # 更改副檔名時不顯示警告
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # 顯示狀態列 (Status Bar)
    defaults write com.apple.finder ShowStatusBar -bool true

    # 顯示路徑列 (Path Bar)
    defaults write com.apple.finder ShowPathbar -bool true

    # 預設與分組方式：名稱
    defaults write com.apple.finder FXPreferredGroupBy -string "Name"
    defaults write com.apple.finder FXArrangeGroupViewBy -string "Name"

    # 避免在網路與 USB 儲存裝置上建立 .DS_Store
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    # 自動從垃圾桶刪除 30 天前的項目
    defaults write com.apple.finder FXRemoveOldTrashItems -bool true
}

function defaults_screencapture() {
    echo "📸 設定截圖..."

    # 儲存路徑：~/Pictures/
    defaults write com.apple.screencapture location -string "${HOME}/Pictures/"

    # 檔案名稱前綴
    defaults write com.apple.screencapture name -string "ScreenShot"

    # 不顯示浮動縮圖 (直接存檔)
    defaults write com.apple.screencapture show-thumbnail -bool false
}

function defaults_lockscreen() {
    echo "🔒 設定鎖定畫面與電源管理..."

    # 閒置時關閉顯示器：永不 (Never sleep display)
    # 注意：這可能需要 sudo 權限
    sudo pmset -a displaysleep 0

    # 螢幕保護程式啟動或螢幕關閉後，需要輸入密碼的延遲時間：1 小時 (3600 秒)
    # askForPassword: 1 (開啟)
    # askForPasswordDelay: 3600 (秒)
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 3600
}

function defaults_input_sources() {
    # echo "⌨️  設定輸入法..."

    # 針對不同視窗自動切換輸入法
    # defaults write com.apple.HIToolbox AppleGlobalTextInputProperties -dict TextInputGlobalPropertyPerContextInput -bool true
    :
}

function kill_affected_applications() {
    echo "🔄 重啟相關應用程式以套用設定..."

    local apps=(
        "Activity Monitor"
        "Calendar"
        "cfprefsd"
        "Dock"
        "Finder"
        "SystemUIServer"
    )
    for app in "${apps[@]}"; do
        killall "${app}" &>/dev/null || true
    done
}

function main() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        echo "⚠️  非 macOS 系統，跳過 defaults 設定。"
        return 0
    fi

    echo "⚙️  開始套用 macOS 系統預設值..."
    echo "🔑 此腳本包含電源管理設定，可能會要求 sudo 密碼..."
    sudo -v

    defaults_ui
    defaults_dock
    defaults_finder
    defaults_keyboard
    defaults_trackpad
    defaults_controlcenter
    defaults_input_sources
    defaults_screencapture
    defaults_lockscreen

    kill_affected_applications

    echo "✅ macOS 系統設定完成！"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
