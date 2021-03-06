# $OSTYPE =~ [mac]^darwin, linux-gnu, [win]msys, FreeBSD, [termux]linux-android
# Darwin\ *64;Linux\ armv7*;Linux\ aarch64*;Linux\ *64;CYGWIN*\ *64;MINGW*\ *64;MSYS*\ *64

case $(uname -sm) in
    Darwin\ *64 )
        alias lns='ln -fs'
        function af { lsof -p $1 +r 1 &>/dev/null }
        alias osxattrd='xattr -r -d com.apple.quarantine'
        alias rmdss='find . -name ".DS_Store" -depth -exec rm {} \;'
        [[ -x $HOME/.iterm2_shell_integration.zsh ]]  && source $HOME/.iterm2_shell_integration.zsh
        ;;
    Linux\ *64 )
        alias lns='ln -fsr'
        function af { tail --pid=$1 -f /dev/null }
        alias drop_caches='sync; echo 3 | sudo tee /proc/sys/vm/drop_caches'
        ;;
    * )
        alias lns='ln -fsr'
        ;;
esac

compdef _kill af

if (( $+commands[ip] )); then
    export route=$(ip route | awk 'NR==1 {print $3}')
else
    export route=$(grep -m 1 nameserver /etc/resolv.conf | awk '{print $2}')
fi

function notify {
    local ug=${2:-2}
    local title=${3:-$(date -Is)}

    if (ps aux | grep awesome | grep -v grep > /dev/null); then
        local color=("#5684ae" "#048243" "#d9544d")
        local timeout=(5 30 0)
        # compose the notification
        MESSAGE="
        local naughty = require('naughty')
        naughty.notify({ \
            title = \"${title}\", \
            text = \"$1\", \
            timeout = ${timeout[$ug]}, \
            margin = 8, \
            width = 382, \
            border_color = \"${color[$ug]}\",
            border_width = 2,
            screen = 1,
        })"
        # send it to awesome
        echo $MESSAGE | awesome-client
    else
        local urgency=(low normal critical)
        notify-send -u "${urgency[$ug]}" -a "${title}" "$1"
    fi
}

function alert {
    RVAL=$?                           # get return value of the last command
    DATE=`date -Is`                     # get time of completion
    LAST=$history[$HISTCMD] # get current command
    LAST=${LAST%[;&|]*}      # remove "; alert" from it

    # set window title so we can get back to it
    echo -ne "\e]2;$LAST\a"

    LAST=${LAST//\"/'\"'}        # replace " for \" to not break lua format

    # check if the command was successful
    if [[ $RVAL == 0 ]]; then
        RVAL="SUCCESS"
        UGL=2
    else
        RVAL="FAILURE"
        UGL=3
    fi

    notify "$LAST" $UGL "$RVAL: $DATE"
}

if [ -n "$WSL_DISTRO_NAME" ]; then
    #ps# Install-Module -Name BurntToast
    toast () { powershell.exe -command New-BurntToastNotification "-Text '$1'" }
    # export WSLHOME=$(wslpath $(wslvar USERPROFILE))
fi

function china_mirrors {
    local b_u="cp /etc/apt/sources.list /etc/apt/sources.list.\$(date +%y%m%d%H%M%S)"
    local b_a="cp /etc/apk/repositories /etc/apk/repositories.\$(date +%y%m%d%H%M%S)"
    local s_u="sed -i 's/\(archive\|security\).ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list"
    local s_d="sed -i 's/\(.*\)\(security\|deb\).debian.org\(.*\)main/\1mirrors.ustc.edu.cn\3main contrib non-free/g' /etc/apt/sources.list"
    local s_a="sed -i 's/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g' /etc/apk/repositories"
    local s=$([ 0 -lt $UID ] && echo sudo)
    local cmd
    local os
    if [ -n "$1" ]; then
        cmd="echo"
        os="$1"
    else
        cmd="$s"
        os=$(grep ^ID= /etc/os-release | sed 's/ID=\(.*\)/\1/')
    fi
    case $os in
        ubuntu )
            eval "$cmd $b_u"
            eval "$cmd $s_u"
            ;;
        debian )
            eval "$cmd $b_u"
            eval "$cmd $s_d"
            ;;
        alpine )
            eval "$cmd $b_a"
            eval "$cmd $s_a"
            ;;
        * )
    esac
}

function make-swapfile {
    local file="/root/swapfile"
    local size="16"
    local options=$(getopt -o f:s: -- "$@")
    eval set -- "$options"
    while true; do
        case "$1" in
            -f)
                shift
                file=$1
                ;;
            -s)
                shift
                size=$1
                ;;
            --)
                shift
                break
                ;;
        esac
        shift
    done

    dd if=/dev/zero of=$file bs=1M count=$((1024*${size})) # GB
    chmod 0600 $file
    mkswap $file
    swapon $file
    echo "$file swap swap defaults 0 2" >> /etc/fstab
}


function iptables---- {
    iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    iptables -A INPUT -p tcp -m multiport --dport 22,80,443 -j ACCEPT
    iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
    iptables -A INPUT -p tcp --dport 55555 -j ACCEPT
    iptables -A INPUT -p tcp --dport 2222 -j ACCEPT
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -i wg0 -j ACCEPT
    iptables -P INPUT DROP
}

function iptables-allow-address {
    iptables -A INPUT -s $1 -j ACCEPT
}

function iptables-clean-input {
    iptables -P INPUT ACCEPT
    iptables -F
}

alias iptables-list-input="iptables -L INPUT --line-num -n"
