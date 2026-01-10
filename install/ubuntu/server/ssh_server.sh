#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

function is_installed() {
    command -v "$1" &>/dev/null
}

function install_openssh_server() {
    if dpkg -s openssh-server >/dev/null 2>&1; then
        echo "✅ openssh-server 已安裝。"
    else
        echo "⬇️  正在安裝 openssh-server..."
        sudo apt-get update && sudo apt-get install --no-install-recommends -y \
            vim \
            openssh-server
    fi
}

function setup_sshd() {
    echo "⚙️  設定 sshd..."
    sudo mkdir -p /var/run/sshd
    mkdir -p "${HOME}/.ssh"

    local ssh_port="${SSH_PORT:-22}"

    # 修改 sshd_config
    # 允許 Root 登入 (通常在 Docker 容器內需要)
    sudo sed -i 's/^#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
    sudo sed -i 's/^#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config

    # 設定 Port
    if grep -q "^Port" /etc/ssh/sshd_config; then
        sudo sed -i "s/^Port .*/Port ${ssh_port}/" /etc/ssh/sshd_config
    else
        sudo sed -i "s/^#Port .*/Port ${ssh_port}/" /etc/ssh/sshd_config
    fi

    # Listen Address 0.0.0.0
    sudo sed -i 's/^#ListenAddress 0.0.0.0/ListenAddress 0.0.0.0/' /etc/ssh/sshd_config

    # 開啟 Pubkey Auth
    sudo sed -i 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

    # PAM fix for Docker (解決登入後立即斷線問題)
    sudo sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

    # 驗證設定檔
    sudo /usr/sbin/sshd -t

    # 確保 authorized_keys 存在與權限正確
    touch "${HOME}/.ssh/authorized_keys"
    chmod 600 "${HOME}/.ssh/authorized_keys"
    chmod 700 "${HOME}/.ssh"
}

function run_sshd() {
    echo "🚀 啟動 sshd..."
    if command -v service >/dev/null 2>&1; then
        sudo service ssh start
    else
        echo "⚠️  'service' command not found. 嘗試手動啟動..."
        if [ -x /usr/sbin/sshd ]; then
            sudo /usr/sbin/sshd
        fi
    fi
}

function main() {
    install_openssh_server
    setup_sshd
    run_sshd
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # 僅在 Docker 環境或強制變數下執行
    if [ -f "/.dockerenv" ] || [ "${FORCE_SSHD_INSTALL:-}" == "true" ]; then
        main
    else
        echo "ℹ️  非 Docker 環境，跳過 SSH Server 設定 (可設定 FORCE_SSHD_INSTALL=true 強制執行)。"
    fi
fi
