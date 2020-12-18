if (( $+commands[kubectl] )); then
    source $CFG/.zshrc.d/k8s/kubectl.zsh
    source $CFG/.zshrc.d/k8s/kube-ps1.zsh

    export KUBE_EDITOR=$EDITOR

fi
