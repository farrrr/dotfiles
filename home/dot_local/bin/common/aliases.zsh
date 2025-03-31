#!/usr/bin/env zsh
# ~/.config/zsh/aliases.zsh

###############################################################################
# 🔖 別名設定（alias & suffix alias）
# 此檔案包含常用指令縮寫與副檔名關聯執行程式
###############################################################################

# ----------------------------------
# 🌐 通用 alias（補充功能、簡寫）
# ----------------------------------

# eza（彩色 ls）支援與 fallback 到 ls
if command -v "eza" >/dev/null 2>&1; then
  alias ls="eza -F --icons -a --group-directories-first"
  alias ll="ls --long --group --header --binary --time-style=long-iso --icons"
else
  alias ls="ls --color=auto"
  alias ll="ls -al"
fi

# gcloud：以容器方式執行 Google Cloud SDK
alias gcloud='docker run --rm -it -v "${HOME%/}"/.config/gcloud:/root/.config/gcloud gcr.io/google.com/cloudsdktool/cloud-sdk gcloud'

# Bash LSP：使用容器版 bash-language-server
alias bash-language-server="docker run --platform linux/amd64 --rm -i ghcr.io/shunk031/bash-language-server:latest"

# 如果系統沒有 dircolors，使用 GNU coreutils 的 gdircolors
if [ ! -x "$(command -v dircolors)" ]; then
  alias dircolors=gdircolors
fi

# bat 取代 cat，並改善 less 顯示
if [ -x "$(command -v bat)" ]; then
  alias cat=bat

  # 定義 batgrep 輔助功能
  function batgrep() {
    command batgrep --color --smart-case --context=0 "$@" | command less -+J -+W
  }
  alias batgrep='noglob batgrep'
fi

# ping 美化輸出
if [ -x "$(command -v prettyping)" ]; then
  alias ping="prettyping --nolegend"
fi

# curlie = curl + httpie 結合版本
if [ -x "$(command -v curlie)" ]; then
  alias curl=curlie
fi

# fd 與 rg 已由 function 包裝並 noglob，可安全 alias 回原名
alias fd='noglob fd'
alias rg='noglob rg'

# ----------------------------------
# 📄 副檔名自動對應程式（suffix alias）
# 讓某些檔案可以直接打檔名就執行對應程式（如開啟 .json 就打 foo.json）
# ----------------------------------

alias -s zip="zipinfo"
alias -s {avdl,c,coffee,css,el,gql,gradle,graphql,h,handlebars,hpp,html,http,java,js,json,json5,jsx,lock,log,md,py,rb,scss,swift,text,ts,tsx,txt,xml,yaml,yml,yo}=code
