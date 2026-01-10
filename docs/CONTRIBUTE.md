# 貢獻與維護指南 (Contributing Guide)

本文件定義了本 Dotfiles 專案的架構設計原則、腳本執行順序規範，以及如何新增或修改設定。維護者（Human & AI）應嚴格遵守此規範。

## 1. Chezmoi Scripts 架構設計

本專案採用 **「五段式重構」 (5-Stage Refactoring)** 策略來管理所有安裝腳本。目標是將複雜的系統建置過程拆解為可預測、可依賴的階段。

### 1.1 核心設計原則

*   **順序由檔名決定 (Order by Filename ID)**：
    *   Chezmoi 依照字母順序執行腳本。我們利用檔名中的數字前綴（如 `00-`, `10-`, `20-`）來強制定義執行順序。
    *   資料夾結構（如 `common/`, `macos/`）僅用於分類與 OS 條件判斷，**不應依賴資料夾名稱來決定執行順序**。

*   **Before vs After 的明確分界**：
    *   `run_once_before_`：**「讓 Apply 能成功的前置作業」**。例如安裝 Package Manager、解密金鑰、安裝 Mise/Runtime。此階段失敗通常代表環境無法繼續。
    *   `run_once_after_`：**「實際的安裝與設定」**。例如安裝 CLI 工具、設定 macOS Defaults、GUI 軟體。

*   **單一責任原則 (Single Responsibility)**：
    *   每個腳本應只做一件事（例如：`install-fzf.sh` 只負責安裝 fzf）。
    *   好處：方便除錯、重跑特定腳本、以及從檔名即可預知行為。

### 1.2 五段式生命週期 (The 5 Stages)

我們將腳本的執行生命週期劃分為以下五個標準階段。請在命名腳本時，根據其性質歸類至對應的數字區段：

#### [Phase 1: Before Apply] 系統準備階段

*   **`00-bootstrap` (Initial Setup)**
    *   **定義**：最低限度的系統準備，確保後續腳本有權限或工具可執行。
    *   **內容範例**：
        *   檢查/安裝 Homebrew (macOS) 或 apt/pacman (Linux)。
        *   確保 `sudo` 權限可用。
        *   建立必要的基礎目錄結構。

*   **`10-base` (Essentials)**
    *   **定義**：基礎環境建置。這些工具是「其他 Dotfiles 設定」可能會依賴的。
    *   **原則**：此階段安裝的工具**不應依賴** dotfiles 本身已連結完成（因為此時可能還在 before 階段）。
    *   **內容範例**：
        *   安裝/解鎖機密管理工具 (1Password CLI)。
        *   安裝 Runtime Manager (Mise, Asdf)。
        *   安裝 Shell 本體 (Zsh, Bash)。
        *   解密必要的 SSH Keys 或 GPG Keys。

#### [Phase 2: After Apply] 應用與設定階段

*   **`20-apps` (CLI & Tools)**
    *   **定義**：主要生產力工具的安裝。此時 dotfiles 設定檔 (`.zshrc`, `.config/`) 已經被 Chezmoi 部署到定位。
    *   **內容範例**：
        *   CLI 工具：`fzf`, `ripgrep`, `eza`, `bat`, `ghq`。
        *   Shell Plugins：`sheldon`, `starship`。
        *   開發語言環境：透過 Mise 安裝 NodeJS, Python, Go 等版本。

*   **`30-gui` (GUI & Preferences)**
    *   **定義**：圖形介面軟體安裝與系統偏好設定。此階段通常耗時較長，且較無相依性問題。
    *   **內容範例**：
        *   Homebrew Casks (Ghostty, Chrome, Slack)。
        *   macOS Defaults (`defaults write ...`)：Dock 設定、鍵盤重複速度、觸控板行為。
        *   Linux GNOME/KDE 設定。

*   **`90-post` (Cleanup & Notify)**
    *   **定義**：收尾工作。確保所有變更生效，並清理暫存檔。
    *   **內容範例**：
        *   重建 Shell Cache (如 `bat cache --build`)。
        *   清理 Homebrew Cache。
        *   顯示安裝摘要報告 (Summary)。
        *   發送系統通知「Dotfiles 更新完成」。

---

## 2. 檔案命名規範

請遵循以下格式命名 `home/.chezmoiscripts` 下的檔案：

```text
run_once_<stage>_<number>_<category>_<priority>-<description>.sh.tmpl
```

*   **stage**: `before` 或 `after`。
*   **number**: 對應上述五段式編號 (`00`, `10`, `20`, `30`, `90`)。
*   **category**: (選用) 用於進一步分組，如 `bootstrap`, `base`, `apps`。
*   **priority**: (選用) 同一階段內的執行順序微調 (`00`~`99`)。

### 實際範例

```bash
# Before: 00-bootstrap
home/.chezmoiscripts/common/run_once_before_00_bootstrap_00-install-homebrew.sh.tmpl
home/.chezmoiscripts/common/run_once_before_00_bootstrap_10-check-sudo.sh.tmpl

# Before: 10-base
home/.chezmoiscripts/common/run_once_before_10_base_00-install-mise.sh.tmpl
home/.chezmoiscripts/common/run_once_before_10_base_10-install-zsh.sh.tmpl

# After: 20-apps
home/.chezmoiscripts/common/run_once_after_20_apps_00-install-starship.sh.tmpl
home/.chezmoiscripts/linux/run_once_after_20_apps_10-install-docker.sh.tmpl

# After: 30-gui
home/.chezmoiscripts/macos/run_once_after_30_gui_00-macos-defaults.sh.tmpl
home/.chezmoiscripts/macos/run_once_after_30_gui_10-install-ghostty.sh.tmpl

# After: 90-post
home/.chezmoiscripts/common/run_once_after_90_post_00-cleanup.sh.tmpl
```

## 3. 開發流程建議

1.  **新增功能時**：先思考它屬於哪一個階段 (bootstrap vs apps?)。
2.  **撰寫腳本**：
    *   將實際安裝邏輯寫在 `install/common/` 或 `install/macos/` 下的獨立 Shell Script (不含 template 語法)。
    *   在 `home/.chezmoiscripts/` 下建立對應的 `.sh.tmpl` 檔案，使用 `{{ include ... }}` 引用前者。
3.  **測試**：使用 `chezmoi apply` 或直接執行該 `.sh.tmpl` 渲染後的腳本進行測試。
