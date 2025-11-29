# rust
[[ -f ~/.cargo/env ]] && . ~/.cargo/env

# fzf
[[ -f ~/.fzf.zsh ]] && . ~/.fzf.zsh

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
else
    alias pacs=pacsearch
    alias pacsync='pacman -Syu'
fi

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
(($+commands[pyenv])) || export PATH="$PYENV_ROOT/bin:$PATH"
(($+commands[pyenv])) && eval "$(pyenv init -)"

# zoxide
eval "$(zoxide init --cmd c zsh)"
