export REPOS_BASE=~/repos

mkdir -p $XDG_CONFIG_HOME/zsh
mkdir -p $XDG_DATA_HOME/zsh

if [[ ! -L $XDG_CONFIG_HOME/zsh/.zprofile ]]
then
    ln -sr $REPOS_BASE/zsh/.zprofile $XDG_CONFIG_HOME/zsh
    ln -sr $REPOS_BASE/zsh/.zshrc    $XDG_CONFIG_HOME/zsh
    ln -sr $REPOS_BASE/zsh/autoload  $XDG_CONFIG_HOME/zsh
fi

export ZDOTDIR=$XDG_CONFIG_HOME/zsh
