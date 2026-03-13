#!/bin/bash
# 所有 module 共用的輔助函式

log_info() { echo -e "\033[0;34m[INFO]\033[0m $*"; }
log_ok()   { echo -e "\033[0;32m[ OK ]\033[0m $*"; }
log_warn() { echo -e "\033[0;33m[WARN]\033[0m $*"; }
log_err()  { echo -e "\033[0;31m[ERR ]\033[0m $*"; }

# 檢查指令是否存在
has_command() { command -v "$1" &>/dev/null; }

# 確認 Homebrew 已安裝（macOS）
ensure_brew() {
    if ! has_command brew; then
        log_info "安裝 Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Apple Silicon 路徑
        if [[ -f /opt/homebrew/bin/brew ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
}
