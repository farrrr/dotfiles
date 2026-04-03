#!/bin/bash
# 安裝 Shell 環境：Zsh + Sheldon + Oh My Posh
set -euo pipefail

source "${DOTFILES_DIR}/modules/_common.sh"

# --- 安裝 Zsh ---
install_zsh() {
    if has_command zsh; then
        log_info "Zsh 已安裝，跳過"
        return
    fi

    case "${DOTFILES_OS}" in
        darwin)
            ensure_brew
            brew install zsh
            ;;
        linux)
            sudo apt-get update && sudo apt-get install -y zsh
            ;;
    esac

    # 設為預設 Shell
    local zsh_path
    zsh_path="$(which zsh)"
    if ! grep -qF "${zsh_path}" /etc/shells; then
        echo "${zsh_path}" | sudo tee -a /etc/shells
    fi
    sudo chsh -s "${zsh_path}" "${USER}"
    log_ok "Zsh 安裝完成並設為預設 Shell"
}

# --- 安裝 Sheldon ---
install_sheldon() {
    if has_command sheldon; then
        log_info "Sheldon 已安裝，跳過"
        return
    fi

    case "${DOTFILES_OS}" in
        darwin)
            ensure_brew
            brew install sheldon
            ;;
        linux)
            mkdir -p ~/.local/bin
            curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
                | bash -s -- --repo "rossmacarthur/sheldon" --to ~/.local/bin
            ;;
    esac
    log_ok "Sheldon 安裝完成"
}

# --- 安裝 Oh My Posh ---
install_oh_my_posh() {
    if has_command oh-my-posh; then
        log_info "Oh My Posh 已安裝，跳過"
        return
    fi

    case "${DOTFILES_OS}" in
        darwin)
            ensure_brew
            brew install jandedobbeleer/oh-my-posh/oh-my-posh
            ;;
        linux)
            # Oh My Posh 安裝腳本需要 unzip
            if ! has_command unzip; then
                sudo apt-get update && sudo apt-get install -y unzip
            fi
            curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
            ;;
    esac
    log_ok "Oh My Posh 安裝完成"
}

install_zsh
install_sheldon
install_oh_my_posh
