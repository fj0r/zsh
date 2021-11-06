if [[ -d $HOME/world ]]; then
    hash -d w="$HOME/world"
else
    hash -d w="/world"
fi

hash -d c="$CFG"
hash -d p="$HOME/pub"
hash -d s="$HOME/.ssh"
hash -d k="$HOME/.kube"
hash -d v="$HOME/.config/nvim"
hash -d z="$CFG/.zshrc.d"

hash -d f="$HOME/Desktop"
hash -d d="$HOME/Downloads"
hash -d o="$HOME/Documents"
hash -d a="$HOME/assets"
