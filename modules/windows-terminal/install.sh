#!/bin/bash
# Windows Terminal 與 PowerShell Profile 設定
set -euo pipefail

source "${DOTFILES_DIR}/modules/_common.sh"

if [[ "${DOTFILES_OS}" != "windows" ]]; then
    log_warn "Windows Terminal module 僅適用於 Windows，跳過"
    exit 0
fi

setup_powershell_profile() {
    local ps_profile_dir
    ps_profile_dir="$(wslpath "$(powershell.exe -NoProfile -Command '[Environment]::GetFolderPath("MyDocuments")' | tr -d '\r')")/PowerShell"

    if [[ ! -d "${ps_profile_dir}" ]]; then
        mkdir -p "${ps_profile_dir}"
    fi

    log_ok "PowerShell Profile 目錄就緒"
}

install_oh_my_posh_windows() {
    if powershell.exe -NoProfile -Command "Get-Command oh-my-posh -ErrorAction SilentlyContinue" &>/dev/null; then
        log_info "Oh My Posh (Windows) 已安裝，跳過"
        return
    fi

    log_info "安裝 Oh My Posh (Windows)..."
    powershell.exe -NoProfile -Command "winget install JanDeDobbeleer.OhMyPosh -s winget"
    log_ok "Oh My Posh (Windows) 安裝完成"
}

setup_powershell_profile
install_oh_my_posh_windows
