#!/usr/bin/env bash
#  shellcheck disable=SC1091
#  vim:ts=4:sts=4:sw=4:et

# ============================================================================ #
# STARTUP
# ============================================================================ #
# If not running interactively, don't do anything:
[ -z "${PS1:-}" ] && return

if [ -z "${HOME:-}" ]; then
    export HOME=~
fi

bash_tools="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export bash_tools

# shellcheck disable=SC1090,SC1091
. "$bash_tools/.bash.d/os-detection.sh"
. "$bash_tools/.bash.d/welcome.sh"

# enable color support for ls
if [ "$TERM" != "dumb" ]; then
    eval "$(dircolors -b)"
fi

export BASH_SILENCE_DEPRECATION_WARNING=1

# ============================================================================ #

#[ -f /etc/profile     ] && . /etc/profile
[ -f /etc/bash/bashrc ] && . /etc/bash/bashrc
[ -f /etc/bashrc      ] && . /etc/bashrc

[ -f /etc/bash_completion ] && . /etc/bash_completion

[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# shellcheck disable=SC1090,SC1091
[ -f "$HOME/.aliases" ] && source "$HOME/.aliases"

# ============================================================================ #
# History settings
# ============================================================================ #

export HISTSIZE=50000
export HISTFILESIZE=50000

rmhist(){ history -d "$1"; }
histrm(){ rmhist "$1"; }
histrmlast(){ history -d "$(history | tail -n 2 | head -n 1 | awk '{print $1}')"; }

# This adds a time format of "YYYY-mm-dd hh:mm:ss  command" to the bash history
export HISTTIMEFORMAT="%F %T  "

# stop logging duplicate successive commands to history
HISTCONTROL=ignoredups

# append rather than overwrite history
shopt -s histappend

# check window size and update $LINES and $COLUMNS after each command
shopt -s checkwinsize

shopt -s cdspell

# prevent core dumps which can leak sensitive information
ulimit -c 0

# tighten permissions except for root where library installations become inaccessible to my user account
if [ $EUID = 0 ]; then
    umask 0022
else
    # caused no end of problems when doing sudo command which retained 0077 and broke library access for user accounts
    umask 0022
fi

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# ============================================================================ #
# Colors
# ============================================================================ #

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac
# Otherwise set a title for the terminal window
PROMPT_COMMAND='echo -en "\033]0;${PWD/#$HOME/~}\a"'

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# ============================================================================ #
# Environment variables
# ============================================================================ #

export GOPATH="$HOME/go"
export GOROOT="${GOROOT:-/usr/local/go}"

export PATH="$GOPATH/bin:$GOROOT/bin"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export PATH="$HOME/.temporalio/bin:$PATH"
export PATH="$HOME/bin/btp:$PATH"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH"
# VSCODE
export PATH="$PATH:/mnt/c/Users/stock/AppData/Local/Programs/Microsoft VS Code/bin"

# Alias definitions
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# ============================================================================ #
# Functions
# ============================================================================ #

# Git Parser
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
# Only adds git parser
#export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w \[\033[01;31m\]$(parse_git_branch)\[\033[00m\]\$ '
# Modifies also user and host in the prompt + git parser
export PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\][PS]\[\033[00m\]:\[\033[01;34m\]\w \[\033[01;31m\]$(parse_git_branch)\[\033[00m\]\$ '

# Grep (search) through your history for previous run commands:
function hg() {
    history | grep "$1";
}

# ============================================================================ #
# Tools
# ============================================================================ #

# GPG
gpg-connect-agent /bye
export GPG_TTY=$(tty)

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# PNPM
export PNPM_HOME="~/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Brew
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv bash)"
