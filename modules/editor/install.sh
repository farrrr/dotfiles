#!/bin/bash
# 安裝 Neovim
set -euo pipefail

source "${DOTFILES_DIR}/modules/_common.sh"

install_neovim() {
    if has_command nvim; then
        log_info "Neovim 已安裝，跳過"
        return
    fi

    case "${DOTFILES_OS}" in
        darwin)
            ensure_brew
            brew install neovim
            ;;
        linux)
            if has_command snap; then
                sudo snap install nvim --classic
            else
                # 使用 AppImage
                local nvim_url="https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage"
                curl -fsSLO "${nvim_url}"
                chmod +x nvim-linux-x86_64.appimage
                sudo mv nvim-linux-x86_64.appimage /usr/local/bin/nvim
            fi
            ;;
    esac
    log_ok "Neovim 安裝完成"
}

install_neovim
