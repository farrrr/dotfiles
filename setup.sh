#!/usr/bin/env bash

# 設定 Shell 選項以提高安全性與除錯能力
# -E: ERR trap 被 shell 函式繼承
# -e: 若指令回傳非零值則立即退出
# -u: 讀取未設定的變數視為錯誤
# -o pipefail: Pipeline 中只要有一個指令失敗，整個 Pipeline 即視為失敗
set -Eeuo pipefail

# 若已設定 DOTFILES_DEBUG 環境變數，則開啟除錯模式 (印出執行指令)
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# shellcheck disable=SC2016
declare -r DOTFILES_LOGO='
             *** This is setup script for my dotfiles setup ***
                     https://github.com/farrrr/dotfiles
'

declare -r DOTFILES_REPO_URL="https://github.com/farrrr/dotfiles"
declare -r BRANCH_NAME="${BRANCH_NAME:-main}"
declare -r OS_TYPE="$(uname)"

# 檢查是否在 CI 環境中執行
function is_ci() {
    "${CI:-false}"
}

# 檢查是否在 TTY (終端機) 環境中執行
function is_tty() {
    [ -t 0 ]
}

# 檢查是否不在 TTY 環境中
function is_not_tty() {
    ! is_tty
}

# 檢查是否為 CI 環境或非 TTY 環境
# 用於決定是否需要互動式操作或略過某些需要互動的步驟
function is_ci_or_not_tty() {
    is_ci || is_not_tty
}

# 註冊在腳本結束時 (EXIT) 執行的指令
# 透過此函式可以堆疊多個 cleanup 指令
function at_exit() {
    AT_EXIT+="${AT_EXIT:+$'\n'}"
    AT_EXIT+="${*?}"
    # shellcheck disable=SC2064
    trap "${AT_EXIT}" EXIT
}

# Linux 系統的 sudo 權限保持 (Keepalive)
function keepalive_sudo_linux() {
    # 既然都需要密碼，不如一開始就先問？
    echo "Checking for \`sudo\` access which may request your password."
    sudo -v

    # 保持連線：背景執行迴圈，每 60 秒更新一次 sudo 時間戳
    # 如果已設定 sudo 權限則更新，否則不動作
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &
}

# macOS 系統的 sudo 權限保持 (Keepalive)
# 使用 macOS Keychain 來安全地儲存並提取密碼，以供 sudo 使用
function keepalive_sudo_macos() {
    # 參考: https://github.com/reitermarkus/dotfiles/blob/master/.sh#L85-L116

    # 1. 讀取密碼並存入 Keychain (使用 security 指令)
    (
        builtin read -r -s -p "Password: " </dev/tty
        builtin echo "add-generic-password -U -s 'dotfiles' -a '${USER}' -w '${REPLY}'"
    ) | /usr/bin/security -i
    printf "\n"

    # 2. 註冊清理動作：腳本結束時從 Keychain 移除密碼
    at_exit "
                echo -e '\033[0;31mRemoving password from Keychain …\033[0m'
                /usr/bin/security delete-generic-password -s 'dotfiles' -a '${USER}'
            "

    # 3. 建立 ASKPASS 腳本，供 sudo 自動讀取密碼
    SUDO_ASKPASS="$(/usr/bin/mktemp)"
    at_exit "
                echo -e '\033[0;31mDeleting SUDO_ASKPASS script …\033[0m'
                /bin/rm -f '${SUDO_ASKPASS}'
            "
    {
        echo "#!/bin/sh"
        echo "/usr/bin/security find-generic-password -s 'dotfiles' -a '${USER}' -w"
    } >"${SUDO_ASKPASS}"

    /bin/chmod +x "${SUDO_ASKPASS}"
    export SUDO_ASKPASS

    # 4. 驗證 sudo 密碼是否正確
    if ! /usr/bin/sudo -A -kv 2>/dev/null; then
        echo -e '\033[0;31mIncorrect password.\033[0m' 1>&2
        exit 1
    fi
}

# 根據 OS 類型保持 sudo 權限
function keepalive_sudo() {
    if [ "${OS_TYPE}" == "Darwin" ]; then
        keepalive_sudo_macos
    elif [ "${OS_TYPE}" == "Linux" ]; then
        keepalive_sudo_linux
    else
        echo "Invalid OS type: ${OS_TYPE}" >&2
        exit 1
    fi
}

# macOS 初始化設定
function initialize_os_macos() {
    function is_homebrew_exists() {
        command -v brew &>/dev/null
    }

    # 檢查並安裝 Homebrew
    if ! is_homebrew_exists; then
        echo "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew is already installed."
    fi

    # 檢查並安裝 1Password CLI
    if ! command -v op &>/dev/null; then
        echo "1Password CLI not found. Installing via Homebrew..."
        brew install --cask 1password-cli
    else
        echo "1Password CLI is already installed."
    fi

    # 設定 Homebrew 環境變數 (供後續指令使用)
    if [[ $(arch) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ $(arch) == "i386" || $(arch) == "x86_64" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    else
        echo "Invalid CPU arch: $(arch)" >&2
        exit 1
    fi
}

# Linux 初始化設定
function initialize_os_linux() {
    # 基本相依性檢查
    local missing_deps=()
    if ! command -v curl &>/dev/null; then missing_deps+=("curl"); fi
    if ! command -v git &>/dev/null; then missing_deps+=("git"); fi
    if ! command -v gpg &>/dev/null; then missing_deps+=("gpg"); fi
    if ! command -v unzip &>/dev/null; then missing_deps+=("unzip"); fi

    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "Missing required dependencies: ${missing_deps[*]}"

        # 嘗試自動安裝 (僅支援 apt/Ubuntu/Debian)
        if command -v apt-get &>/dev/null; then
            echo "Attempting to install missing dependencies via apt-get..."
            # 確保有 sudo 權限 (假設 keepalive_sudo 已經處理，或此處會觸發 sudo)
            if sudo apt-get update && sudo apt-get install -y "${missing_deps[@]}"; then
                echo "Successfully installed dependencies."
            else
                echo "Failed to install dependencies automatically."
            fi
        fi

        echo "Please install them manually using your package manager (apt, pacman, etc.) and run this script again."
        exit 1
    fi

    # 安裝 1Password CLI
    if ! command -v op &>/dev/null; then
        echo "Installing 1Password CLI..."
        # 設定 Keyring 目錄
        export GNUPGHOME="${HOME}/.gnupg"
        mkdir -p "${GNUPGHOME}"
        chmod 700 "${GNUPGHOME}"

        # 下載並加入 1Password GPG Key
        curl -sS https://downloads.1password.com/linux/keys/1password.asc | \
            sudo gpg --dearmor --output /usr/share/keyrings/1password-archive-keyring.gpg

        # 加入 1Password Apt Repository
        echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] https://downloads.1password.com/linux/debian/amd64 stable main' | \
            sudo tee /etc/apt/sources.list.d/1password.list

        # 安裝 op
        sudo apt-get update && sudo apt-get install -y 1password-cli
    else
        echo "1Password CLI is already installed."
    fi
}

# 根據 OS 執行對應的初始化
function initialize_os_env() {
    if [ "${OS_TYPE}" == "Darwin" ]; then
        initialize_os_macos
    elif [ "${OS_TYPE}" == "Linux" ]; then
        initialize_os_linux
    else
        echo "Invalid OS type: ${OS_TYPE}" >&2
        exit 1
    fi
}

# 下載並執行 chezmoi 進行 dotfiles 部署
function run_chezmoi() {
    # 優先使用系統 PATH 中的 chezmoi
    if command -v chezmoi &>/dev/null; then
        echo "Found existing chezmoi in PATH: $(command -v chezmoi)"
        local chezmoi_cmd="chezmoi"
    else
        # 若無，則下載至 ~/.local/bin
        local bin_dir="${HOME}/.local/bin"
        mkdir -p "${bin_dir}"
        export PATH="${PATH}:${bin_dir}"

        if [ ! -x "${bin_dir}/chezmoi" ]; then
            echo "chezmoi not found. Downloading to ${bin_dir}..."
            sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "${bin_dir}"
        fi
        local chezmoi_cmd="${bin_dir}/chezmoi"
    fi

    # 決定是否使用 --no-tty 選項
    if is_ci_or_not_tty; then
        no_tty_option="--no-tty" # /dev/tty 不可用（特別是在 CI 環境中）
    else
        no_tty_option="" # /dev/tty 可用，或者不是在 CI 環境中
    fi

    echo "Running chezmoi init..."
    # 執行 chezmoi init 以設定來源目錄，
    # 產生設定檔，並選擇性地更新目標目錄以符合目標狀態。
    "${chezmoi_cmd}" init "${DOTFILES_REPO_URL}" \
        --force \
        --branch "${BRANCH_NAME}" \
        --use-builtin-git true \
        ${no_tty_option}


    # 確保 PATH 包含 ~/.local/bin，因為 chezmoi apply 可能會安裝工具到這裡
    export PATH="${PATH}:${HOME}/.local/bin"

    echo "Running chezmoi apply..."
    # 執行 chezmoi apply 以確保目標處於目標狀態，必要時進行更新。
    "${chezmoi_cmd}" apply ${no_tty_option}

    # 注意：我們不再刪除 chezmoi 執行檔，保留它以供日後使用。
    # rm -fv "${chezmoi_cmd}"
}

# Dotfiles 初始化的主流程
function initialize_dotfiles() {
    if ! is_ci_or_not_tty; then
        # - github workflow 的 /dev/tty 不可用。
        # - 我們可以在 github workflow 中使用無密碼 sudo。
        # 因此，若非 CI 環境才執行 sudo keep alive。
        keepalive_sudo
    fi
    run_chezmoi
}

# 從 chezmoi data 取得 system 類型 (client/server)
function get_system_from_chezmoi() {
    local system
    # 使用 chezmoi execute-template 直接取得變數值，避免依賴 jq
    system=$(chezmoi execute-template '{{ .system }}' 2>/dev/null || echo "")
    if [ -z "$system" ] || [ "$system" == "null" ] || [ "$system" == "<no value>" ]; then
        # Fallback: 若無法讀取，預設為 client (最常見情況) 或提示錯誤
        # 這裡假設若無法判斷則不強制退出，留給 restart_shell_system 判斷
        echo "unknown"
    else
        echo "${system}"
    fi
}

# 重新啟動 Shell 以套用變更
function restart_shell_system() {
    local system
    system=$(get_system_from_chezmoi)

    echo "Determined system type: ${system}"

    # 手動執行清理，因為 exec 會取代目前行程，導致 trap EXIT 失效
    if [ -n "${AT_EXIT:-}" ]; then
        eval "${AT_EXIT}"
    fi

    # 以登入 shell 執行 (為了重新載入 .zprofile 或 .profile)
    # 使用 exec 取代目前行程
    if [ "${system}" == "client" ]; then
        echo "Replacing current setup process with zsh..."
        exec /bin/zsh --login

    elif [ "${system}" == "server" ]; then
        echo "Replacing current setup process with bash..."
        exec /bin/bash --login

    else
        echo "Could not determine system type (client/server) or invalid type: '${system}'"
        echo "Please restart your shell manually."
        exit 0
    fi
}

# 決定是否自動重啟 Shell
function restart_shell() {
    # 檢查是否透過 pipe 執行 (例如: curl ... | bash)
    # 如果是 pipe 執行，通常不適合直接 exec 取代 shell
    if [ -p /dev/stdin ]; then
        echo "Setup finished. Please restart your shell manually or run 'exec zsh' (or bash)."
    else
        echo "Restarting your shell..."
        restart_shell_system
    fi
}

function main() {
    echo "${DOTFILES_LOGO}"

    echo "=== Initializing OS Environment ==="
    initialize_os_env

    echo "=== Initializing Dotfiles with chezmoi ==="
    initialize_dotfiles

    echo "=== Setup Complete ==="
    restart_shell
}

main
