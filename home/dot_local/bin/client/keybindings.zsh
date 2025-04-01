#!/usr/bin/env zsh

# Ctrl-x, Ctrl-k：剪掉整行 + 複製到系統剪貼簿
# Ctrl-u, Ctrl-k：向前/向後刪除 + 複製至剪貼簿
# ⌘+W 類似效果
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
