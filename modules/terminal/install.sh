#!/bin/bash
# 安裝 Ghostty 終端機
set -euo pipefail

source "${DOTFILES_DIR}/modules/_common.sh"

install_ghostty() {
    if has_command ghostty; then
        log_info "Ghostty 已安裝，跳過"
        return
    fi

    case "${DOTFILES_OS}" in
        darwin)
            ensure_brew
            brew install --cask ghostty
            ;;
        linux)
            log_warn "Ghostty Linux 版請參考 https://ghostty.org/download"
            ;;
    esac
    log_ok "Ghostty 安裝完成"
}

install_ghostty
