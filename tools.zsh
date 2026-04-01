# rust
[[ -f ~/.cargo/env ]] && . ~/.cargo/env

# fzf key bindings and fuzzy completion
. <(fzf --zsh)

# kubernetes
if (($+commands[kubectl]))
then
    . <(kubectl completion zsh)
fi

# pacman
if (($+commands[pacaur]))
then
    alias pacs='pacaur -Ss'
    alias pacsync='pacaur -Syu'
elif (($+commands[pacman]))
then
    alias pacs=pacsearch
    alias pacsync='pacman -Syu'
fi

# pnpm
export PNPM_HOME="$XDG_DATA_HOME"/pnpm
path=($PNPM_HOME $path)

# pyenv
if (($+commands[pyenv]))
then
    export PYENV_ROOT="$HOME/.pyenv"
    [[ -d $PYENV_ROOT/bin ]] && path=($PYENV_ROOT/bin $path)
    eval "$(pyenv init - zsh)"
fi

# zoxide
eval "$(zoxide init --cmd c zsh)"
