#[Esc][h] man 当前命令时，显示简短说明
alias run-help >&/dev/null && unalias run-help
autoload run-help

# -L 只追踪相对链接 -E 添加 html 后缀
alias sget='wget -m -k -E -p -np -e robots=off'
alias aria2rpc='aria2c --max-connection-per-server=8 --min-split-size=10M --enable-rpc --rpc-listen-all=true --rpc-allow-origin-all'

if (( $+commands[ss] )); then
    alias ns='ss -tulwnp'
else
    alias ns="netstat -plnetu"
fi


function toggle-proxy {
    if [ -z $http_proxy ] || [ ! -z $1 ]; then
        local url=${1:-http://localhost:1081}
        echo "set proxy to $url"
        export http_proxy=$url
        export https_proxy=$url
        export no_proxy=localhost,127.0.0.0/8,*.local
    else
        echo "unset proxy"
        unset http_proxy
        unset https_proxy
        unset no_proxy
    fi
}

function toggle-proxy-git {
    if [ -z "$(git config --global --get http.proxy)" ] || [ ! -z $1 ]; then
        local url=${1:-http://localhost:1081}
        echo "set git proxy to $url"
        git config --global http.proxy $url
        git config --global https.proxy $url
    else
        echo "unset git proxy"
        git config --global --unset http.proxy
        git config --global --unset https.proxy
    fi
}

#历史命令 top10
alias top10='print -l  ${(o)history%% *} | uniq -c | sort -nr | head -n 10'

function timeconv { date -d @$1 +"%Y-%m-%d %T" }

alias sch="grep -rnw '.' --color=auto -e"

function runmd {
    local i
    for i in $*
        awk '/```/{f=0} f; /```bash/{f=1}' ${i} | /bin/bash -ex
}

# 查找大文件
function findBigFiles {
    find . -type f -size +$1 -print0 | xargs -0 du -h | sort -nr
}

function slam {
    local n=0
    until eval $*
    do
        n=$[$n+1]
        echo "$fg_bold[red]$(date -Is)<$n>$reset_color $*"
        sleep 1
    done
}
