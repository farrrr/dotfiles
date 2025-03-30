#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# shellcheck disable=SC2016
declare -r DOTFILES_LOGO='
           https://github.com/farrrr/dotfiles
'

# 定義常量
declare -r DOTFILES_REPO_URL="https://github.com/farrrr/dotfiles"
declare -r BRANCH_NAME="${BRANCH_NAME:-main}"
declare -r DOTFILES_GITHUB_PAT="${DOTFILES_GITHUB_PAT:-}"

# 檢查是否在 CI 環境中運行
function is_ci() {
    "${CI:-false}"
}

# 檢查是否有可用的 TTY
function is_tty() {
    [ -t 0 ]
}

# 檢查是否沒有可用的 TTY
function is_not_tty() {
    ! is_tty
}

# 檢查是否在 CI 環境中或沒有可用的 TTY
function is_ci_or_not_tty() {
    is_ci || is_not_tty
}

# 註冊退出時執行的命令
function at_exit() {
    AT_EXIT+="${AT_EXIT:+$'\n'}"
    AT_EXIT+="${*?}"
    # shellcheck disable=SC2064
    trap "${AT_EXIT}" EXIT
}

# 獲取作業系統類型
function get_os_type() {
    uname
}

# 在 Linux 上保持 sudo 權限活動
function keepalive_sudo_linux() {
    # 預先請求 sudo 密碼
    echo "正在檢查 \`sudo\` 權限，可能需要輸入您的密碼。"
    sudo -v

    # 保持活動：如果設置了，更新現有的 sudo 時間戳；否則不做任何事情
    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" || exit
    done 2>/dev/null &
}

# 在 macOS 上保持 sudo 權限活動
function keepalive_sudo_macos() {
    # 參考：https://github.com/reitermarkus/dotfiles/blob/master/.sh#L85-L116
    (
        builtin read -r -s -p "密碼：" </dev/tty
        builtin echo "add-generic-password -U -s 'dotfiles' -a '${USER}' -w '${REPLY}'"
    ) | /usr/bin/security -i
    printf "\n"
    at_exit "
                echo -e '\033[0;31m從鑰匙圈中移除密碼…\033[0m'
                /usr/bin/security delete-generic-password -s 'dotfiles' -a '${USER}'
            "
    SUDO_ASKPASS="$(/usr/bin/mktemp)"
    at_exit "
                echo -e '\033[0;31m刪除 SUDO_ASKPASS 腳本…\033[0m'
                /bin/rm -f '${SUDO_ASKPASS}'
            "
    {
        echo "#!/bin/sh"
        echo "/usr/bin/security find-generic-password -s 'dotfiles' -a '${USER}' -w"
    } >"${SUDO_ASKPASS}"

    /bin/chmod +x "${SUDO_ASKPASS}"
    export SUDO_ASKPASS

    if ! /usr/bin/sudo -A -kv 2>/dev/null; then
        echo -e '\033[0;31m密碼不正確。\033[0m' 1>&2
        exit 1
    fi
}

# 根據系統類型保持 sudo 權限
function keepalive_sudo() {
    local ostype
    ostype="$(get_os_type)"

    echo "為 ${ostype} 設定 sudo 權限"

    if [ "${ostype}" == "Darwin" ]; then
        keepalive_sudo_macos
    elif [ "${ostype}" == "Linux" ]; then
        keepalive_sudo_linux
    else
        echo "無效的作業系統類型：${ostype}" >&2
        exit 1
    fi
}

# 初始化 macOS 環境
function initialize_os_macos() {
    function is_homebrew_exists() {
        command -v brew &>/dev/null
    }

    # 如需要，安裝 Homebrew
    if ! is_homebrew_exists; then
        echo "安裝 Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        echo "Homebrew 已安裝"
    fi

    # 設定 Homebrew 環境變數
    if [[ $(arch) == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ $(arch) == "i386" || $(arch) == "x86_64" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    else
        echo "無效的 CPU 架構：$(arch)" >&2
        exit 1
    fi
}

# 初始化 Linux 環境
function initialize_os_linux() {
    echo "初始化 Linux 環境..."
    # 在這裡添加 Linux 特定的初始化步驟
}

# 根據系統類型初始化環境
function initialize_os_env() {
    local ostype
    ostype="$(get_os_type)"

    echo "為 ${ostype} 初始化作業系統環境"

    if [ "${ostype}" == "Darwin" ]; then
        initialize_os_macos
    elif [ "${ostype}" == "Linux" ]; then
        initialize_os_linux
    else
        echo "無效的作業系統類型：${ostype}" >&2
        exit 1
    fi
}

# 執行 chezmoi 安裝和配置
function run_chezmoi() {
    echo "安裝 chezmoi..."

    # 檢查是否已安裝 chezmoi
    if command -v chezmoi >/dev/null 2>&1; then
        echo "chezmoi 已安裝"
        local chezmoi_cmd="chezmoi"
    else
        # 從 URL 下載 chezmoi 二進制檔案
        echo "下載 chezmoi..."
        sh -c "$(curl -fsLS get.chezmoi.io)"
        local chezmoi_cmd="./bin/chezmoi"
    fi

    # 設定 TTY 選項
    local no_tty_option=""
    if is_ci_or_not_tty; then
        no_tty_option="--no-tty"  # /dev/tty 不可用（特別是在 CI 環境中）
    fi

    echo "初始化 chezmoi..."
    # 執行 `chezmoi init` 設定源目錄，
    # 生成配置檔案，並選擇性地更新目標目錄以匹配目標狀態
    if ! "${chezmoi_cmd}" init "${DOTFILES_REPO_URL}" \
        --force \
        --branch "${BRANCH_NAME}" \
        --use-builtin-git true \
        ${no_tty_option}; then
        echo "初始化 chezmoi 失敗" >&2
        exit 1
    fi

    # `age` 命令需要 tty，但在 GitHub Actions 中沒有 tty。
    # 因此，目前很難在此工作流程中解密使用 `age` 加密的檔案。
    # 暫時從 chezmoi 的控制中移除加密的目標檔案。
    if is_ci_or_not_tty; then
        echo "在 CI 環境中移除加密檔案..."
        find "$(${chezmoi_cmd} source-path)" -type f -name "encrypted_*" -exec rm -fv {} +
    fi

    # 將 $HOME/.local/bin 添加到 PATH 中，以安裝必要的二進制檔案
    export PATH="${PATH}:${HOME}/.local/bin"

    # 設定 GitHub PAT 環境變數（如果有）
    if [[ -n "${DOTFILES_GITHUB_PAT}" ]]; then
        export DOTFILES_GITHUB_PAT
    fi

    # 執行 `chezmoi apply` 確保目標檔案處於目標狀態，
    # 必要時更新它們
    echo "應用 chezmoi 配置..."
    "${chezmoi_cmd}" apply ${no_tty_option}

    # 清理 chezmoi 二進制檔案
    if [[ "${chezmoi_cmd}" == "./bin/chezmoi" ]]; then
        echo "清理 chezmoi 二進制檔案..."
        rm -fv "${chezmoi_cmd}"
    fi

    echo "安裝完成！"
}

# 初始化 dotfiles
function initialize_dotfiles() {
    echo "開始初始化 dotfiles..."

    if ! is_ci_or_not_tty; then
        # GitHub 工作流程中的 /dev/tty 不可用。
        # 在 GitHub 工作流程中，我們可以使用無密碼的 sudo。
        # 因此，跳過 sudo 保持活動功能。
        keepalive_sudo
    fi
    run_chezmoi
}

# 從 chezmoi 獲取系統類型
function get_system_from_chezmoi() {
    local system
    system=$(chezmoi data | jq -r '.system')
    echo "${system}"
}

# 根據系統類型重啟 shell
function restart_shell_system() {
    local system
    system=$(get_system_from_chezmoi)

    echo "準備以登入 shell 方式重啟 shell（重新加載 .zprofile 或 .profile）"

    # 無論是 client 或 server 環境都使用 zsh
    /bin/zsh --login
}

# 重啟 shell
function restart_shell() {
    # 如果指定了 "bash -c $(curl -L {URL})"，則重啟 shell
    # 不重啟：
    #   curl -L {URL} | bash
    if [ -p /dev/stdin ]; then
        echo "繼續重啟您的 shell"
    else
        echo "正在重啟您的 shell..."
        restart_shell_system
    fi
}

# 檢查並安裝 zsh（如果需要）
function ensure_zsh_installed() {
    local ostype
    ostype="$(get_os_type)"

    # 檢查 zsh 是否已安裝
    if ! command -v zsh >/dev/null 2>&1; then
        echo "安裝 zsh..."

        if [ "${ostype}" == "Darwin" ]; then
            # macOS 通常已預裝 zsh，但如果沒有，使用 Homebrew 安裝
            brew install zsh
        elif [ "${ostype}" == "Linux" ]; then
            # 在 Linux 上安裝 zsh
            if command -v apt-get >/dev/null 2>&1; then
                sudo apt-get update
                sudo apt-get install -y zsh
            elif command -v yum >/dev/null 2>&1; then
                sudo yum install -y zsh
            elif command -v dnf >/dev/null 2>&1; then
                sudo dnf install -y zsh
            else
                echo "無法確定包管理器，請手動安裝 zsh" >&2
                return 1
            fi
        else
            echo "不支援的作業系統：${ostype}" >&2
            return 1
        fi
    else
        echo "zsh 已安裝"
    fi

    # 檢查 zsh 是否為默認 shell
    if [[ "$SHELL" != *"zsh"* ]]; then
        echo "設定 zsh 為默認 shell..."
        local zsh_path
        zsh_path="$(command -v zsh)"

        # 檢查 zsh 是否在 /etc/shells 中
        if ! grep -q "${zsh_path}" /etc/shells; then
            echo "添加 ${zsh_path} 到 /etc/shells"
            echo "${zsh_path}" | sudo tee -a /etc/shells
        fi

        # 更改默認 shell
        chsh -s "${zsh_path}"
    else
        echo "zsh 已是默認 shell"
    fi

    return 0
}

# 主函數
function main() {
    echo "$DOTFILES_LOGO"
    echo "歡迎使用 dotfiles 安裝腳本！"

    initialize_os_env
    ensure_zsh_installed
    initialize_dotfiles

    echo "dotfiles 安裝完成！"
    # restart_shell  # 已禁用，因為 at_exit 函數無法正常工作
}

# 執行主函數
main
