function mm {
    local emoji=":tada:"
    local channel
    local url="mmhook"
    eval set -- $(getopt -o c:e:u: -- "$@")
    while true; do
        case "$1" in
        -c)
            shift
            channel=$1
            ;;
        -e)
            shift
            emoji=$1
            ;;
        -u)
            shift
            url=$1
            ;;
        --)
            shift
            break
            ;;
        esac
        shift
    done
    if [ ! -z "$channel" ]; then
        channel=",\"channel\":\"$channel\""
    fi
    curl -sS -X POST -H 'Content-Type: application/json' \
         $(cat $HOME/.config/${url}.url) \
         -d "{\"text\": \"$1 $emoji\n<${USER}@${HOST}>\"${channel}}"
}

function entf {
    local title
    local content=""
    eval set -- $(getopt -o t:c: -- "$@")
    while true; do
        case "$1" in
        -t)
            shift
            title=$1
            ;;
        -c)
            shift
            content=$1
            ;;
        --)
            shift
            break
            ;;
        esac
        shift
    done

    curl -# --ssl \
        --url "smtp://${EMAIL_SERVER:-smtp.qq.com}" \
        --user "${EMAIL_ACCOUNT}:${EMAIL_TOKEN}" \
        --mail-from $EMAIL_ACCOUNT \
        --mail-rcpt $1 \
        --upload-file <(echo -e "From: \"$EMAIL_ACCOUNT\" <$EMAIL_ACCOUNT>\nTo: \"$1\" <$1>\nSubject: ${title}\nDate: $(date)\n\n${content}")
}

function _comp_entf_recipients {
    local -a recipients
    for i in ${(ps:\n:)EMAIL_RECIPIENTS}; do
        recipients+=($i)
    done
    _describe 'recipients' recipients
}

function _comp_entf {
    _arguments '-t[title]' '-c[content]' '1:recipient:_comp_entf_recipients'
}

compdef _comp_entf entf
