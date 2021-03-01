autoload -U add-zsh-hook
autoload -U compinit
compinit
# zmodload zsh/complist
zmodload -i zsh/complist

#允许在交互模式中使用注释
setopt INTERACTIVE_COMMENTS

#启用自动 cd，输入目录名回车进入目录
setopt AUTO_CD

#扩展路径
#/v/c/p/p => /var/cache/pacman/pkg
setopt complete_in_word

#禁用 core dumps
# limit coredumpsize 0

#键绑定风格 (e)macs|(v)i
bindkey -e
#设置 [DEL]键 为向后删除
bindkey "\e[3~" delete-char

#以下字符视为单词的一部分
WORDCHARS='-*[]~#%^<>{}'

###### title
case $TERM in (*xterm*|*rxvt*|(dt|k|E)term)
   preexec () { print -Pn "\e]0;${PWD/$HOME/\~}: $1\a" }
   ;;
esac

alias a='alias'
alias orz='source ~/.zshrc'
alias rm='rm -i'
alias mv='mv -i'
alias ll='ls -alh'
alias du='du -h'
alias df='df -h'
alias mkdir='mkdir -p'
alias r='grep --color=auto'
alias diff='diff -u'
alias l='tail -f'
alias u='curl -v'

function t {
    local name="$(whoami)@$(hostname)[${1:-}]"
    tmux attach -t $name || tmux new -s $name
}
alias tl='tmux list-sessions'

function x {
    export $1=$2
}

function o {
    echo $(eval "echo \"\$$1\"")
}

_ofunc () {
    _arguments '1:vars:_vars'
}
compdef _ofunc o

function take() {
    mkdir -p $@ && cd ${@:$#}
}
function px { ps aux | grep -i "$*" }
function p { pgrep -a "$*" }
__default_indirect_object="local z=\${@: -1} y=\$1 && [[ \$z == \$1 ]] && y=\"\$default\""

function sources { [ -f $1 ] && source $1 }

function __completion_cache {
    local __CACHED_COMPLETION_FILE="${HOME}/.zsh_cache/${1}_completion"

    if [[ ! -f $__CACHED_COMPLETION_FILE ]]; then
        mkdir -p ${HOME}/.zsh_cache
        eval $2 >! $__CACHED_COMPLETION_FILE
    fi

    sources $__CACHED_COMPLETION_FILE 
    #unset __CACHED_COMPLETION_FILE
}

if [ -x "$(command -v nvim)" ]; then
    export EDITOR=nvim
elif [ -x "$(command -v vim)" ]; then
    export EDITOR=vim
else
    export EDITOR=vi
fi

if [ -n "$VIMRUNTIME" ]; then
    alias v=drop
    alias e=drop
else
    alias v=$EDITOR
    alias e=$EDITOR
fi

export TIME_STYLE=long-iso
alias n='date +%y%m%d%H%M%S'
alias now='date -Iseconds'
