#!/bin/bash
# 安裝 Git 相關工具：Delta
set -euo pipefail

source "${DOTFILES_DIR}/modules/_common.sh"

install_delta() {
    if has_command delta; then
        log_info "Delta 已安裝，跳過"
        return
    fi

    case "${DOTFILES_OS}" in
        darwin)
            ensure_brew
            brew install git-delta
            ;;
        linux)
            if has_command cargo; then
                cargo install git-delta
            else
                log_warn "Delta 需要 cargo，建議先安裝 runtime module"
            fi
            ;;
    esac
    log_ok "Delta 安裝完成"
}

install_delta
log_ok "Git module 完成（ghq 由 mise 管理）"
