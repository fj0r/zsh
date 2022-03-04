_docker_debug="--cap-add=SYS_PTRACE --security-opt seccomp=unconfined"
_docker_appimage="--cap-add=SYS_ADMIN --device /dev/fuse"
_docker_netadmin="--cap-add=NET_ADMIN --device /dev/net/tun"

if [ -z "$CRICTL" ]; then
    if (( $+commands[podman] )); then
        export CRICTL=podman
        export CRICOMPOSE="docker-compose"
    elif (( $+commands[nerdctl] )); then
        export CRICTL=nerdctl
        export CRICOMPOSE="nerdctl compose"
        _docker_appimage="${_docker_appimage} --security-opt apparmor:unconfined"
    else
        export CRICTL=docker
        export CRICOMPOSE="docker-compose"
        _docker_appimage="${_docker_appimage} --security-opt apparmor:unconfined"
    fi
fi

alias d="$CRICTL"
alias di="$CRICTL images"
alias drmi="$CRICTL rmi"
alias dt="$CRICTL tag"
alias dp="$CRICTL ps"
alias dpa="$CRICTL ps -a"
alias dl="$CRICTL logs -ft"
alias dpl="$CRICTL pull"
alias dps="$CRICTL push"
alias dr="$CRICTL run ${_docker_debug} ${_docker_appimage} -i -t --rm -v \$PWD:/world"
alias drr="$CRICTL run --rm -v \$PWD:/world"
alias dcs="$CRICTL container stop"
alias dcr="$CRICTL container rm -f"
alias dcp="$CRICTL cp"
alias dsp="$CRICTL system prune -f"
alias dspa="$CRICTL system prune --all --force --volumes"
alias dvi="$CRICTL volume inspect"
alias dvr="$CRICTL volume rm"
#alias dvp="$CRICTL volume prune"
alias dvp="$CRICTL volume rm \$($CRICTL volume ls -q | awk -F, 'length(\$0) == 64 { print }')"
alias dvl="$CRICTL volume ls"
alias dvc="$CRICTL volume create"
alias dsv="$CRICTL save"
alias dld="$CRICTL load"
alias dh="$CRICTL history"
alias dhl="$CRICTL history --no-trunc"
alias dis="$CRICTL inspect"

alias dc="$CRICOMPOSE"
alias dcu="$CRICOMPOSE up"
alias dcud="$CRICOMPOSE up -d"
alias dcd="$CRICOMPOSE down"

function da {
    if [ $# -gt 1 ]; then
        $CRICTL exec -it $@
    else
        $CRICTL exec -it $1 /bin/sh -c "[ -e /bin/zsh ] && /bin/zsh || [ -e /bin/bash ] && /bin/bash || /bin/sh"
    fi
}

function dg {
    dr --pid=container:$1 --net=container:$1 ${2:-io} ${3:-zsh}
}

_dgcn () {
    local dsc=()
    while read -r line; do
        local rest=$(echo $line | awk '{$1="";$2=""; print $0;}')
        local id=$(echo $line | awk '{print $1;}')
        local name=$(echo $line | awk '{print $2;}')
        dsc+="$name:$rest"
        dsc+="$id:$rest"
    done <<< $($CRICTL container ls -a --format '{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t')
    _describe containers dsc
}
compdef _dgcn da dg

function dvbk {
    for i in $*
        $CRICTL run --rm       \
            -v $PWD:/backup    \
            -v ${i}:/data      \
            ubuntu:focal       \
            tar --transform='s/^\.//' -zcvf /backup/vol_${i}_`date +%Y%m%d%H%M%S`.tar.gz -C /data .
}

_dvlq () {
    _alternative "$CRICTL volumes:volume:($($CRICTL volume ls -q | awk -F, 'length($0) != 64 { print }'))"
}
compdef _dvlq dvbk

function dvrs {
    $CRICTL volume create $2
    $CRICTL run --rm           \
            -v $PWD:/backup    \
            -v $2:/data        \
            alpine             \
            tar zxvf /backup/$1 -C /data
}

_dvrs () {
    _arguments '1:backup file:_files' '2:volume:_dvlq'
}
compdef _dvrs dvrs

function ipl {
    if (( $+commands[skopeo] )); then
        echo 'use local skopeo'
        for i in $*; do
            echo "<-- $i"
            sleep 1
            skopeo copy docker://$i docker-daemon:$i
        done
    else
        echo 'use container skopeo'
        for i in $*; do
            echo "<-- $i"
            sleep 1
            docker run -i -t --rm \
                -v /var/run/docker.sock:/var/run/docker.sock \
                -v /var/lib/containers:/var/lib/containers \
                -e http_proxy=$http_proxy \
                -e https_proxy=$https_proxy \
                fj0rd/0x:k8s skopeo copy \
                docker://$i \
                containers-storage:$i
        done
    fi
}

function bud {
    docker run -i -t --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v /var/lib/containers:/var/lib/containers \
        -v $PWD:/world \
        -e http_proxy=$http_proxy \
        -e https_proxy=$https_proxy \
        fj0rd/0x:k8s buildah bud \
            --pull \
            -t containers-storage:$1 \
            -f /world/${2:Dockerfile} /world \
            && skopeo copy containers-storage:$1 docker-daemon:$1
}
