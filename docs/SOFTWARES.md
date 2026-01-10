# 軟體清單 (Software List)

本文件列出由 dotfiles 自動安裝與管理的所有軟體套件。

## 📍 Core Utilities (跨平台核心工具)

這些工具在 macOS 與 Ubuntu 上皆會安裝 (部分差異由腳本自動處理)。

| 軟體名稱 | 描述 | 安裝方式 |
| :--- | :--- | :--- |
| **Zsh** | Z Shell，預設的 Shell 環境 | System / Brew / Apt |
| **Starship** | 跨平台 Shell 提示字元 (Prompt) | Official Script / Brew |
| **Mise** | 多語言版本管理工具 (取代 asdf) | Official Script |
| **Sheldon** | Zsh 套件管理器 (Rust based) | Official Script / Brew |
| **1Password CLI** | 密碼管理工具指令列介面 (`op`) | Official Apt / Brew |
| **FZF** | 命令列模糊搜尋工具 | Git / Brew |

---

##  macOS

### Homebrew Packages (CLI)
位於 `install/macos/common/misc.sh`

| 套件 | 描述 |
| :--- | :--- |
| **bat** | `cat` 的現代化替代品 (語法高亮) |
| **bat-extras** | `bat` 的額外腳本 (含 `batgrep`, `batdiff`) |
| **btop** | 資源監控儀表板 |
| **curlie** | `curl` 的前端封裝 (類似 httpie) |
| **git-delta** | Git diff 語法高亮工具 |
| **imagemagick** | 圖片處理工具 CLI |
| **neovim** | 現代化 Vim 編輯器 |
| **prettyping** | `ping` 的美化輸出 |
| **shellcheck** | Shell 腳本靜態分析工具 |
| **unzip** | 解壓縮工具 |
| **vim** | 經典文字編輯器 |
| **watchexec** | 監控檔案變更並自動執行指令 |
| **wget** | 檔案下載工具 |

### Homebrew Casks (GUI Apps)
位於 `install/macos/common/misc.sh`, `orbstack.sh`, `ghostty.sh`

| App | 描述 |
| :--- | :--- |
| **OrbStack** | 輕量級 Docker/Linux 虛擬化工具 |
| **Ghostty** | 高效能 GPU 加速終端機 |
| **Google Chrome** | 網頁瀏覽器 |
| **VS Code** | 程式碼編輯器 |
| **Raycast** | 系統啟動器 (替代 Spotlight) |
| **Setapp** | 應用程式訂閱服務 |
| **Notion** | 筆記與協作工具 |
| **Tower** | Git GUI 用戶端 |
| **ChatGPT** | OpenAI 桌面版應用程式 |
| **WeChat** | 微信桌面版 |
| **Antigravity** | Google 內部工具 (需權限) |
| **Adobe Acrobat Reader** | PDF 閱讀器 |
| **Google Drive** | 雲端硬碟 |

### Mac App Store (MAS)
位於 `install/macos/common/mac_app_store.sh`

> ⚠️ 目前清單皆為註解狀態 (預設不安裝)，需手動開啟。

| App | ID |
| :--- | :--- |
| **Xcode** | 497799835 |
| **LINE** | 539883307 |
| **Bandwidth+** | 490461369 |
| **1Password 7** | 1333542190 |
| **Tailscale** | 1475387142 |
| **Magnet** | 441258766 |

---

## 🐧 Ubuntu

### Server / Common Packages
位於 `install/ubuntu/common/misc.sh` 與 `server/`

| 套件 | 描述 |
| :--- | :--- |
| **OpenSSH Server** | SSH 伺服器 (Server only) |
| **Git Credential Manager** | Git 認證管理 (Server only) |
| **tzdata** | 時區資料 (Server only) |
| **btop** | 資源監控 |
| **curl / wget** | 網路工具 |
| **vim / neovim** | 編輯器 |
| **unzip** | 解壓縮工具 |
| **iputils-ping** | Ping 工具 |
| **bat** | Cat 替代品 |

### Client / Docker
位於 `install/ubuntu/client/docker.sh`

| 套件 | 描述 |
| :--- | :--- |
| **Docker Engine** | 容器化平台 |
| **Docker Compose** | 容器編排工具 |
