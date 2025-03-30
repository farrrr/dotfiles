#!/usr/bin/env bash

if command -v "eza" >/dev/null 2>&1; then
    alias ls="eza -F --icons -a --group-directories-first"
    alias ll="ls --long --group --header --binary --time-style=long-iso --icons"
else
    alias ls="ls --color=auto"
    alias ll="ls -al"
fi

alias gcloud='docker run --rm -it -v "${HOME%/}"/.config/gcloud:/root/.config/gcloud gcr.io/google.com/cloudsdktool/cloud-sdk gcloud'

# alias for bash-language-server in docker container
alias bash-language-server="docker run --platform linux/amd64 --rm -i ghcr.io/shunk031/bash-language-server:latest"