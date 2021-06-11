alias wq='wg-quick'
alias wqu='wg-quick up'
alias wqd='wg-quick down'

function wqe {
    sudo $EDITOR /etc/wireguard/${1:-wg0}.conf
}

function wqr {
    sudo bash -c "wg syncconf ${1:-wg0} <(wg-quick strip ${1:-wg0})"
}

function gen-wg-key {
    umask 077 # default: 022
    wg genkey | tee ${1:-wg} | wg pubkey > ${1:-wg}.pub
}
