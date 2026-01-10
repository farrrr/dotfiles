#!/usr/bin/env zsh
# ~/.config/zsh/aliases.zsh

###############################################################################
# 🔖 別名設定 (Aliases & Suffix Aliases)
# 此檔案包含常用指令縮寫與副檔名關聯執行程式
# 注意：此檔案由 Sheldon (common-alias) 載入
###############################################################################

# ----------------------------------
# 🌐 通用 alias (General Aliases)
# ----------------------------------

# eza: 現代化的 ls 替代品
# 檢查 eza 是否存在
if (( $+commands[eza] )); then
  alias ls="eza -F --icons -a --group-directories-first"
  alias ll="ls --long --group --header --binary --time-style=long-iso --icons"
else
  # Fallback: 使用標準 ls
  alias ls="ls --color=auto"
  alias ll="ls -al"
fi

# gcloud: 以容器方式執行 Google Cloud SDK
alias gcloud='docker run --platform linux/amd64 --rm -it -v "${HOME%/}"/.config/gcloud:/root/.config/gcloud gcr.io/google.com/cloudsdktool/cloud-sdk gcloud'

# Bash LSP: 使用容器版 bash-language-server
alias bash-language-server="docker run --platform linux/amd64 --rm -i ghcr.io/shunk031/bash-language-server:latest"

# dircolors: 修正部分系統缺少 dircolors 指令的問題
if (( ! $+commands[dircolors] )); then
  if (( $+commands[gdircolors] )); then
    alias dircolors=gdircolors
  fi
fi

# bat: 現代化的 cat 替代品 (支援語法高亮)
if (( $+commands[bat] )); then
  alias cat=bat

  # batgrep: 使用 bat 搜尋並整合 less 分頁
  function batgrep() {
    command batgrep --color --smart-case --context=0 "$@" | command less -+J -+W
  }
  # noglob 防止 Shell 展開通配符，讓 batgrep 自己處理
  alias batgrep='noglob batgrep'
fi

# prettyping: 美化 ping 輸出
if (( $+commands[prettyping] )); then
  alias ping="prettyping --nolegend"
fi

# curlie: 結合 curl 強大功能與 httpie 介面
if (( $+commands[curlie] )); then
  alias curl=curlie
fi

# fd / rg: 防止 Shell 過度展開，並保留這兩個強力工具的別名
alias fd='noglob fd'
alias rg='noglob rg'

# ----------------------------------
# 📄 Suffix Aliases (副檔名關聯)
# 當在 Shell 輸入 `foo.ext` 時，自動展開為 `command foo.ext`
# ----------------------------------

# 壓縮檔使用 zipinfo 查看
alias -s zip="zipinfo"

# 程式碼與文字檔案使用 VS Code (code) 開啟
alias -s {avdl,c,coffee,css,el,gql,gradle,graphql,h,handlebars,hpp,html,http,java,js,json,json5,jsx,lock,log,md,py,rb,scss,swift,text,ts,tsx,txt,xml,yaml,yml,yo}=code
