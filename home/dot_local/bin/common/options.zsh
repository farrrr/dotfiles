#!/usr/bin/env zsh
# ~/.config/zsh/options.zsh

###############################################################################
# Zsh 選項與環境變數設定
# 此檔案主要用來調整 Zsh 行為、歷史紀錄、目錄操作、補全等功能
###############################################################################

# -------------------------------
# ✅ 一般選項
# -------------------------------
setopt interactive_comments      # 允許使用 # 來寫註解
setopt long_list_jobs            # jobs 顯示時使用詳細格式
setopt extendedglob              # 啟用延伸型萬用字元樣式（如 (#i) 不區分大小寫）
setopt notify                    # 後台工作完成時立即通知
setopt list_packed               # 讓補全顯示更緊湊
setopt transient_rprompt         # 清除右側提示符，保持畫面整潔

# -------------------------------
# 📁 目錄導航
# -------------------------------
setopt auto_cd                   # 輸入資料夾名稱自動 cd 進去
setopt auto_pushd                # 使用 cd 時自動將上一個資料夾推入堆疊
setopt pushd_ignore_dups         # 避免 pushd 堆疊中出現重複項目
setopt glob_complete             # 啟用萬用字元補全提示
setopt numeric_glob_sort         # 補全時使用數值排序
export DIRSTACKSIZE=10           # pushd 堆疊大小上限

# -------------------------------
# 🕘 歷史紀錄
# -------------------------------
setopt correct                   # 自動更正拼錯的指令（輸入錯誤時提示修正）
setopt hist_save_no_dups         # 儲存歷史時不包含重複紀錄
setopt inc_append_history        # 即時寫入歷史檔，而非關閉 shell 時才寫入
setopt extended_history          # 每條紀錄都含時間戳
setopt hist_ignore_space         # 以空白開頭的指令不會被記錄
setopt hist_reduce_blanks        # 移除指令中的多餘空白
setopt hist_verify               # 讓歷史紀錄指令需按 Enter 才執行
setopt hist_fcntl_lock           # 避免歷史檔在多個 shell 間被寫壞

export HISTFILE=~/.zsh_history   # 歷史紀錄檔案位置
export SAVEHIST=$HISTSIZE        # 儲存的歷史筆數 = 記憶中大小

# -------------------------------
# 📝 游標移動與字元
# -------------------------------
export WORDCHARS=${WORDCHARS:s:/}  # 把斜線從 WORDCHARS 移除，讓 Ctrl+← 停在目錄分隔處

# -------------------------------
# 🔧 補全設定
# -------------------------------
setopt nolistbeep                # 補全失敗時不發出嗶聲

zstyle ':completion:*' menu select                  # 啟用選單型補全介面
zstyle ':completion:*' extra-verbose yes            # 顯示更多補全資訊
zstyle ':completion:*:descriptions' format "%F{yellow}--- %d%f"  # 顯示補全來源說明
zstyle ':completion:*:messages' format '%d'         # 補全訊息格式
zstyle ':completion:*:warnings' format "%F{red}No matches for:%f %d"  # 沒有匹配時的提示格式
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'  # 自動更正提示
zstyle ':completion:*' group-name ''                # 群組補全項目
zstyle ':completion:*' auto-description 'specify: %d'  # 沒有補全說明時使用此格式
zstyle ':completion::complete:*' use-cache 1        # 啟用補全快取（儲存在 ~/.zcompcache）
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' \
                                   'r:|[._-]=* r:|=*' \
                                   'l:|=* r:|=*'   # 補全時不分大小寫、支援模糊匹配
