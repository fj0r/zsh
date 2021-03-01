autoload -U is-at-least

if (( $+commands[inv])); then
    source <(inv --print-completion-script zsh)
fi

if (( $+commands[just])); then
    alias j='just'
    source <(just --completions zsh | sed '$d')
    compdef _just just
fi

