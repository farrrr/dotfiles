# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 語言

所有回覆與文件使用繁體中文。

## 專案概述

個人 dotfiles 管理系統，使用 chezmoi 管理，從 `~/.local/share/chezmoi` 的舊版全面改寫。支援跨平台（macOS Apple Silicon/Intel、Ubuntu Linux）與雙模式（Client 個人電腦 / Server 遠端伺服器）。

## 舊版架構參考

舊版位於 `~/.local/share/chezmoi`，改寫時可參考但不需保留所有設計：

### Chezmoi 結構
- `.chezmoiroot` 指向 `home/` 目錄，所有 dotfile 放在 `home/` 下
- `.chezmoi.yaml.tmpl` 定義模板變數：`email`、`system`（client/server）、`is_mac`、`is_linux`、`git_signing_key`
- `.chezmoiexternal.yaml.tmpl` 管理外部資源（如 Nerd Font 自動下載）
- `.chezmoiignore` 使用模板做條件式忽略

### 五段式安裝流程
腳本在 `home/.chezmoiscripts/`，命名格式：`run_once_<stage>_<number>_<category>_<priority>-<description>.sh.tmpl`
1. **00-bootstrap**：Homebrew/Apt、1Password CLI、Xcode CLI Tools
2. **10-base**：Zsh、Mise、Sheldon
3. **20-apps**：FZF、Starship、Oh My Posh、Mise 語言工具
4. **30-gui**：Mac App Store、OrbStack、Ghostty、macOS Defaults
5. **90-post**：收尾工作（Docker SSH 等）

安裝腳本實體放在 `install/{common,macos,ubuntu}/`，chezmoi scripts 呼叫它們。

### 核心工具鏈
- **Shell**：Zsh + Sheldon（插件管理）+ zsh-defer（延遲載入）
- **Prompt**：Starship（模組化配置在 `.config/starship/`）
- **Editor**：Neovim + LazyVim
- **Terminal**：Ghostty（Catppuccin Mocha 主題）
- **Runtime**：Mise（管理 Go、Node、Python、Rust 等版本）
- **Git**：Delta（diff 美化）、histogram diff、SSH 簽署（1Password）、ghq（repo 管理，root: `~/codebase`）
- **現代 CLI 替代品**：eza(ls)、bat(cat)、fd(find)、ripgrep(grep)、curlie(curl)、prettyping(ping)、btop(top)、lazygit、yazi、zellij

### Sheldon 多源插件配置
模板化 `plugins.toml.tmpl` 引入多個來源：
- `common.toml`：所有環境
- `client/common.toml`、`client/macos.toml`、`client/ubuntu.toml`：Client 模式
- `server.toml`：Server 模式

### 別名系統
位於 `.config/alias/`，用 suffix alias（`alias -s`）做檔案關聯，`noglob` 包裝 fd/rg。

### 1Password 整合
- Git commit SSH 簽署
- `op` CLI 管理機密，不在本地存放私鑰
- macOS 用 Keychain 存 sudo 密碼

### macOS LaunchAgents
`Library/private_LaunchAgents/` 下管理背景服務（MLX embedding、TEI reranker 等）。

### macOS Defaults
`install/macos/common/defaults.sh` 設定系統偏好（深色模式、鍵盤重複速度、Finder 顯示隱藏檔、Dock 等）。
