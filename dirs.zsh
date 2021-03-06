if [[ -d $HOME/world ]]; then
    hash -d w="$HOME/world"
else
    hash -d w="/world"
fi

hash -d c="$CFG/.."
hash -d p="$HOME/pub"
hash -d s="$HOME/.ssh"
hash -d k="$HOME/.kube"
hash -d v="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
hash -d z="$CFG"

hash -d f="$HOME/Desktop"
hash -d d="$HOME/Downloads"
hash -d o="$HOME/Documents"
hash -d t="$HOME/temp"
