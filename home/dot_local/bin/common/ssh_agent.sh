#!/usr/bin/env bash

# 啟動 ssh-agent
eval "$(ssh-agent)" >/dev/null 2>&1

# 遍歷 .ssh 目錄下所有以 id_ 開頭的私鑰檔案
for key in "${HOME}/.ssh/id_"*; do
    # 檢查檔案是否存在且是普通檔案
    if [ -f "$key" ]; then
        # 檢查檔案權限是否正確（600）
        if [ "$(stat -f %Lp "$key" 2>/dev/null || stat -c %a "$key")" = "600" ]; then
            ssh-add "$key" >/dev/null 2>&1
        else
            echo "警告：$key 的權限不是 600，已跳過" >&2
        fi
    fi
done
