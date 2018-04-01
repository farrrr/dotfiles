###############################################################################
# .zshrc is sourced in interactive shells.
# It should contain commands to set up aliases, functions, options, key bindings, etc.
###############################################################################
#echo ".zshrc running"
#START=$(gdate +%s.%N)
#rm ~/.zcompdump ~/.zcompcache
fpath=(~/.zsh-personal-completions $fpath)
autoload -U +X compinit && compinit
autoload -U +X bashcompinit && bashcompinit
autoload -U zmv

###############################################################################
# remember your ancestor
###############################################################################
source ~/.bash_profile

###############################################################################
# directory navigation options
###############################################################################
setopt autocd autopushd pushdignoredups globcomplete
export DIRSTACKSIZE=10

###############################################################################
# history
###############################################################################
setopt correct histignorealldups incappendhistory extendedhistory histignorespace histreduceblanks hist_verify

export HISTFILE=~/.zsh_history
export SAVEHIST=$HISTSIZE

###############################################################################
# development
###############################################################################
export ANDROID_HOME=/usr/local/share/android-sdk

###############################################################################
# completion
###############################################################################
setopt nolistbeep
# Do menu-driven completion.
zstyle ':completion:*' menu select

# Color completion for some things.
# converted LSCOLORS using https://geoff.greer.fm/lscolors/
if [[ $OSTYPE == 'linux-gnu' ]]; then
  zstyle ':completion:*' list-colors 'di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=36:ow=36'
else
  zstyle ':completion:*' list-colors 'di=36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43'
fi

# formatting and messages
# http://www.masterzen.fr/2009/04/19/in-love-with-zsh-part-one/
zstyle ':completion:*' verbose yes
# describe different versions of completion. Test with: cd<tab>
zstyle ':completion:*:descriptions' format "%F{yellow}--- %d%f"
zstyle ':completion:*:messages' format '%d'
# when no match exists. Test with: cd fdjsakl<tab>
zstyle ':completion:*:warnings' format "%F{red}No matches for:%f %d"
zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'
# groups matches. Test with cd<tab>
zstyle ':completion:*' group-name ''
# this will only show up if a parameter flag has a name but no description
zstyle ':completion:*' auto-description 'specify: %d'
# this should make completion for some commands faster, haven't noticed though. saves in .zcompcache
zstyle ':completion::complete:*' use-cache 1

# activate approximate completion, but only after regular completion (_complete)
# zstyle ':completion:::::' completer _complete _approximate
# limit to 1 error
# zstyle ':completion:*:approximate:*' max-errors 1
# case insensitive completion
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'

# command line completion for kubectl
if [ -x "$(command -v kubectl)" ]; then
  source <(kubectl completion zsh)
fi

###############################################################################
# zplug - zsh plugin manager
###############################################################################
if [[ -d /usr/local/opt/zplug ]]; then
  export ZPLUG_HOME=/usr/local/opt/zplug
elif [[ -d ~/.zplug ]]; then
  export ZPLUG_HOME=~/.zplug
fi
source $ZPLUG_HOME/init.zsh

zplug 'zplug/zplug', hook-build:'zplug --self-manage'
zplug "zsh-users/zsh-completions"
zplug "lukechilds/zsh-better-npm-completion", defer:2
zplug "plugins/colored-man-pages", from:oh-my-zsh, defer:2
# command-not-found works for both Ubuntu and Mac
zplug "plugins/command-not-found", from:oh-my-zsh, defer:2

if [[ $OSTYPE == 'linux-gnu' ]]; then
  zplug "holygeek/git-number", as:command, use:'git-*', lazy:true
  zplug "zsh-users/zsh-syntax-highlighting", defer:2
  zplug "zsh-users/zsh-autosuggestions", defer:2
fi

# zplug check returns true if all packages are installed
# Therefore, when it returns false, run zplug install
if ! zplug check; then
    zplug install
fi

# source plugins and add commands to the PATH
zplug load

# yarn must be run after node is defined
export PATH="$PATH:$(yarn global bin)"

###############################################################################
# add-ons installed by homebrew
###############################################################################
if [ -f /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# fuzzy completion: ^R, ^T, ⌥C, **
[ -f ~/.fzf.`basename $SHELL` ] && source ~/.fzf.`basename $SHELL`

# set up direnv
if [ -x "$(command -v direnv)" ]; then
  eval "$(direnv hook $SHELL)"
fi
# this needs to be done just once, and you will be prompted about it
# direnv allow

###############################################################################
# prompt
###############################################################################
if [ -d ~/.zsh-git-prompt ]; then
  GIT_PROMPT_EXECUTABLE="haskell"
  source ~/.zsh-git-prompt/zshrc.sh
fi

export ZSH_THEME_GIT_PROMPT_BRANCH="%{$fg[magenta]%}"
export ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[green]%}%{✚%G%}"
export ZSH_THEME_GIT_PROMPT_CONFLICTS="%{$fg_bold[red]%}%{✖%G%}"
export ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg[red]%}%{●%G%}"
export PROMPT_PERCENT_OF_LINE=20
function myPromptWidth() {
  echo $(( ${COLUMNS:-80} * PROMPT_PERCENT_OF_LINE / 100 ))
}
width_part='$(myPromptWidth)'
PROMPT="%K{106}%F%${width_part}<…<%3~%f%k%(?..%{$fg[red]%} %?%{$reset_color%})%(1j.%{$fg[cyan]%} %j%{$reset_color%}.) "
git_part='$(git_super_status)'
RPROMPT="${git_part} %F{106}%*%f"

###############################################################################
# fun functions
###############################################################################
function co() {
    local branches branch
    branches=$(git branch -a) &&
    branch=$(echo "$branches" | egrep -i "$1"  | fzf +s +m) &&
    git checkout $(echo "$branch" | sed "s:.* remotes/origin/::" | sed "s:.* ::")
}

# git co foo**<tab>
_fzf_complete_git() {
    ARGS="$@"
    local branches
    branches=$(git branch -vv --all)
    if [[ $ARGS == 'git co'* ]]; then
        _fzf_complete "--reverse --multi" "$@" < <(
            echo $branches
        )
    else
        eval "zle ${fzf_default_completion:-expand-or-complete}"
    fi
}
_fzf_complete_git_post() {
     awk '{print $1}' | sed "s:remotes/origin/::"
}

function go() {
    local repos repo
    repos=$(find $CODE_DIR -name .git -type d -maxdepth 3 -prune | egrep -i "$1"  | sed 's#/.git$##') &&
    repo=$(echo "$repos" | fzf +s +m) &&
    cd $(echo "$repo" | sed "s:.* remotes/origin/::" | sed "s:.* ::")
}

function rg() {
  command rg --pretty --smart-case --no-line-number $* | less
}

# highlighter
function h {
  grep --color=always -E "$1|$" $2 | less
}

# like z, but if there are alternatives show them in fzf
c() {
  local dir
  dir="$(fasd -Rdl "$1" | fzf -1 -0 --no-sort +m)" && cd "${dir}" || return 1
}

# Use Ctrl-x,Ctrl-l to get the output of the last command
insert-last-command-output() {
LBUFFER+="$(eval $history[$((HISTCMD-1))])"
}
zle -N insert-last-command-output
bindkey "^X^L" insert-last-command-output

###############################################################################
# Suffix aliases - http://zshwiki.org/home/examples/aliassuffix
###############################################################################
alias -s zip="zipinfo"

###############################################################################
# keybindings
###############################################################################
bindkey "^P" history-beginning-search-backward
bindkey "^N" history-beginning-search-forward
# make zsh behave like bash for ctrl-u (fine to modify since most others will have bash)
bindkey "^U" backward-kill-line
# edit command line like in bash (zsh has 'fc' but it has to execute the command first)
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

###############################################################################
# Syntax highlighting for the shell
# syntax highlighting should be loaded after all widgets, to work with them
###############################################################################
if [ -f /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi
export ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets root)
export ZSH_HIGHLIGHT_STYLES[assign]='bg=18,fg=220' # dark blue background
export ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=219,bg=236' # pink
export ZSH_HIGHLIGHT_STYLES[commandseparator]='bg=21,fg=195' # light on dark blue
export ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=94' # brown
export ZSH_HIGHLIGHT_STYLES[globbing]='fg=99' # lilac
export ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=63' # softer lilac
export ZSH_HIGHLIGHT_STYLES[path]='fg=cyan,underline' # make folders same colors as in ls
export ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]='fg=243,underline'
export ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=white,underline'
export ZSH_HIGHLIGHT_STYLES[redirection]='fg=148,bold,bg=235' # >> yellow-green
export ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=182' # light pink

#echo ".zshrc finished:"
#END=$(gdate +%s.%N)
#echo "$END - $START" | bc
