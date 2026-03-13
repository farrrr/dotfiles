#!/bin/bash
# 安裝 Docker：macOS 用 OrbStack，Linux 用 Docker Engine
set -euo pipefail

source "${DOTFILES_DIR}/modules/_common.sh"

install_docker() {
    case "${DOTFILES_OS}" in
        darwin)
            if [[ -d "/Applications/OrbStack.app" ]]; then
                log_info "OrbStack 已安裝，跳過"
                return
            fi
            ensure_brew
            brew install --cask orbstack
            log_ok "OrbStack 安裝完成"
            ;;
        linux)
            if has_command docker; then
                log_info "Docker 已安裝，跳過"
                return
            fi
            curl -fsSL https://get.docker.com | sh
            sudo usermod -aG docker "${USER}"
            log_ok "Docker Engine 安裝完成（需重新登入以套用群組權限）"
            ;;
    esac
}

install_docker
