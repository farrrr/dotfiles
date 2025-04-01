#!/usr/bin/env zsh
# ~/.config/zsh/keybindings.zsh

###############################################################################
# ⌨️ 快捷鍵綁定
# 此檔案用來定義 Zsh 的鍵盤操作行為（如方向鍵搜尋、編輯、剪貼等）
###############################################################################

# 上/下方向鍵：從歷史中搜尋以目前輸入開頭的指令
bindkey "^P" history-beginning-search-backward
bindkey "^N" history-beginning-search-forward

# Ctrl-x Ctrl-e：打開外部編輯器編輯當前指令
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# Ctrl-x Ctrl-l：插入上一條指令的輸出結果
zle -N insert-last-command-output
bindkey "^X^L" insert-last-command-output

# 全域 alias 展開觸發鍵
zle -N globalias
bindkey "^X^a" globalias
