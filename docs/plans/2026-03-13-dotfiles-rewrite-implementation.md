# Dotfiles 全面改寫 - 實作計畫

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 從零建立模組化 dotfiles 系統，包含 bubbletea TUI 安裝器、chezmoi dotfile 同步、age 機密管理。

**Architecture:** 薄 installer（bubbletea Go binary）負責 TUI 互動和呼叫 module scripts；modules（bash scripts）負責實際安裝邏輯；chezmoi 只負責 dotfile 同步。Profile YAML 定義預設模組組合，installer 讀取 meta.yaml 動態產生選單。

**Tech Stack:** Go (bubbletea/bubbles/lipgloss)、Bash、Chezmoi、age

**設計文件：** `docs/plans/2026-03-13-dotfiles-rewrite-design.md`

**舊版參考：** `~/.local/share/chezmoi`（可讀取但不直接複製）

---

## Phase 1：專案骨架與基礎 Module

### Task 1: 建立專案目錄結構

**Files:**
- Create: `profiles/.gitkeep`
- Create: `modules/.gitkeep`
- Create: `home/.gitkeep`
- Create: `secrets/.gitkeep`
- Create: `installer/go.mod`
- Create: `.gitignore`
- Modify: `CLAUDE.md`

**Step 1: 建立目錄結構**

```bash
mkdir -p profiles modules home/dot_config secrets installer/cmd installer/internal/{tui,profile,runner}
```

**Step 2: 建立 .gitignore**

```gitignore
# 編譯產物
installer/bin/
installer/dist/

# OS 檔案
.DS_Store
Thumbs.db

# age 私鑰（加密後的 .age 檔案可以 commit）
*.age.key

# chezmoi 狀態
.chezmoistate.boltdb
```

**Step 3: 初始化 Go module**

```bash
cd installer && go mod init github.com/fartseng/dotfiles/installer
```

**Step 4: 更新 CLAUDE.md**

加入新版架構的開發指引（建置指令、目錄說明、慣例等），取代舊版參考內容。

**Step 5: Commit**

```bash
git add -A && git commit -m "chore: 建立專案骨架目錄結構"
```

---

### Task 2: 建立 Profile 與 Module Meta 定義

**Files:**
- Create: `profiles/macos-full.yaml`
- Create: `profiles/linux-server.yaml`
- Create: `profiles/linux-desktop.yaml`
- Create: `profiles/windows.yaml`
- Create: `profiles/minimal.yaml`
- Create: `modules/shell/meta.yaml`
- Create: `modules/git/meta.yaml`
- Create: `modules/editor/meta.yaml`
- Create: `modules/runtime/meta.yaml`
- Create: `modules/terminal/meta.yaml`
- Create: `modules/fonts/meta.yaml`
- Create: `modules/macos-defaults/meta.yaml`
- Create: `modules/windows-terminal/meta.yaml`
- Create: `modules/docker/meta.yaml`

**Step 1: 建立所有 profile 定義**

```yaml
# profiles/macos-full.yaml
name: macOS Full
description: 完整 macOS 開發環境
os: darwin
system: client
modules:
  - fonts
  - shell
  - git
  - editor
  - runtime
  - terminal
  - macos-defaults
  - docker
```

```yaml
# profiles/linux-server.yaml
name: Linux Server
description: 伺服器基本工具與 Shell 環境
os: linux
system: server
modules:
  - fonts
  - shell
  - git
  - runtime
```

```yaml
# profiles/linux-desktop.yaml
name: Linux Desktop
description: Linux 桌面開發環境
os: linux
system: client
modules:
  - fonts
  - shell
  - git
  - editor
  - runtime
  - terminal
  - docker
```

```yaml
# profiles/windows.yaml
name: Windows
description: PowerShell + Windows Terminal + Oh My Posh
os: windows
system: client
modules:
  - fonts
  - shell
  - git
  - editor
  - windows-terminal
```

```yaml
# profiles/minimal.yaml
name: Minimal
description: 最輕量環境，只有好看的 Prompt 和基本別名
os: all
system: any
modules:
  - fonts
  - shell
```

**Step 2: 建立所有 module meta.yaml**

```yaml
# modules/fonts/meta.yaml
name: 字型
description: MesloLGS Nerd Font（Oh My Posh 和終端機所需）
os:
  - darwin
  - linux
  - windows
depends_on: []
```

```yaml
# modules/shell/meta.yaml
name: Shell 環境
description: Zsh + Sheldon + Oh My Posh + 別名系統
os:
  - darwin
  - linux
depends_on:
  - fonts
```

```yaml
# modules/git/meta.yaml
name: Git 設定
description: Git + Delta + ghq + SSH 簽署
os:
  - darwin
  - linux
  - windows
depends_on: []
```

```yaml
# modules/editor/meta.yaml
name: 編輯器
description: Neovim + LazyVim
os:
  - darwin
  - linux
  - windows
depends_on: []
```

```yaml
# modules/runtime/meta.yaml
name: Runtime 管理
description: Mise（Go、Node、Python、Rust 等版本管理）
os:
  - darwin
  - linux
depends_on: []
```

```yaml
# modules/terminal/meta.yaml
name: 終端機
description: Ghostty 終端機設定
os:
  - darwin
  - linux
depends_on:
  - fonts
```

```yaml
# modules/macos-defaults/meta.yaml
name: macOS 系統偏好
description: 鍵盤、觸控板、Finder、Dock 等系統設定
os:
  - darwin
depends_on: []
```

```yaml
# modules/windows-terminal/meta.yaml
name: Windows Terminal
description: Windows Terminal 設定與 PowerShell Profile
os:
  - windows
depends_on:
  - fonts
```

```yaml
# modules/docker/meta.yaml
name: Docker
description: OrbStack (macOS) / Docker Engine (Linux)
os:
  - darwin
  - linux
depends_on: []
```

**Step 3: Commit**

```bash
git add profiles/ modules/ && git commit -m "feat: 新增 profile 定義與 module meta.yaml"
```

---

### Task 3: Shell Module — install.sh

**Files:**
- Create: `modules/shell/install.sh`

**Step 1: 撰寫 shell 安裝腳本**

```bash
#!/bin/bash
# 安裝 Shell 環境：Zsh + Sheldon + Oh My Posh
set -euo pipefail

source "${DOTFILES_DIR}/modules/_common.sh"

# --- 安裝 Zsh ---
install_zsh() {
    if command -v zsh &>/dev/null; then
        log_info "Zsh 已安裝，跳過"
        return
    fi

    case "${DOTFILES_OS}" in
        darwin)
            brew install zsh
            ;;
        linux)
            sudo apt-get update && sudo apt-get install -y zsh
            ;;
    esac

    # 設為預設 Shell
    local zsh_path
    zsh_path="$(which zsh)"
    if ! grep -qF "${zsh_path}" /etc/shells; then
        echo "${zsh_path}" | sudo tee -a /etc/shells
    fi
    sudo chsh -s "${zsh_path}" "${USER}"
    log_ok "Zsh 安裝完成並設為預設 Shell"
}

# --- 安裝 Sheldon ---
install_sheldon() {
    if command -v sheldon &>/dev/null; then
        log_info "Sheldon 已安裝，跳過"
        return
    fi

    curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh \
        | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin
    log_ok "Sheldon 安裝完成"
}

# --- 安裝 Oh My Posh ---
install_oh_my_posh() {
    if command -v oh-my-posh &>/dev/null; then
        log_info "Oh My Posh 已安裝，跳過"
        return
    fi

    case "${DOTFILES_OS}" in
        darwin)
            brew install jandedobbeleer/oh-my-posh/oh-my-posh
            ;;
        linux)
            curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/.local/bin
            ;;
    esac
    log_ok "Oh My Posh 安裝完成"
}

install_zsh
install_sheldon
install_oh_my_posh
```

**Step 2: 建立共用函式庫**

```bash
# modules/_common.sh
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
    fi
}
```

**Step 3: 設定執行權限並驗證語法**

```bash
chmod +x modules/shell/install.sh
bash -n modules/shell/install.sh  # 語法檢查
bash -n modules/_common.sh
```
Expected: 無輸出（語法正確）

**Step 4: Commit**

```bash
git add modules/shell/install.sh modules/_common.sh && git commit -m "feat: 新增 shell module 安裝腳本與共用函式庫"
```

---

### Task 4: 其餘 Module — install.sh

**Files:**
- Create: `modules/fonts/install.sh`
- Create: `modules/git/install.sh`
- Create: `modules/editor/install.sh`
- Create: `modules/runtime/install.sh`
- Create: `modules/terminal/install.sh`
- Create: `modules/macos-defaults/install.sh`
- Create: `modules/windows-terminal/install.sh`
- Create: `modules/docker/install.sh`

**Step 1: fonts module**

```bash
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
```

**Step 2: git module**

```bash
#!/bin/bash
# 安裝 Git 相關工具：Delta、ghq
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
            # 透過 cargo 或 GitHub release 安裝
            if has_command cargo; then
                cargo install git-delta
            else
                log_warn "Delta 需要 cargo，請先安裝 runtime module"
            fi
            ;;
    esac
    log_ok "Delta 安裝完成"
}

install_delta
log_ok "Git module 安裝完成（ghq 由 mise 管理）"
```

**Step 3: editor module**

```bash
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
            # 使用 AppImage 或 snap
            if has_command snap; then
                sudo snap install nvim --classic
            else
                curl -fsSLO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.appimage
                chmod +x nvim-linux-x86_64.appimage
                sudo mv nvim-linux-x86_64.appimage /usr/local/bin/nvim
            fi
            ;;
    esac
    log_ok "Neovim 安裝完成"
}

install_neovim
```

**Step 4: runtime module**

```bash
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
```

**Step 5: terminal module**

```bash
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
```

**Step 6: macos-defaults module**

```bash
#!/bin/bash
# 設定 macOS 系統偏好
set -euo pipefail

source "${DOTFILES_DIR}/modules/_common.sh"

if [[ "${DOTFILES_OS}" != "darwin" ]]; then
    log_warn "macOS Defaults 僅適用於 macOS，跳過"
    exit 0
fi

log_info "套用 macOS 系統偏好設定..."

# --- 鍵盤 ---
# 加快鍵盤重複速度
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# 停用自動修正
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
# 啟用全鍵盤控制（Tab 切換所有 UI 元素）
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# --- 觸控板 ---
# 啟用輕觸點按
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
# 加快軌跡速度
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2.5

# --- Finder ---
# 顯示所有副檔名
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# 顯示隱藏檔案
defaults write com.apple.finder AppleShowAllFiles -bool true
# 顯示路徑列
defaults write com.apple.finder ShowPathbar -bool true
# 顯示狀態列
defaults write com.apple.finder ShowStatusBar -bool true
# 預設使用列表顯示
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# --- Dock ---
# 設定 Dock 圖示大小
defaults write com.apple.dock tilesize -int 36
# 自動隱藏 Dock
defaults write com.apple.dock autohide -bool true
# 移除隱藏延遲
defaults write com.apple.dock autohide-delay -float 0
# 加快隱藏動畫速度
defaults write com.apple.dock autohide-time-modifier -float 0.5

# --- 截圖 ---
# 預設儲存到桌面
defaults write com.apple.screencapture location -string "${HOME}/Desktop"
# 使用 PNG 格式
defaults write com.apple.screencapture type -string "png"

# --- 重新啟動受影響的應用程式 ---
for app in "Dock" "Finder"; do
    killall "${app}" &>/dev/null || true
done

log_ok "macOS 系統偏好設定完成（部分設定需要重新登入才生效）"
```

**Step 7: windows-terminal module**

```bash
#!/bin/bash
# Windows Terminal 與 PowerShell Profile 設定
# 此腳本在 WSL 或 Git Bash 下執行
set -euo pipefail

source "${DOTFILES_DIR}/modules/_common.sh"

setup_powershell_profile() {
    local ps_profile_dir
    ps_profile_dir="$(wslpath "$(powershell.exe -NoProfile -Command '[Environment]::GetFolderPath("MyDocuments")' | tr -d '\r')")/PowerShell"

    if [[ ! -d "${ps_profile_dir}" ]]; then
        mkdir -p "${ps_profile_dir}"
    fi

    log_info "設定 PowerShell Profile..."
    # Profile 內容由 chezmoi 管理，這裡只確保目錄存在
    log_ok "PowerShell Profile 目錄就緒"
}

install_oh_my_posh_windows() {
    if powershell.exe -NoProfile -Command "Get-Command oh-my-posh -ErrorAction SilentlyContinue" &>/dev/null; then
        log_info "Oh My Posh (Windows) 已安裝，跳過"
        return
    fi

    log_info "安裝 Oh My Posh (Windows)..."
    powershell.exe -NoProfile -Command "winget install JanDeDobbeleer.OhMyPosh -s winget"
    log_ok "Oh My Posh (Windows) 安裝完成"
}

if [[ "${DOTFILES_OS}" == "windows" ]]; then
    setup_powershell_profile
    install_oh_my_posh_windows
else
    log_warn "Windows Terminal module 僅適用於 Windows，跳過"
fi
```

**Step 8: docker module**

```bash
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
```

**Step 9: 設定執行權限並驗證語法**

```bash
chmod +x modules/*/install.sh
for f in modules/*/install.sh modules/_common.sh; do bash -n "$f"; done
```
Expected: 無輸出（全部語法正確）

**Step 10: Commit**

```bash
git add modules/ && git commit -m "feat: 新增所有 module 安裝腳本"
```

---

## Phase 2：Chezmoi Dotfiles

### Task 5: Chezmoi 核心設定與 Shell Dotfiles

**Files:**
- Create: `home/.chezmoi.yaml.tmpl`
- Create: `home/.chezmoiignore`
- Create: `home/dot_zshrc`
- Create: `home/dot_zprofile`
- Create: `home/dot_config/alias/common.sh`

**Step 1: 極簡化 .chezmoi.yaml.tmpl**

installer 會產生完整的 `.chezmoi.yaml`，這個模板只做 fallback：

```yaml
{{- $email := promptStringOnce . "email" "請輸入 Email 地址" -}}
{{- $system := promptChoiceOnce . "system" "系統類型" (list "client" "server") -}}

data:
  email: {{ $email | quote }}
  system: {{ $system | quote }}
  is_mac: {{ eq .chezmoi.os "darwin" }}
  is_linux: {{ eq .chezmoi.os "linux" }}

encryption: age
age:
  passphrase: true
```

**Step 2: .chezmoiignore**

```
# 根據 OS 忽略不適用的檔案
{{- if ne .chezmoi.os "darwin" }}
Library/
{{- end }}
{{- if ne .chezmoi.os "windows" }}
AppData/
Documents/
{{- end }}
```

**Step 3: dot_zshrc**

從舊版遷移並優化，加入 Oh My Posh 替代 Starship：

```zsh
#!/usr/bin/env zsh

# --- Path 設定 ---
typeset -gU path fpath
path=(
    ${HOME}/.local/bin(N-/)
    $path
    /usr/local/{,s}bin(N-/)
)
fpath=(
    $fpath
    ${HOME}/.local/bin/common(N-/)
)

# --- Sheldon 插件載入 ---
eval "$(sheldon source)"

# --- Oh My Posh 提示符 ---
if (( $+commands[oh-my-posh] )); then
    eval "$(oh-my-posh init zsh --config ${HOME}/.config/oh-my-posh/config.yaml)"
fi
```

**Step 4: dot_zprofile**

```zsh
# 登入 Shell 初始化

# Homebrew（macOS Apple Silicon）
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Mise 啟動
if command -v mise &>/dev/null; then
    eval "$(mise activate zsh)"
fi
```

**Step 5: 別名設定**

從舊版遷移 `home/dot_config/alias/common.sh`，移除 emoji 註解前綴，保持繁體中文註解。（內容同舊版但清理格式）

**Step 6: Commit**

```bash
git add home/ && git commit -m "feat: 新增 chezmoi 核心設定與 Shell dotfiles"
```

---

### Task 6: Git 設定

**Files:**
- Create: `home/dot_config/git/config.tmpl`
- Create: `home/dot_gitignore`

**Step 1: Git config 模板**

從舊版遷移，移除 1Password SSH 簽署，改用本機 SSH key：

```gitconfig
[user]
    name = Far Tseng
    email = {{ .email | quote }}
    signingkey = ~/.ssh/id_ed25519.pub

[core]
    quotepath = false
    excludesfile = ~/.gitignore
    pager = delta

[init]
    defaultBranch = main

[gpg]
    format = ssh

[commit]
    gpgsign = true

[pull]
    rebase = true

[push]
    autoSetupRemote = true

[rebase]
    autoStash = true

[merge]
    log = true

[diff]
    algorithm = histogram
    mnemonicPrefix = true
    colorMoved = default
    submodule = log

[interactive]
    diffFilter = delta --color-only

[delta]
    syntax-theme = Dracula
    navigate = true
    tabs = 2
    side-by-side = true
    line-numbers = false
    file-style = bold "#eee8aa"
    file-decoration-style = ol "#b8860b"
    hunk-header-line-number-style = "#4169e1"
    hunk-header-decoration-style = ol "#000080"
    commit-decoration-style = bold "#00fa9a" box ul
    word-diff-regex = ''

[status]
    submodulesummary = true

[log]
    decorate = short
    abbrevcommit = true
    date = relative

[format]
    pretty = "%C(yellow)%h %C(magenta)%<(15,trunc)%an %C(cyan)%cd %C(auto)%d%Creset %s"

[fetch]
    prune = true

[rerere]
    enabled = true

[ghq]
    root = ~/codebase

[alias]
    st = status
    br = branch
    ci = commit -v
    co = checkout
    sw = switch
    re = restore
    d = diff --color-words=.
    lol = log --graph --all
    lo = log --graph
    last = log -1 HEAD
    f = "!if [[ $(git rev-parse --abbrev-ref HEAD) == 'main' ]]; then git fetch --no-tags origin main; else git fetch --no-tags origin $(git rev-parse --abbrev-ref HEAD) main:main; fi"
    p = "!git pull --no-tags origin $(git rev-parse --abbrev-ref HEAD)"
    pc = "!git push && gh pr create -w"
    puff = push --force-if-includes --force-with-lease
```

**Step 2: 全域 gitignore**

```gitignore
.DS_Store
Thumbs.db
*.swp
*.swo
*~
.idea/
.vscode/
```

**Step 3: Commit**

```bash
git add home/dot_config/git/ home/dot_gitignore && git commit -m "feat: 新增 Git 設定（改用本機 SSH key 簽署）"
```

---

### Task 7: Neovim 設定（LazyVim）

**Files:**
- Create: `home/dot_config/nvim/init.lua`
- Create: `home/dot_config/nvim/lua/config/lazy.lua`
- Create: `home/dot_config/nvim/lua/config/options.lua`
- Create: `home/dot_config/nvim/lua/config/keymaps.lua`
- Create: `home/dot_config/nvim/lua/config/autocmds.lua`

**Step 1: 從舊版遷移 Neovim 設定**

直接使用舊版內容，註解改為繁體中文。結構不變：
- `init.lua`：載入 `config.lazy`
- `lua/config/lazy.lua`：Lazy.nvim 設定（同舊版）
- `lua/config/options.lua`：`autowrite=false`, `wrap=true`, `relativenumber=false`
- `lua/config/keymaps.lua`：空檔案（預留）
- `lua/config/autocmds.lua`：空檔案（預留）

**Step 2: Commit**

```bash
git add home/dot_config/nvim/ && git commit -m "feat: 新增 Neovim + LazyVim 設定"
```

---

### Task 8: Oh My Posh、Mise、Ghostty、Sheldon 設定

**Files:**
- Create: `home/dot_config/oh-my-posh/config.yaml`
- Create: `home/dot_config/mise/config.toml`
- Create: `home/dot_config/ghostty/config`
- Create: `home/dot_config/sheldon/plugins.toml.tmpl`
- Create: Sheldon plugin source files

**Step 1: Oh My Posh 設定**

將舊版 Starship 的 Catppuccin Mocha 配色與模組配置轉換為 Oh My Posh YAML 格式。需要包含：
- Catppuccin Mocha 配色
- OS icon
- 目錄路徑
- Git 分支與狀態
- 程式語言版本（Go、Node、Python、Rust）
- 命令執行時間
- 雲端（AWS、GCP）
- 時間

參考 Oh My Posh 文件：https://ohmyposh.dev/docs/configuration/overview

```yaml
# home/dot_config/oh-my-posh/config.yaml
# Oh My Posh 提示符設定 — Catppuccin Mocha 配色

"$schema": "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/schema.json"
version: 3
final_space: true
console_title_template: "{{ .Folder }}"

# 配色定義
palette:
  base: "#1e1e2e"
  mantle: "#181825"
  surface0: "#313244"
  surface1: "#45475a"
  text: "#cdd6f4"
  blue: "#89b4fa"
  green: "#a6e3a1"
  yellow: "#f9e2af"
  red: "#f38ba8"
  mauve: "#cba6f7"
  peach: "#fab387"
  teal: "#94e2d5"
  lavender: "#b4befe"

blocks:
  # 第一行：主要資訊
  - type: prompt
    alignment: left
    segments:
      - type: os
        style: diamond
        foreground: "p:text"
        background: "p:surface1"
        leading_diamond: ""
        template: "{{ .Icon }} "

      - type: path
        style: powerline
        foreground: "p:text"
        background: "p:surface1"
        powerline_symbol: ""
        properties:
          style: agnoster_short
          max_depth: 3

      - type: git
        style: powerline
        foreground: "p:base"
        background: "p:green"
        powerline_symbol: ""
        template: " {{ .HEAD }}{{ if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }}  {{ .Working.String }}{{ end }}{{ if .Staging.Changed }}  {{ .Staging.String }}{{ end }} "
        properties:
          branch_icon: " "
          fetch_status: true

      - type: go
        style: powerline
        foreground: "p:base"
        background: "p:blue"
        powerline_symbol: ""
        template: "  {{ .Full }} "

      - type: node
        style: powerline
        foreground: "p:base"
        background: "p:green"
        powerline_symbol: ""
        template: "  {{ .Full }} "

      - type: python
        style: powerline
        foreground: "p:base"
        background: "p:yellow"
        powerline_symbol: ""
        template: "  {{ .Full }} "

      - type: rust
        style: powerline
        foreground: "p:base"
        background: "p:peach"
        powerline_symbol: ""
        template: "  {{ .Full }} "

      - type: aws
        style: powerline
        foreground: "p:base"
        background: "p:yellow"
        powerline_symbol: ""
        template: "  {{ .Profile }}{{ if .Region }} ({{ .Region }}){{ end }} "

      - type: gcp
        style: powerline
        foreground: "p:base"
        background: "p:blue"
        powerline_symbol: ""
        template: " 󱇶 {{ .Project }} "

      - type: executiontime
        style: powerline
        foreground: "p:text"
        background: "p:surface0"
        powerline_symbol: ""
        template: " 󰔟 {{ .FormattedMs }} "
        properties:
          threshold: 2000
          style: austin

      - type: time
        style: diamond
        foreground: "p:text"
        background: "p:surface0"
        trailing_diamond: ""
        template: "  {{ .CurrentDate | date \"15:04\" }} "

  # 第二行：輸入提示
  - type: prompt
    alignment: left
    newline: true
    segments:
      - type: text
        style: plain
        foreground: "p:green"
        foreground_templates:
          - "{{ if gt .Code 0 }}p:red{{ end }}"
        template: "❯"
```

**Step 2: Mise 設定**

直接從舊版遷移 `home/dot_config/mise/config.toml`（內容同舊版）。

**Step 3: Ghostty 設定**

直接從舊版遷移 `home/dot_config/ghostty/config`（內容同舊版，移除重複的 `macos-option-as-alt`）。

**Step 4: Sheldon 設定**

從舊版遷移 `plugins.toml.tmpl` 和 plugin source files，結構保持不變（common、client/common、client/macos、client/ubuntu、server 多源配置）。

**Step 5: Commit**

```bash
git add home/dot_config/{oh-my-posh,mise,ghostty,sheldon}/ && git commit -m "feat: 新增 Oh My Posh、Mise、Ghostty、Sheldon 設定"
```

---

## Phase 3：Installer（bubbletea TUI）

### Task 9: Installer 基礎框架

**Files:**
- Create: `installer/cmd/main.go`
- Create: `installer/internal/profile/profile.go`
- Create: `installer/internal/runner/runner.go`
- Modify: `installer/go.mod`

**Step 1: 安裝 Go 依賴**

```bash
cd installer
go get github.com/charmbracelet/bubbletea@latest
go get github.com/charmbracelet/bubbles@latest
go get github.com/charmbracelet/lipgloss@latest
go get gopkg.in/yaml.v3@latest
```

**Step 2: Profile 讀取器**

```go
// installer/internal/profile/profile.go
package profile

// Profile 代表一個安裝設定檔
type Profile struct {
    Name        string   `yaml:"name"`
    Description string   `yaml:"description"`
    OS          string   `yaml:"os"`
    System      string   `yaml:"system"`
    Modules     []string `yaml:"modules"`
}

// ModuleMeta 代表一個模組的描述資訊
type ModuleMeta struct {
    Name        string   `yaml:"name"`
    Description string   `yaml:"description"`
    OS          []string `yaml:"os"`
    DependsOn   []string `yaml:"depends_on"`
}

// LoadProfiles 從 profiles/ 目錄載入所有 profile
// LoadModules 從 modules/*/meta.yaml 載入所有模組描述
// FilterByOS 根據當前 OS 過濾可用的 profiles 和 modules
// ResolveDependencies 根據 depends_on 做拓撲排序
```

實作完整的 profile 讀取、OS 過濾、依賴排序邏輯。

**Step 3: Module 執行器**

```go
// installer/internal/runner/runner.go
package runner

// Runner 負責依序呼叫 module 的 install.sh
type Runner struct {
    DotfilesDir string
    OS          string
    Arch        string
    System      string
}

// Run 執行指定模組的 install.sh，傳入環境變數
// RunAll 依序執行多個模組，回報進度
```

實作 exec.Command 呼叫 bash script，設定環境變數，串流輸出。

**Step 4: 主程式入口**

```go
// installer/cmd/main.go
package main

// 偵測 OS/Arch → 載入 profiles/modules → 啟動 TUI 或執行安裝
```

**Step 5: 驗證編譯**

```bash
cd installer && go build -o bin/installer ./cmd/
```
Expected: 編譯成功，產生 `bin/installer`

**Step 6: Commit**

```bash
git add installer/ && git commit -m "feat: installer 基礎框架（profile 讀取、module 執行器）"
```

---

### Task 10: Installer TUI 畫面

**Files:**
- Create: `installer/internal/tui/app.go`
- Create: `installer/internal/tui/profile_select.go`
- Create: `installer/internal/tui/module_select.go`
- Create: `installer/internal/tui/config_input.go`
- Create: `installer/internal/tui/progress.go`
- Create: `installer/internal/tui/styles.go`

**Step 1: 定義 TUI 狀態機**

```
AppState:
  ProfileSelect → ModuleSelect → ConfigInput → Progress → Done
```

**Step 2: Profile 選擇畫面**

使用 `bubbles/list` 元件，顯示可用 profiles（根據 OS 過濾），含名稱和描述。

**Step 3: Module 勾選畫面**

自訂 checkbox list，根據選中的 profile 預設勾選對應模組，使用者可以增減。顯示模組名稱和描述。

**Step 4: 設定輸入畫面**

使用 `bubbles/textinput` 元件，依序詢問：
- Git email
- age passphrase（密碼模式，不顯示輸入）

**Step 5: 安裝進度畫面**

使用 `bubbles/spinner` + 自訂列表，即時顯示每個模組的安裝狀態：
- `○` 等待中
- `●` 安裝中（帶 spinner）
- `✓` 完成
- `✗` 失敗

**Step 6: 樣式定義**

使用 `lipgloss` 定義統一的色彩方案（Catppuccin Mocha）。

**Step 7: 驗證編譯並手動測試**

```bash
cd installer && go build -o bin/installer ./cmd/ && ./bin/installer
```

**Step 8: Commit**

```bash
git add installer/ && git commit -m "feat: installer TUI 畫面（profile 選擇、模組勾選、設定輸入、進度顯示）"
```

---

### Task 11: Installer 與 Chezmoi 整合

**Files:**
- Create: `installer/internal/chezmoi/chezmoi.go`
- Modify: `installer/cmd/main.go`

**Step 1: Chezmoi 整合模組**

```go
// installer/internal/chezmoi/chezmoi.go
package chezmoi

// GenerateConfig 根據 TUI 輸入產生 .chezmoi.yaml
// InitAndApply 執行 chezmoi init --apply
// 偵測 chezmoi 是否已安裝，未安裝則自動安裝
```

**Step 2: 安裝狀態管理**

```go
// 寫入 ~/.config/dotfiles/state.yaml
// 讀取既有 state 做差異比對
// 支援 --diff 模式（chezmoi apply 觸發時使用）
```

**Step 3: 主程式新增 chezmoi 流程**

在安裝完所有 modules 後：
1. 產生 `.chezmoi.yaml`
2. 執行 `chezmoi init --apply --source <dotfiles-dir>/home`

**Step 4: 新增 chezmoi run_onchange_ 腳本**

```bash
# home/.chezmoiscripts/run_onchange_check-modules.sh.tmpl
#!/bin/bash
# 當 profile 內容變化時觸發 installer
# hash: {{ include "../../profiles" | sha256sum }}
set -euo pipefail

INSTALLER="${HOME}/.local/bin/dotfiles-installer"
if [[ -x "${INSTALLER}" ]]; then
    "${INSTALLER}" --diff
fi
```

**Step 5: 驗證完整流程**

```bash
cd installer && go build -o bin/installer ./cmd/ && ./bin/installer --help
```

**Step 6: Commit**

```bash
git add installer/ home/.chezmoiscripts/ && git commit -m "feat: installer 與 chezmoi 整合，支援差異偵測觸發"
```

---

## Phase 4：交叉編譯與發佈

### Task 12: Makefile 與 GitHub Release

**Files:**
- Create: `installer/Makefile`
- Create: `.github/workflows/release.yaml`

**Step 1: Makefile**

```makefile
# installer/Makefile

APP_NAME := dotfiles-installer
VERSION := $(shell git describe --tags --always --dirty 2>/dev/null || echo "dev")
LDFLAGS := -ldflags "-s -w -X main.version=$(VERSION)"
PLATFORMS := darwin/amd64 darwin/arm64 linux/amd64 linux/arm64 windows/amd64

.PHONY: build clean all

build:
	go build $(LDFLAGS) -o bin/$(APP_NAME) ./cmd/

all: clean
	@for platform in $(PLATFORMS); do \
		os=$${platform%/*}; arch=$${platform#*/}; \
		ext=""; [ "$$os" = "windows" ] && ext=".exe"; \
		echo "Building $$os/$$arch..."; \
		GOOS=$$os GOARCH=$$arch go build $(LDFLAGS) \
			-o dist/$(APP_NAME)-$$os-$$arch$$ext ./cmd/; \
	done

clean:
	rm -rf bin/ dist/
```

**Step 2: GitHub Actions Release Workflow**

當 push tag (`v*`) 時自動編譯所有平台 binary 並上傳到 GitHub Release。

**Step 3: 驗證交叉編譯**

```bash
cd installer && make all
ls -la dist/
```
Expected: 5 個 binary（darwin/amd64、darwin/arm64、linux/amd64、linux/arm64、windows/amd64）

**Step 4: Commit**

```bash
git add installer/Makefile .github/ && git commit -m "ci: 新增 Makefile 與 GitHub Release workflow"
```

---

## Phase 5：收尾

### Task 13: 更新 CLAUDE.md 與 README

**Files:**
- Modify: `CLAUDE.md`
- Create: `README.md`

**Step 1: 更新 CLAUDE.md**

替換為新版架構的開發指引，包含：
- 建置指令（`cd installer && make build`）
- 測試方式
- 新增 module 的流程
- 目錄結構說明
- 慣例（bash script 規範、繁體中文註解）

**Step 2: 建立 README.md**

包含：
- 快速開始（curl 一行安裝）
- 支援環境
- Profile 說明
- 自訂模組方式

**Step 3: Commit**

```bash
git add CLAUDE.md README.md && git commit -m "docs: 更新 CLAUDE.md 與新增 README.md"
```

---

### Task 14: Windows 支援（PowerShell Profile）

**Files:**
- Create: `home/Documents/PowerShell/Microsoft.PowerShell_profile.ps1`（chezmoi 管理）

**Step 1: PowerShell Profile**

```powershell
# Oh My Posh 提示符
oh-my-posh init pwsh --config "$env:USERPROFILE\.config\oh-my-posh\config.yaml" | Invoke-Expression

# 別名
Set-Alias -Name vim -Value nvim
Set-Alias -Name ll -Value Get-ChildItem
```

**Step 2: Commit**

```bash
git add home/Documents/ && git commit -m "feat: 新增 Windows PowerShell Profile"
```

---

## 執行順序摘要

| Phase | Task | 內容 | 預估複雜度 |
|-------|------|------|-----------|
| 1 | 1 | 專案骨架 | 低 |
| 1 | 2 | Profile + Module Meta | 低 |
| 1 | 3 | Shell module install.sh | 中 |
| 1 | 4 | 其餘 module install.sh | 中 |
| 2 | 5 | Chezmoi 核心 + Shell dotfiles | 中 |
| 2 | 6 | Git 設定 | 低 |
| 2 | 7 | Neovim 設定 | 低 |
| 2 | 8 | Oh My Posh + Mise + Ghostty + Sheldon | 中 |
| 3 | 9 | Installer 基礎框架 | 高 |
| 3 | 10 | Installer TUI 畫面 | 高 |
| 3 | 11 | Installer + Chezmoi 整合 | 高 |
| 4 | 12 | 交叉編譯與 Release | 中 |
| 5 | 13 | 文件更新 | 低 |
| 5 | 14 | Windows PowerShell | 低 |
