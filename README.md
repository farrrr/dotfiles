# Far's Dotfiles

個人開發環境管理系統。使用 [chezmoi](https://www.chezmoi.io/) 同步 dotfiles，搭配自製 TUI 安裝器進行互動式設定。

## 快速開始

```bash
# 下載 installer（自動偵測 OS/Arch）
curl -sL https://github.com/farrrr/dotfiles/releases/latest/download/dotfiles-installer-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/') -o installer
chmod +x installer
./installer
```

## 支援環境

| Profile | 環境 | 說明 |
|---------|------|------|
| macOS Full | macOS | 完整開發環境 |
| Linux Server | Linux | 伺服器基本工具 |
| Linux Desktop | Linux | 桌面開發環境 |
| Windows | Windows | PowerShell + Terminal |
| Minimal | 任何 | 好看的 Prompt + 基本別名 |

## 架構

```
dotfiles/
├── installer/     bubbletea TUI 安裝器
├── profiles/      Profile 定義（YAML）
├── modules/       安裝腳本（meta.yaml + install.sh）
├── home/          chezmoi 管理的 dotfiles
└── secrets/       age 加密的機密檔案
```

## 工具鏈

| 類別 | 工具 |
|------|------|
| Shell | Zsh + Sheldon + Oh My Posh |
| Editor | Neovim + LazyVim |
| Terminal | Ghostty |
| Runtime | Mise |
| Git | Delta + ghq |

## 新增模組

1. 建立 `modules/<name>/meta.yaml` 和 `install.sh`
2. 在對應的 profile YAML 中加入模組名稱
3. 執行 `chezmoi apply` 或重跑 installer

## 授權

MIT
