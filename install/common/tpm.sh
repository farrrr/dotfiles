#!/usr/bin/env bash

set -Eeuo pipefail

# 如果設置了 DOTFILES_DEBUG 環境變數，則啟用 debug 模式
if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# 設定目錄
readonly TMUX_PLUGINS_DIR="${HOME%/}/.tmux/plugins"
readonly TPM_DIR="${TMUX_PLUGINS_DIR}/tpm"

# 檢查是否已安裝 tmux-mem-cpu-load
function is_tmux_mem_cpu_load_installed() {
    command -v "tmux-mem-cpu-load" &>/dev/null
}

# 克隆 TPM 倉庫
function clone_tpm() {
    echo "正在克隆 TPM 倉庫..."
    local dir="$1"
    local url="https://github.com/tmux-plugins/tpm"

    if [ ! -d "${dir}" ]; then
        git clone "${url}" "${dir}"
        echo "TPM 倉庫克隆成功"
    else
        echo "TPM 倉庫已存在"
    fi
}

# 安裝 TPM 插件
function install_tpm_plugins() {
    echo "正在安裝 TPM 插件..."
    local dir="$1"
    local cmd="${dir%/}/scripts/install_plugins.sh"

    if [ -f "${cmd}" ]; then
    "${cmd}"
        echo "TPM 插件安裝成功"
    else
        echo "錯誤：找不到 TPM 插件安裝腳本" >&2
        return 1
    fi
}

# 安裝 TPM
function install_tpm() {
    echo "開始安裝 TPM..."
    export TMUX_PLUGIN_MANAGER_PATH="${TMUX_PLUGINS_DIR}"

    if [ ! "${DOTFILES_DEBUG:-}" ] || [ ! -d "${TPM_DIR}" ]; then
        clone_tpm "${TPM_DIR}"
        install_tpm_plugins "${TPM_DIR}"
    else
        echo "TPM 已安裝，跳過安裝步驟"
    fi
}

# 安裝 tmux-mem-cpu-load
function install_tmux_mem_cpu_load() {
    echo "開始安裝 tmux-mem-cpu-load..."

    if [ ! "${DOTFILES_DEBUG:-}" ] && is_tmux_mem_cpu_load_installed; then
        echo "tmux-mem-cpu-load 已安裝，跳過安裝步驟"
        return 0
    fi

    local tmux_mem_cpu_load_url="https://github.com/thewtex/tmux-mem-cpu-load.git"
    local tmp_dir
    tmp_dir="$(mktemp -d /tmp/tmux-mem-cpu-load-XXXXXXXXXX)"

    echo "正在克隆 tmux-mem-cpu-load 倉庫..."
    git clone "${tmux_mem_cpu_load_url}" "${tmp_dir}"

    echo "正在編譯 tmux-mem-cpu-load..."
    cd "${tmp_dir}" || exit 1
    cmake . -DCMAKE_INSTALL_PREFIX="${HOME%/}/.local/"
    make
    make install

    # 清理臨時目錄
    rm -rf "${tmp_dir}"

    if is_tmux_mem_cpu_load_installed; then
        echo "tmux-mem-cpu-load 安裝成功"
    else
        echo "錯誤：tmux-mem-cpu-load 安裝失敗" >&2
        return 1
    fi
}

# 卸載 TPM
function uninstall_tpm() {
    echo "正在卸載 TPM..."
    if [ -d "${TPM_DIR}" ]; then
    rm -rfv "${TPM_DIR}"
        echo "TPM 卸載成功"
    else
        echo "TPM 未安裝，無需卸載"
    fi
}

# 卸載 tmux-mem-cpu-load
function uninstall_tmux_mem_cpu_load() {
    echo "正在卸載 tmux-mem-cpu-load..."
    if is_tmux_mem_cpu_load_installed; then
    rm -fv "${HOME%/}/.local/bin/tmux-mem-cpu-load"
        echo "tmux-mem-cpu-load 卸載成功"
    else
        echo "tmux-mem-cpu-load 未安裝，無需卸載"
    fi
}

# 主函數
function main() {
    echo "開始設置 tmux 插件環境..."
    install_tpm
    install_tmux_mem_cpu_load
    echo "tmux 插件環境設置完成！"
}

# 檢查腳本是否直接執行（而非被導入）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
