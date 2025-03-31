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

# Ctrl-x, Ctrl-k：剪掉整行 + 複製到系統剪貼簿
# Ctrl-u, Ctrl-k：向前/向後刪除 + 複製至剪貼簿
# ⌘+W 類似效果
{{- if eq .chezmoi.os "darwin" }}
pb-copy-region-as-kill () {
  zle copy-region-as-kill
  print -rn $CUTBUFFER | pbcopy
}
zle -N pb-copy-region-as-kill
bindkey -e '\ew' pb-copy-region-as-kill

pb-backward-kill-line () {
  zle backward-kill-line
  print -rn $CUTBUFFER | pbcopy
}
zle -N pb-backward-kill-line
bindkey -e '^u' pb-backward-kill-line

pb-kill-line () {
  zle kill-line
  print -rn $CUTBUFFER | pbcopy
}
zle -N pb-kill-line
bindkey -e '^k' pb-kill-line

pb-kill-buffer () {
  zle kill-buffer
  print -rn $CUTBUFFER | pbcopy
}
zle -N pb-kill-buffer
bindkey -e '^x^k' pb-kill-buffer
{{- end }}
