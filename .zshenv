# Repos
if [[ -z $REPOS_BASE ]]
then
   if [[ -d ~/github ]]
   then
      export REPOS_BASE=~/github
      base=$HOME
   elif [[ -d ~/dimitar ]]
   then
      export REPOS_BASE=~/dimitar
      base=$REPOS_BASE
   fi
else
   if [[ -d ~/github ]]
   then
      base=$HOME
   else
      base=$REPOS_BASE
   fi
fi

# XDG
export XDG_CONFIG_HOME=$base/.config
export   XDG_DATA_HOME=$base/.local/share

# Zsh dot directory
export ZDOTDIR=$XDG_CONFIG_HOME/zsh

if [[ $base != $HOME ]]
then
   mkdir -p {$XDG_CONFIG_HOME,$XDG_DATA_HOME}/zsh

   for config in .zprofile .zshrc autoload
   do
      if [[ ! -L $XDG_CONFIG_HOME/zsh/$config ]]
      then
         ln -sr $REPOS_BASE/zsh/$config $XDG_CONFIG_HOME/zsh
      fi
   done
fi
