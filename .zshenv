export REPOS_BASE=~/repos

if [[ -z $XDG_CONFIG_HOME ]]
then
    export XDG_CONFIG_HOME=~/.config
    export XDG_DATA_HOME=~/.local/share
fi

mkdir -p $XDG_CONFIG_HOME/zsh
mkdir -p $XDG_DATA_HOME/zsh

export ZDOTDIR=$XDG_CONFIG_HOME/zsh
