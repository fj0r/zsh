autoload -U is-at-least

if (( $+commands[inv])); then
    __completion_cache invoke "inv --print-completion-script zsh"
fi

if (( $+commands[fab])); then
    __completion_cache fabric "fab --print-completion-script zsh"
fi

if (( $+commands[just])); then
    __completion_cache just "just --completions zsh | sed '\$d'"
    alias j='just'
    compdef _just just
fi

