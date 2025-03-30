#!/usr/bin/env zsh

# for golang
export GOPATH="${HOME}/codebase"

typeset -gU path
path=(
    $path
    /usr/local/go/bin(N-/)
    ${GOPATH}/bin(N-/)
)
