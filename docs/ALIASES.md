# 別名清單 (Aliases)

本文件列出由 `home/dot_config/alias/` 定義的所有 Shell 別名。這些別名旨在簡化常用指令輸入或提供更好的預設選項。

## 🌐 通用別名 (Common)
定義於 `home/dot_config/alias/common.sh`，適用於所有環境。

### 檔案與目錄操作
| Alias | Command / Logic | 說明 |
| :--- | :--- | :--- |
| **ls** | `eza -F --icons -a ...` | 使用 `eza` 替換標準 `ls`，顯示圖示與分類 (若無 eza 則回退至 ls) |
| **ll** | `ls --long --group ...` | 詳細列表模式 (Long format) |
| **cat** | `bat` | 使用 `bat` 替換 `cat` (支援語法高亮) |
| **batgrep** | `batgrep ... | less` | 使用 bat 進行 grep 搜尋並分頁 |
| **gcloud** | `docker run ... gcloud` | 透過 Docker 執行 Google Cloud SDK |

### 網路與工具
| Alias | Command / Logic | 說明 |
| :--- | :--- | :--- |
| **ping** | `prettyping --nolegend` | 美化 Ping 輸出 |
| **curl** | `curlie` | 使用 `curlie` (httpie 風格) 替換標準 curl |
| **dircolors** | `gdircolors` | 修正 macOS 缺少 dircolors 的相容性 |

### Shell 行為修正
| Alias | Command | 說明 |
| :--- | :--- | :--- |
| **fd** | `noglob fd` | 防止 Shell 對 fd 參數進行通配符展開 |
| **rg** | `noglob rg` | 防止 Shell 對 rg 參數進行通配符展開 |

### Suffix Aliases (自動關聯)
直接輸入檔案路徑 (如 `readme.md`) 即可使用對應程式開啟。

| 副檔名 | 執行程式 | 範例 |
| :--- | :--- | :--- |
| **.zip** | `zipinfo` | `data.zip` -> `zipinfo data.zip` |
| **.md, .py, .js...** | `code` | `script.py` -> `code script.py` |

---

## 💻 Client 專用
定義於 `home/dot_config/alias/client.sh`。
*(目前為空，保留供未來擴充)*

---

## 🖥 Server 專用
定義於 `home/dot_config/alias/server.sh`。
*(目前為空，保留供未來擴充)*
