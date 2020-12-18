function gen-ssh-key {
    local file='id_ed25519'
    local comment=$(date -Iseconds)
    local options=$(getopt -o c:f: -- "$@")
    eval set -- "$options"
    while true; do
        case "$1" in
        -c )
            shift
            comment="$1"
            ;;
        -f )
            shift
            file="$1"
            ;;
        -- )
            shift
            break
            ;;
        esac
        shift
    done
    ssh-keygen -t ed25519 -f ${file} -C ${comment}
    if (( $+commands[puttygen] )); then
        puttygen ${file} -o ${file}.ppk
    fi
}

alias ssh-copy-id-with-pwd='ssh-copy-id -o PreferredAuthentications=password -o PubkeyAuthentication=no -f -i'
alias sa='ssh-agent $SHELL'
alias sad='ssh-add'
alias rs="rsync -avP"

function s {
    local password="-o IdentitiesOnly=yes "
    local cmd="ssh "
    local show=""
    local shell=""
    eval set -- $(getopt -o VXPIi:p:u:R:L:D:J:ZB -- "$@")
    while true; do
        case "$1" in
        -V)
            show="1"
            ;;
        -X)
            cmd+="-X "
            ;;
        -P)
            password=""
            ;;
        -I)
            cmd+="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "
            ;;
        -i)
            shift
            cmd+="-i $1 "
            ;;
        -p)
            shift
            cmd+="-p $1 "
            ;;
        -u)
            shift
            cmd+="-o ProxyCommand='websocat -bE - $1' "
            ;;
        -R)
            shift
            cmd+="-NTvR $1 "
            ;;
        -L)
            shift
            cmd+="-NTvL $1 "
            ;;
        -D)
            shift
            cmd+="-NTvD $1 "
            ;;
        -J)
            shift
            cmd+="-J $1 "
            ;;
        -B)
            shell="/bin/bash -ic "
            ;;
        -Z)
            shell="-t /bin/zsh -ic "
            ;;
        --)
            shift
            break
            ;;
        esac
        shift
    done

    cmd+="${password}$1"
    if [ ! -z $2 ]; then
        shift
        cmd+=" ${shell}'$@'"
    fi

    if [ ! -z $show ]; then
        ssh -V
        echo
        echo $cmd
        return
    fi

    eval $cmd
}

compdef s=ssh