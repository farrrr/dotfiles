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

# gh CLI 需要先裝好並認證，mise install 才有 GITHUB_TOKEN 避免 rate limit
install_gh() {
    if has_command gh; then
        log_info "GitHub CLI 已安裝，跳過"
    else
        case "${DOTFILES_OS}" in
            darwin)
                ensure_brew
                brew install gh
                ;;
            linux)
                # GitHub 官方 apt repo
                curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
                    | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
                    | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
                sudo apt-get update && sudo apt-get install -y gh
                ;;
        esac
        log_ok "GitHub CLI 安裝完成"
    fi

    # 確認已登入，未登入則引導認證
    if ! gh auth status &>/dev/null; then
        log_info "請登入 GitHub CLI（用於 mise 下載工具時的 API 認證）"
        gh auth login
    fi

    # 設定 GITHUB_TOKEN 供 mise 使用
    export GITHUB_TOKEN
    GITHUB_TOKEN="$(gh auth token 2>/dev/null || true)"
}

setup_tools() {
    log_info "安裝 Mise 管理的工具..."
    mise install --yes
    log_ok "Mise 工具安裝完成"
}

install_mise
install_gh
setup_tools
