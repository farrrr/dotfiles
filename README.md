# Far's Dotfiles

個人開發環境管理系統。使用 [chezmoi](https://www.chezmoi.io/) 同步 dotfiles，搭配自製 TUI 安裝器進行互動式設定。

## 快速開始

```bash
curl -sL https://raw.githubusercontent.com/farrrr/dotfiles/main/install.sh | sh
```

> 從 source 編譯：
> ```bash
> git clone https://github.com/farrrr/dotfiles.git && cd dotfiles
> cd installer && make build && ./bin/dotfiles-installer
> ```

## 安裝流程

Installer 執行順序：

1. **TUI 互動** — 選擇 Profile、勾選模組、輸入 Email / System
2. **chezmoi init --apply** — 從 GitHub clone repo 並同步所有 config 到 `$HOME`
3. **執行模組** — 依序跑各模組的 `install.sh`
4. **儲存狀態** — 記錄已安裝的模組到 `~/.config/dotfiles/state.yaml`

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
├── .chezmoiroot      指定 home/ 為 chezmoi source 目錄
├── installer/        bubbletea TUI 安裝器（Go）
├── profiles/         Profile 定義（YAML）
├── modules/          安裝腳本（meta.yaml + install.sh）
├── home/             chezmoi 管理的 dotfiles（對應 $HOME）
├── secrets/          age 加密的機密檔案
└── docs/plans/       設計文件與實作計畫
```

## 工具管理策略

| 管理方式 | 工具 |
|----------|------|
| **Mise** (全域 config) | go, node, pnpm, python, chezmoi, uv, aws-cli, dotenvx, bat, curlie, delta, eza, fd, fzf, jq, lazygit, ripgrep, tree-sitter, yazi, zellij, shellcheck, shfmt, ghq, gh |
| **Homebrew / apt** | oh-my-posh, sheldon（mise registry 不支援） |
| **rustup** | Rust toolchain |
| **Chezmoi** | 所有 dotfiles / config 檔案 |

## 工具鏈

| 類別 | 工具 |
|------|------|
| Shell | Zsh + Sheldon + Oh My Posh |
| Editor | Neovim + LazyVim |
| Terminal | Ghostty + Zellij |
| Runtime | Mise（語言 / CLI 工具管理） |
| Git | Delta + ghq + lazygit |
| Prompt | Oh My Posh（跨平台） |

## 新增模組

1. 建立 `modules/<name>/meta.yaml` 和 `install.sh`
2. 在對應的 profile YAML 中加入模組名稱
3. 執行 `chezmoi apply` 或重跑 installer

## 建置

```bash
# 編譯 installer
cd installer && make build

# 交叉編譯所有平台
cd installer && make all

# 語法檢查所有 install.sh
for f in modules/*/install.sh; do bash -n "$f"; done
```

## 授權

MIT
