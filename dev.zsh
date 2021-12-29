if (( $+commands[docker] )); then
    _dx_ctl="docker run -e user=__\$USER:\$UID:\$GID"
elif (( $+commands[podman] )); then
    # --uidmap 0:\$UID:5000
    _dx_ctl="podman run "
fi
_dx_debug="--cap-add=SYS_PTRACE --security-opt seccomp=unconfined"
_dx_proxy="-e http_proxy=http://172.17.0.1:7890 -e https_proxy=http://172.17.0.1:7890"
alias yx="${_dx_ctl} --rm -it -v \$PWD:/world ${_dx_debug} ${_dx_proxy}"
alias yrs="yx --name rs_\$(date +%m%d%H%M) -v \$HOME/.cache/cargo:/opt/cargo io:rs"
alias yhs="yx --name hs_\$(date +%m%d%H%M) -v \$HOME/.cache/stack:/opt/stack io:hs"
alias _yrs="yx -v \$HOME/.cache/cargo:/opt/cache io:rs"
alias _yhs="yx -v \$HOME/.cache/stack:/opt/cache io:hs"
alias ygo="yx --name go_\$(date +%m%d%H%M) -v \$HOME/.cache/gopkg:/home/__\$USER/go/pkg io:go"
alias _ygo="yx -v \$HOME/.cache/gopkg:/opt/cache io:go"
alias ypy="yx"
alias yjl="yx"
alias yjs="yx"
alias yrkt="yx"

