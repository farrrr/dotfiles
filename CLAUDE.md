# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 語言

所有回覆、註解與文件使用繁體中文。

## 專案概述

個人 dotfiles 管理系統。bubbletea TUI 安裝器 + chezmoi dotfile 同步 + 模組化安裝腳本。

支援環境：macOS Client、Linux Server、Linux Desktop、Windows WSL、Windows 原生。

## 目錄結構

- `.chezmoiroot` — 指定 `home/` 為 chezmoi source 目錄
- `install.sh` — 一鍵安裝腳本（`curl | sh`）
- `installer/` — bubbletea Go TUI 安裝器（編譯成零依賴 binary）
- `profiles/` — Profile 定義（YAML），描述預設模組組合
- `modules/` — 安裝腳本，每個模組一個目錄（meta.yaml + install.sh）
- `home/` — chezmoi 管理的 dotfiles（對應 $HOME）
- `secrets/` — age 加密的機密檔案
- `docs/plans/` — 設計文件與實作計畫

## 安裝流程

1. `install.sh` 下載對應平台的 installer binary
2. Installer 找不到本地 repo 時自動 `git clone` 到 `~/.local/share/chezmoi`
3. TUI 收集設定（profile、modules、email、system）
4. 寫入 chezmoi config → `chezmoi apply`（同步 config 到 $HOME）
5. 依序執行各 module 的 `install.sh`
6. 儲存安裝狀態到 `~/.config/dotfiles/state.yaml`

## 建置指令

```bash
# 編譯 installer
cd installer && make build

# 交叉編譯所有平台
cd installer && make all

# 語法檢查所有 install.sh
for f in modules/*/install.sh; do bash -n "$f"; done
```

## 工具管理策略

- **Mise**：管理有 registry 支援的 CLI 工具與語言（全域 `~/.config/mise/config.toml`）
- **Homebrew / apt**：mise 不支援的工具（oh-my-posh, sheldon），由 module install.sh 安裝
- **rustup**：Rust toolchain 獨立管理
- **Chezmoi**：所有 dotfiles / config 同步

## 慣例

### Module 規範
- 每個 module 目錄包含 `meta.yaml`（描述）+ `install.sh`（安裝腳本）
- install.sh 一律使用 `#!/bin/bash` + `set -euo pipefail`
- 透過環境變數接收：`DOTFILES_DIR`、`DOTFILES_OS`、`DOTFILES_ARCH`、`DOTFILES_SYSTEM`
- 腳本必須冪等（重複執行不會壞）
- 共用函式放在 `modules/_common.sh`

### Profile 規範
- YAML 格式，定義 name、description、os、system、modules
- `os` 值：darwin / linux / windows / all
- `system` 值：client / server / any

### Chezmoi
- `home/` 裡的檔案由 chezmoi 同步到 $HOME（透過 `.chezmoiroot` 指定）
- 模板盡量精簡，安裝邏輯不放在 chezmoi scripts 裡
- 機密管理使用 age passphrase 模式

### 程式碼風格
- 所有註解使用繁體中文
- Shell script 遵循 shellcheck 規範
- Go 程式碼遵循 gofmt 標準
