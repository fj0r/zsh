if (( $+commands[kubectl] )); then
    __KUBECTL_COMPLETION_FILE="${HOME}/.zsh_cache/kubectl_completion"

    if [[ ! -f $__KUBECTL_COMPLETION_FILE ]]; then
        mkdir -p ${HOME}/.zsh_cache
        kubectl completion zsh >! $__KUBECTL_COMPLETION_FILE
    fi

    [[ -f $__KUBECTL_COMPLETION_FILE ]] && source $__KUBECTL_COMPLETION_FILE

    unset __KUBECTL_COMPLETION_FILE
fi

function _gen_kubectl_alias {
    eval "alias kg$1='kubectl get $2'"
    eval "alias ko$1='kubectl get -o yaml $2'"
    eval "alias kg$1a='kubectl get $2 --all-namespaces'"
    eval "alias kg$1w='kubectl get $2 --watch'"
    eval "alias kg$1i='kubectl get $2 -o wide'"
    eval "alias kg$1iw='kubectl get $2 -o wide --watch'"
    eval "alias ke$1='kubectl edit $2'"
    eval "alias kd$1='kubectl describe $2'"
    eval "alias kdel$1='kubectl delete $2'"
}

# This command is used a LOT both below and in daily life
alias k=kubectl
alias kg='kubectl get'
alias ko='kubectl get -o yaml'
alias kd='kubectl describe'
alias ke='kubectl edit'
alias kc='kubectl create'
alias klb="kubectl label --overwrite"

# Execute a kubectl command against all namespaces
alias kca='_kca(){ kubectl "$@" --all-namespaces;  unset -f _kca; }; _kca'

# Apply a YML file
alias kaf='kubectl apply -f'
# Apply resources from a directory containing kustomization.yaml
alias kak='kubectl apply -k'

# Drop into an interactive terminal on a container
alias keti='kubectl exec -ti'
alias ka='kubectl exec -ti'

# Manage configuration quickly to switch contexts between local, dev ad staging.
alias kcuc='kubectl config use-context'
alias kcsc='kubectl config set-context'
alias kcdc='kubectl config delete-context'
alias kccc='kubectl config current-context'

# List all contexts
alias kcgc='kubectl config get-contexts'

# General aliases
alias kdel='kubectl delete'
alias kdelf='kubectl delete -f'
alias kdelk='kubectl delete -k'

# Pod management.
_gen_kubectl_alias p pods

# get pod by label: kgpl "app=myapp" -n myns
alias kgpl='kgp -l'

# get pod by namespace: kgpn kube-system"
alias kgpn='kgp -n'

# Service management.
_gen_kubectl_alias s svc

# Ingress management
_gen_kubectl_alias i ingress

# Namespace management
_gen_kubectl_alias ns namespaces
alias kgnsl='kgns -o jsonpath="{.items[*].metadata.name}" -l'
alias kcns='kubectl create namespace'
alias klbns="klb namespace"
alias kcn='kubectl config set-context $(kubectl config current-context) --namespace'

# ConfigMap management
_gen_kubectl_alias cm configmaps

# Secret management
_gen_kubectl_alias sec secret

# Deployment management.
_gen_kubectl_alias d deployment
alias ksd='kubectl scale deployment'
alias krsd='kubectl rollout status deployment'
kres(){
    kubectl set env $@ REFRESHED_AT=$(date +%Y%m%d%H%M%S)
}

# Rollout management.
alias kgrs='kubectl get rs'
alias krh='kubectl rollout history'
alias kru='kubectl rollout undo'

# Statefulset management.
_gen_kubectl_alias ss statefulset
alias ksss='kubectl scale statefulset'
alias krsss='kubectl rollout status statefulset'

# Port forwarding
alias kpf='kubectl port-forward'

# Tools for accessing all information
alias kga='kubectl get all'
alias kgaa='kubectl get all --all-namespaces'

# Logs
alias kl='kubectl logs'
alias kl1h='kubectl logs --since 1h'
alias kl1m='kubectl logs --since 1m'
alias kl1s='kubectl logs --since 1s'
alias klf='kubectl logs -f'
alias klf1h='kubectl logs --since 1h -f'
alias klf1m='kubectl logs --since 1m -f'
alias klf1s='kubectl logs --since 1s -f'

# File copy
alias kcp='kubectl cp'

# Node Management
_gen_kubectl_alias no nodes

# PVC management.
_gen_kubectl_alias pvc pvc
alias kgpv='kubectl get pv'
alias kgpvca='kubectl get pvc --all-namespaces'
alias kgpvcw='kgpvc --watch'

# top
alias ktn='kubectl top node'
alias ktp='kubectl top pod'

### kcc
function kcco {
    export KUBECONFIG=~/.kube/$1
    #_kube_ps1_update_cache
}

function wkcc {
    if [[ -n "$WSL_DISTRO_NAME" && -z "$WSLHOME" ]]; then
        export WSLHOME=$(wslpath $(wslvar USERPROFILE))
    fi
    if [ -n "$WSLHOME" ]; then
        export KUBECONFIG=~/.kube/$1
        cp -f $KUBECONFIG $WSLHOME/.kube/config
    else
        echo 'not a WSL environment!'
    fi
}

function kcc {
    export _KUBECONFIG=~/.kube/$1
    local KUBECONF=/tmp/kubeconf-$UID/$$/$1
    if [ ! -f $_KUBECONFIG ]; then
        echo "$_KUBECONFIG is not a KUBECONFIG"
        return
    fi
    if [ ! -f $KUBECONF ]; then
        local dir=$(dirname $KUBECONF)
        if [ ! -d $dir ]; then
            mkdir -p $dir
            chmod -R go-rwx /tmp/kubeconf-$UID
        fi
        cp -f $_KUBECONFIG $KUBECONF
    fi
    export KUBECONFIG=$KUBECONF
}

function _clean_kcc {
    if [ -d /tmp/kubeconf-$UID/$$ ]; then
        rm -rf /tmp/kubeconf-$UID/$$
    fi
}
add-zsh-hook zshexit _clean_kcc

_kcc() {
    local -a contexts
    local desc
    if (( $+commands[yq] )); then
        #desc='yq r $HOME/.kube/$i 'current-context''
        #desc='yq e '.current-context' $HOME/.kube/$i'
        desc="grep 'current-context:' \$HOME/.kube/\$i | awk '{print \$2}'"
    else
        desc='$i'
    fi
    for i in $(grep -e '^current-context:.*' -rl $HOME/.kube --exclude-dir="*cache" --exclude="*.log" | sed 's!'"$HOME/.kube/"'!!'); do
        contexts+="${i}:$(eval $desc)"
    done
    _arguments '1:contexts:((${contexts}))'
}

compdef _kcc kcco
compdef _kcc kcc
compdef _kcc wkcc


function kn {
    kubectl config set-context $(kubectl config current-context) --namespace $1
    if [[ -f $KUBECONFIG && -f $_KUBECONFIG ]]; then
        cp -f $KUBECONFIG $_KUBECONFIG
    fi
}

_kn() {
    _arguments "1:namespace:(($(kubectl get namespace -o jsonpath='{.items[*].metadata.name}')))"
}

compdef _kn kn

###
function clean-evicted-pod {
    kubectl get pods --all-namespaces -ojson \
        | jq -r '.items[] | select(.status.reason!=null) | select(.status.reason | contains("Evicted")) | .metadata.name + " " + .metadata.namespace' \
        | xargs -n2 -l bash -c "kubectl delete pods \$0 --namespace=\$1"
}

function kube-rm-stucked-ns {
    kubectl get namespace "$1" -o json \
        | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
        | kubectl replace --raw /api/v1/namespaces/$1/finalize -f -
}

alias kube-rm-strucked='kdel --grace-period=0 --force'
alias kube-rm-finalizer="kubectl patch -p '{\"metadata\":{\"finalizers\":null}}'"

### helm
if (( $+commands[helm] )); then
    __HELM_COMPLETION_FILE="${HOME}/.zsh_cache/helm_completion"

    if [[ ! -f $__HELM_COMPLETION_FILE ]]; then
        helm completion zsh >! $__HELM_COMPLETION_FILE
    fi

    [[ -f $__HELM_COMPLETION_FILE ]] && source $__HELM_COMPLETION_FILE

    unset __HELM_COMPLETION_FILE
fi

alias kgcert='kubectl get certificates,certificaterequests,orders,challenges -o wide'
alias kecert='kubectl edit certificates'

_gen_kubectl_alias v virtualservices
_gen_kubectl_alias g gateways
_gen_kubectl_alias dr destinationrules
alias kggva='kubectl get gateways,virtualservices -A'

alias kgtk='kubectl get tekton-pipelines'
