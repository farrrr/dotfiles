# Dotfiles 全面改寫設計文件

## 目標

將現有 chezmoi dotfiles（`~/.local/share/chezmoi`）全面改寫，解決以下問題：

1. 舊版架構太重 — 五段式安裝流程、大量 chezmoi 模板、難以維護
2. 多環境安裝不順暢 — 缺乏互動式介面，每種環境都要裝全套
3. 1Password CLI 整合痛點 — 認證疲勞、Server 上不好用、rate limit
4. 工具設定需要重新優化

## 支援環境

| 環境 | 用途 | 頻率 |
|------|------|------|
| macOS Client | 主力開發機 | 最常用 |
| Linux Server | Ubuntu 為主的伺服器 | 常用 |
| Linux Desktop | 桌面開發環境 | 少見 |
| Windows WSL | WSL 裡跑 Linux 環境 | 偶爾 |
| Windows 原生 | PowerShell + Windows Terminal | 偶爾 |

## 架構總覽

```
dotfiles/
├── installer/              # bubbletea TUI 安裝器（Go，編譯成單一 binary）
│   ├── cmd/
│   ├── internal/
│   │   ├── tui/             # bubbletea UI 元件
│   │   ├── profile/         # 讀取 profile YAML
│   │   └── runner/          # 呼叫 module scripts 的執行器
│   ├── go.mod
│   └── Makefile
│
├── profiles/               # Profile 定義（純資料，YAML）
│   ├── macos-full.yaml
│   ├── linux-server.yaml
│   ├── linux-desktop.yaml
│   ├── windows.yaml
│   └── minimal.yaml
│
├── modules/                # 安裝腳本（純 bash script）
│   ├── shell/
│   │   ├── meta.yaml       # 模組名稱、描述、支援 OS、依賴
│   │   └── install.sh
│   ├── git/
│   ├── editor/
│   ├── runtime/
│   ├── terminal/
│   ├── fonts/
│   ├── macos-defaults/
│   ├── windows-terminal/
│   └── docker/
│
├── home/                   # chezmoi 管理的 dotfiles
│   ├── .chezmoi.yaml.tmpl  # 極簡化，變數由 installer 產生
│   ├── .chezmoiignore
│   ├── dot_config/
│   │   ├── git/
│   │   ├── nvim/
│   │   ├── oh-my-posh/
│   │   ├── mise/
│   │   ├── sheldon/
│   │   ├── ghostty/
│   │   ├── zellij/
│   │   └── alias/
│   ├── dot_zshrc
│   ├── dot_zprofile
│   └── Library/
│
├── secrets/                # age 加密的機密檔案（可安全 commit）
├── docs/
├── CLAUDE.md
└── README.md
```

## 核心設計決策

### 1. 薄 Installer + Module Scripts

Installer（bubbletea Go binary）只負責：
- TUI 互動介面（選 profile、勾選模組、輸入設定）
- 產出 `.chezmoi.yaml`
- 依序呼叫 module 的 `install.sh`

所有安裝邏輯在 `modules/*/install.sh` 裡，用 bash 撰寫。加新工具只需新增 module 目錄，不動 installer。

### 2. chezmoi 的角色定位

chezmoi 只負責 **dotfiles 同步**。安裝邏輯全部由 installer + modules 處理。

`chezmoi apply` 時如果偵測到 profile 內容有變化，會自動觸發 installer TUI，顯示差異讓使用者確認後執行新增模組的安裝。

### 3. 安裝流程

#### 全新系統（冷啟動）

```
curl 下載 installer binary → 執行
    ↓
TUI：自動偵測 OS/arch → 顯示可用 profiles → 選擇
    ↓
TUI：顯示該 profile 預設模組 → 可增減 → 確認
    ↓
TUI：輸入 age passphrase、Git email 等設定
    ↓
產生 .chezmoi.yaml → 依序執行 modules → chezmoi init --apply
```

#### 日常變更

```
編輯 profile YAML，加入新模組
    ↓
chezmoi apply
    ↓
偵測到 profile 變化 → 自動啟動 installer TUI
    ↓
顯示差異 → 確認 → 只安裝新增的模組
```

### 4. Module 系統

#### meta.yaml 格式

```yaml
name: Shell 環境
description: Zsh + Sheldon + Oh My Posh + 別名系統
os:
  - darwin
  - linux
depends_on:
  - fonts
```

#### install.sh 規範

- 一律使用 `#!/bin/bash`（不依賴 zsh，確保裸機可執行）
- `set -euo pipefail`
- 透過環境變數接收參數：`DOTFILES_DIR`、`DOTFILES_OS`、`DOTFILES_ARCH`、`DOTFILES_SYSTEM`
- 腳本自行確保冪等性（重複執行不會壞）

#### 依賴解析

Installer 根據 `depends_on` 自動排序執行順序。shell module 最先執行（負責安裝 zsh）。

### 5. Profile 系統

每個 profile 定義：

```yaml
name: macOS Full
description: 完整 macOS 開發環境
os: darwin
system: client
modules:
  - shell
  - git
  - editor
  - runtime
  - terminal
  - fonts
  - macos-defaults
  - docker
```

安裝狀態記錄在 `~/.config/dotfiles/state.yaml`，用於差異比對。

### 6. 機密管理

- 使用 **age passphrase 模式** 取代 1Password CLI
- 不需要 key 檔案，只要記住密碼
- 加密後的 `.age` 檔案安全 commit 到 repo（repo 設為 private）
- SSH key 改用本機產生，不再依賴 1Password SSH Agent

```yaml
# .chezmoi.yaml
encryption: age
age:
  passphrase: true
```

### 7. 工具鏈

| 類別 | 工具 |
|------|------|
| Shell | Zsh + Sheldon + zsh-defer |
| Prompt | Oh My Posh（跨平台含 Windows PowerShell） |
| Editor | Neovim + LazyVim |
| Terminal | Ghostty |
| Runtime 管理 | Mise |
| Git 增強 | Delta、ghq |
| 現代 CLI | eza、bat、fd、ripgrep、curlie、btop、lazygit、yazi、zellij |

所有工具設定將在改寫過程中重新優化。

## 技術選型理由

| 決策 | 理由 |
|------|------|
| 繼續用 chezmoi | 已有經驗、跨平台模板、Windows 支援、age 內建整合 |
| bubbletea 做 installer | 編譯成零依賴 binary、全新系統可直接跑、Charm 生態系風格一致 |
| age passphrase 取代 1Password | 無認證疲勞、Server 友善、不需要額外 CLI 工具 |
| Oh My Posh 統一 prompt | 原生支援 Windows PowerShell、跨平台一致體驗 |
| LazyVim | folke 維護、extras 模組按需啟用、開箱即用的 IDE 體驗 |
| YAML 作為設定格式 | 使用者習慣、可讀性好 |
| install.sh 用 bash | 裸機 Linux Server 也能跑，不依賴 zsh |
| 註解用繁體中文 | 個人 repo，母語最直覺 |
