#!/usr/bin/env zsh
# 通用別名設定
# 由 Sheldon 載入

# --- 檔案列表 ---
if (( $+commands[eza] )); then
    alias ls="eza -F --icons -a --group-directories-first --git"
    alias ll="ls --long --group --header --binary --time-style=long-iso --icons"
else
    alias ls="ls --color=auto"
    alias ll="ls -al"
fi

# --- 編輯器 ---
if (( $+commands[nvim] )); then
    alias vim="nvim"
fi

# --- 現代 CLI 替代品 ---
if (( $+commands[bat] )); then
    alias cat=bat
fi

if (( $+commands[prettyping] )); then
    alias ping="prettyping --nolegend"
fi

if (( $+commands[curlie] )); then
    alias curl=curlie
fi

# 防止 Shell 過度展開通配符
alias fd='noglob fd'
alias rg='noglob rg'

# --- 副檔名關聯 ---
alias -s zip="zipinfo"
alias -s {md,py,js,json,yaml,yml,ts,tsx}=code

# --- Zellij 智慧啟動器 ---
function zj() {
    if ! command -v fzf >/dev/null 2>&1; then
        zellij
        return
    fi

    local ZJ_SESSIONS
    ZJ_SESSIONS=$(zellij list-sessions 2>/dev/null)
    local ZJ_SESSIONS_COUNT
    ZJ_SESSIONS_COUNT=$(echo "$ZJ_SESSIONS" | wc -l | tr -d ' ')
    [[ -z "$ZJ_SESSIONS" ]] && ZJ_SESSIONS_COUNT=0

    local option_new="[NEW] 建立新 Session"
    local option_cancel="[CANCEL] 留在 Shell"

    local menu_content=""
    if [[ "$ZJ_SESSIONS_COUNT" -gt 0 ]]; then
        menu_content="$ZJ_SESSIONS\n"
    fi
    menu_content="${menu_content}${option_new}\n${option_cancel}"

    local selected
    selected=$(echo -e "$menu_content" | fzf --ansi --height=40% --layout=reverse --border --header="Zellij Sessions" --prompt="選擇 > ")

    if [[ "$selected" == "$option_new" ]]; then
        zellij
    elif [[ "$selected" == "$option_cancel" ]]; then
        return 0
    elif [[ -n "$selected" ]]; then
        local session_name
        session_name=$(echo "$selected" | awk '{print $1}' | sed 's/\x1b\[[0-9;]*m//g')
        zellij attach "$session_name"
    fi
}
