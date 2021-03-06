if (( $+commands[docker] )); then
    #_dx_ctl="docker run -e user=__\$USER:\$UID:\$GID"
    _dx_ctl="docker run"
elif (( $+commands[podman] )); then
    # --uidmap 0:\$UID:5000
    _dx_ctl="podman run"
fi

usable_port () {
    BASE_PORT=$1
    INCREMENT=1

    port=$BASE_PORT
    isfree=$(netstat -taln | grep $port)

    while [[ -n "$isfree" ]]; do
        port=$[port+INCREMENT]
        isfree=$(netstat -taln | grep $port)
    done

    echo $port
}

HOSTADDR=${HOSTADDR:-$(hostname -I | awk '{print $1}')}
_dx_debug="--cap-add=SYS_ADMIN --cap-add=SYS_PTRACE --security-opt seccomp=unconfined"
_docker_appimage="--device /dev/fuse --security-opt apparmor:unconfined"
_docker_netadmin="--cap-add=NET_ADMIN --device /dev/net/tun"
_dx_clip="-e DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix"
_dx_proxy="-e HOSTADDR=$HOSTADDR -e http_proxy=http://${HOSTADDR}:7890 -e https_proxy=http://${HOSTADDR}:7890"
_dx_port="-p \$(usable_port 2200):22 -p \$(usable_port 5000):5000"
_dx_id="_\$(date +%m%d%H%M)"
_dx_dir="\$HOME/.cache"
_dx_sshkey="-e ed25519_root=\"\$(cat \$HOME/.ssh/id_ed25519.pub|awk '{print \$2}')\""
alias ox="${_dx_ctl} --rm -it -v \$PWD:/world ${_dx_clip} ${_dx_debug} ${_dx_proxy} ${_dx_sshkey}"
alias ors="ox --name rs${_dx_id} -v ${_dx_dir}/cargo:/opt/cargo ${_dx_port} io:rs"
alias orsn="ox --name rs${_dx_id} -v ${_dx_dir}/cargo:/opt/cargo ${_dx_port} io:rsn"
alias ohs="ox --name hs${_dx_id} -v ${_dx_dir}/stack:/opt/stack ${_dx_port} io:hs"
alias ohsn="ox --name hs${_dx_id} -v ${_dx_dir}/stack:/opt/stack ${_dx_port} io:hsn"
alias ghci="ox --name hs${_dx_id} -v ${_dx_dir}/stack:/opt/stack ${_dx_port} io:hs stack repl"
alias ogo="ox --name go${_dx_id} -v ${_dx_dir}/gopkg:/opt/gopkg ${_dx_port} io:go"
alias opy="ox --name py${_dx_id} -p \$(usable_port 8888):8888 io:torch"
alias ojpl="ox --name jpl${_dx_id} -p \$(usable_port 8888):8888 io:jpl"
alias ong="ox --name ng${_dx_id} -e INSPECT_REQUEST=1 -v ${_dx_dir}/ng:/srv -p \$(usable_port 8080):80 ${_dx_port} ng"
alias opg="ox --name pg${_dx_id} -p \$(usable_port 5432):5432 -e POSTGRES_USER=pg -e POSTGRES_PASSWORD=123123 -v ${_dx_dir}/pg:/var/lib/postgresql/data ng:pg"

oa () {
    local target
    local args=$(getopt -o t: -- "$@")
    eval set -- "$args"
    while true; do
        case "$1" in
            -t)
                shift
                target="$1"
                ;;
            --)
                shift
                break
                ;;
        esac
        shift
    done
    app="${_dx_ctl} --rm -it"
    name="--name dbg-$target"
    ns="--uts container:$target --ipc container:$target --pid container:$target --network container:$target"
    cmd="$app $name $ns -v $PWD:/world ${_dx_clip} ${_dx_debug} ${_dx_proxy} ${_dx_sshkey} $*"
    eval $cmd
}
