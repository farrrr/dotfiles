#!/usr/bin/env zsh

# ~/.config/zsh/functions.zsh

###############################################################################
# 🧩 自定義函數
# 此檔案用來定義常用的自訂函式，方便日常工作或改善 UX
###############################################################################

# 使用 bat 結合 less 顯示檔案內容
function less() {
  local filename="${@:$#}"     # 最後一個參數是檔名
  local flaglength=$(($# - 1))  # 其他為旗標
  if ((flaglength > 0)); then
    local other="${@:1:$flaglength}"
    bat $filename --pager "less $LESS $other"
  elif ((flaglength == 0)); then
    bat $filename --pager "less $LESS"
  else
    command less
  fi
}

# 以顏色顯示 diffs、結合 grc
function rg() {
  command rg --pretty --smart-case --no-line-number "$@" | less
}
function fd() {
  command $FD --color always "$@" | less
}
alias fd='noglob fd'
alias rg='noglob rg'

# 搜尋文字並顯示高亮結果
function h() {
  grep --color=always -E "$1|$" $2 | less
}

# 使用 HTTPie 美化輸出
function httpp() {
  command http --pretty=all "$@" | command less -r
}

# git co foo**<tab>：fuzzy 補全 branch 名稱並切換
function co() {
  local branches branch
  branches=$(git branch -a) &&
  branch=$(echo "$branches" | egrep -i "$1" | $FZF +s +m) &&
  git checkout $(echo "$branch" | sed "s:.* remotes/origin/::" | sed "s:.* ::")
}

# 顯示服務目錄對應的 tree-id（用於 Git 內部定位）
function getTreeidForService() {
  noglob git cat-file -p @^{tree} | \
     grep "services$" | \
     awk '{ system("git cat-file -p " $3) }' | \
     egrep "$1$" | \
     awk '{ print substr($3, 0, 11) }'
}

# 改善 lazygit 切 repo 後自動 cd
function lg() {
  export LAZYGIT_NEW_DIR_FILE=~/.lazygit/newdir
  lazygit "$@"
  if [ -f $LAZYGIT_NEW_DIR_FILE ]; then
    cd "$(cat $LAZYGIT_NEW_DIR_FILE)"
    rm -f $LAZYGIT_NEW_DIR_FILE > /dev/null
  fi
}

# 執行上一條命令並插入結果
function insert-last-command-output() {
  LBUFFER+="$(eval $history[$((HISTCMD-1))])"
}
zle -N insert-last-command-output
bindkey "^X^L" insert-last-command-output
