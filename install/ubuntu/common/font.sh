#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

readonly FONT_DIR="${HOME%/}/.local/share/fonts"
readonly NERD_FONT_ROBOTO_MONO="Roboto Mono Nerd Font Complete.ttf"
readonly NERD_FONT_HACK_MONO="Hack Regular Nerd Font Complete Mono.ttf"
readonly MESLO_FONT="MesloLGS NF Regular.ttf"

# 安裝單個字體檔案
function install_font() {
    local font_url="$1"
    local font_name="$2"

    echo "正在安裝字體：${font_name}"
    mkdir -p "${FONT_DIR}"
    curl -fSL "${font_url}" -o "${FONT_DIR%/}/${font_name}"
}

# 安裝本地字體檔案
function install_local_font() {
    local font_path="$1"
    local font_name="$(basename "${font_path}")"

    echo "正在安裝本地字體：${font_name}"
    mkdir -p "${FONT_DIR}"
    cp -f "${font_path}" "${FONT_DIR%/}/${font_name}"
}

# 安裝所有本地字體
function install_all_local_fonts() {
    local fonts_dir="${HOME}/.local/share/chezmoi/install/media/fonts"

    if [ ! -d "${fonts_dir}" ]; then
        echo "本地字體目錄不存在：${fonts_dir}"
        return
    fi

    echo "正在安裝本地字體..."
    for font in "${fonts_dir}"/*.ttf; do
        if [ -f "${font}" ]; then
            install_local_font "${font}"
        fi
    done
}

function install_nerd_font_roboto_mono() {
    local font_url="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/RobotoMono/Medium/RobotoMonoNerdFontMono-Medium.ttf"
    install_font "${font_url}" "${NERD_FONT_ROBOTO_MONO}"
}

function install_nerd_font_hack_mono() {
    local font_url="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/HackNerdFontMono-Regular.ttf"
    install_font "${font_url}" "${NERD_FONT_HACK_MONO}"
}

function install_meslo_font() {
    local font_url="https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
    install_font "${font_url}" "${MESLO_FONT}"
}

function uninstall_nerd_font_roboto_mono() {
    rm -fv "${FONT_DIR}/${NERD_FONT_ROBOTO_MONO}"
}

function uninstall_nerd_font_hack_mono() {
    rm -fv "${FONT_DIR}/${NERD_FONT_HACK_MONO}"
}

function uninstall_meslo_font() {
    rm -fv "${FONT_DIR}/${MESLO_FONT}"
}

function main() {
    echo "開始安裝字體..."

    # 安裝 Nerd Fonts
    install_nerd_font_roboto_mono
    install_nerd_font_hack_mono

    # 安裝 MesloLGS NF
    install_meslo_font

    # 安裝本地字體
    install_all_local_fonts

    # 更新字體快取
    echo "更新字體快取..."
    fc-cache -f -v

    echo "字體安裝完成！"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
