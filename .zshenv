## XDG
# configuration home
if [[ -z $XDG_CONFIG_HOME ]]
then
   export XDG_CONFIG_HOME=$HOME/.config
fi

# data home
if [[ -z $XDG_DATA_HOME ]]
then
   export XDG_DATA_HOME=$HOME/.local/share
fi

## Zsh dot files
export ZDOTDIR=$XDG_CONFIG_HOME/zsh
