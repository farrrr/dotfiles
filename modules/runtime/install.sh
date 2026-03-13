#!/bin/bash
# 安裝 Mise 並設定語言工具鏈
set -euo pipefail

source "${DOTFILES_DIR}/modules/_common.sh"

install_mise() {
    if has_command mise; then
        log_info "Mise 已安裝，跳過"
        return
    fi

    curl https://mise.run | sh
    export PATH="${HOME}/.local/bin:${PATH}"
    log_ok "Mise 安裝完成"
}

setup_tools() {
    log_info "安裝 Mise 管理的工具..."
    mise install --yes
    log_ok "Mise 工具安裝完成"
}

install_mise
setup_tools
