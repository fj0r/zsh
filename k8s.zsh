if (( $+commands[kubectl] )); then
    source $CFG/.zshrc.d/k8s/kubectl.zsh
    source $CFG/.zshrc.d/k8s/kube-ps1.zsh

    if [ -n "$VIMRUNTIME" ]; then
        export KUBE_EDITOR=$EDITOR
    else
        export KUBE_EDITOR=$EDITOR
    fi

fi
