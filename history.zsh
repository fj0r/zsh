#历史纪录条目数量
export HISTSIZE=100000
#注销后保存的历史纪录条目数量
export SAVEHIST=10000
#历史纪录文件
export HISTFILE=~/.zsh_history
#以附加的方式写入历史纪录
setopt INC_APPEND_HISTORY
#如果连续输入的命令相同，历史纪录中只保留一个
setopt HIST_IGNORE_DUPS
#为历史纪录中的命令添加时间戳
setopt EXTENDED_HISTORY

#启用 cd 命令的历史纪录，cd -[TAB]进入历史路径
setopt AUTO_PUSHD
#相同的历史路径只保留一个
setopt PUSHD_IGNORE_DUPS

#在命令前添加空格，不将此命令添加到纪录文件中
#setopt HIST_IGNORE_SPACE

if (( $+commands[sqlite3] )); then
    source $CFG/.zshrc.d/histdb/sqlite-history.zsh
    autoload -Uz add-zsh-hook
    source $CFG/.zshrc.d/histdb/histdb-interactive.zsh
    bindkey '\C-r' _histdb-isearch
fi
