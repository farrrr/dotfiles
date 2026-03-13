#!/bin/bash
# 安裝 MesloLGS Nerd Font
set -euo pipefail

source "${DOTFILES_DIR}/modules/_common.sh"

FONT_NAME="MesloLGS Nerd Font"
FONT_REPO="ryanoasis/nerd-fonts"
FONT_ASSET="Meslo.tar.xz"

install_font() {
    local font_dir
    case "${DOTFILES_OS}" in
        darwin) font_dir="${HOME}/Library/Fonts/MesloLGS_NF" ;;
        linux)  font_dir="${HOME}/.local/share/fonts/MesloLGS_NF" ;;
        windows) font_dir="${USERPROFILE:-$HOME}/AppData/Local/Microsoft/Windows/Fonts/MesloLGS_NF" ;;
    esac

    if [[ -d "${font_dir}" ]] && [[ -n "$(ls -A "${font_dir}" 2>/dev/null)" ]]; then
        log_info "${FONT_NAME} 已安裝，跳過"
        return
    fi

    log_info "下載 ${FONT_NAME}..."
    local tmp_dir
    tmp_dir="$(mktemp -d)"
    local latest_url="https://github.com/${FONT_REPO}/releases/latest/download/${FONT_ASSET}"
    curl -fsSL "${latest_url}" | tar -xJ -C "${tmp_dir}"

    mkdir -p "${font_dir}"
    find "${tmp_dir}" -name "*.ttf" -exec cp {} "${font_dir}/" \;
    rm -rf "${tmp_dir}"

    # Linux 需要更新字型快取
    if [[ "${DOTFILES_OS}" == "linux" ]] && has_command fc-cache; then
        fc-cache -fv "${font_dir}"
    fi

    log_ok "${FONT_NAME} 安裝完成"
}

install_font
