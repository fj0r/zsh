function btoa {
    echo $1 | base64 -d
}

function atob {
    echo $1 | base64
}

function rnd {
    head /dev/urandom | tr -dc A-Za-z0-9 | head -c ${1:-13}
}

function gen-self-signed-cert {
    openssl req \
        -newkey rsa:4096 -nodes -sha256 -keyout $1.key \
        -x509 -days 365 -out $1.crt \
        -subj /CN=$1
}


export PASSWORD_RULE_PATH=$HOME/.config/passwd
if [ -d $PASSWORD_RULE_PATH ]; then
    chmod -R go-rwx $PASSWORD_RULE_PATH
fi

function gpw {
    local length=12
    local config='default'
    local http=''
    local options=$(getopt -o c:l:h  -- "$@")
    eval set -- "$options"
    while true; do
        case "$1" in
        -c)
            shift
            config="$1"
            ;;
        -l)
            shift
            length="$1"
            ;;
        -h)
            http="true"
            ;;
        --)
            shift
            break
            ;;
        esac
        shift
    done
    # local pwd=$(eval "echo \"\$$config\"")
    token=$(cat $PASSWORD_RULE_PATH/token/$config)
    pwd=$(pwgen -B1cn ${length} -H <(echo -n "$1" | openssl dgst -sha1 -hmac "$token"))
    echo $pwd
    if [ ! -z $http ]; then
        if (( $+commands[htpasswd] )); then
            echo $(htpasswd -nBb $1 $pwd)
        else
            echo $1:$(openssl passwd -apr1 $pwd)
        fi
    fi
}

function _comp_gpw {
    local name
    _arguments '-c[config]:config:->config' '-l[length]:length:' '-h[htpasswd]' "1:item:->item"
    case "$state" in
        config)
            _alternative ":config:($(ls -A $PASSWORD_RULE_PATH/rule))"
        ;;
        item)
            if [ -z ${opt_args[-c]} ]; then
                name="default"
            else
                name=${opt_args[-c]}
            fi
            local matcher
            _alternative "::($(cat $PASSWORD_RULE_PATH/rule/$name))"
        ;;
    esac
}

compdef _comp_gpw gpw
