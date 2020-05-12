# Repos
# REPOS_BASE null:
#   - local startup
#   - command ssh (or /usr/bin/ssh) shared@... (then . .zshenv + exec zsh)
#   - ssh own@...
if [[ -z $REPOS_BASE ]]
then
   if [[ -d ~/github ]]
   then
      # - zsh starting locally
      # - own remote user
      export REPOS_BASE=~/github
      base=$HOME
   elif [[ -d ~/dimitar ]]
   then
      # shared remote user
      export REPOS_BASE=~/dimitar
      base=$REPOS_BASE
   fi
else
   if [[ -d ~/github ]]
   then
      # local sudo zsh: REPOS_BASE github
      base=$HOME
   else
      # function ssh shared@...: REPOS_BASE dimitar
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
