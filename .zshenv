# Repos
if [[ -z $REPOS_BASE ]]
then
   if [[ -d ~/github/editor ]]
   then
      # - zsh local startup (or su -)
      # - ssh own@...
      export REPOS_BASE=~/github
   else
      # command ssh (or /usr/bin/ssh) shared@...
      # . .zshenv + exec zsh to set REPOS_BASE to ~shared/my_folder
      export REPOS_BASE=$(cd ${${(%):-%x}%/*}/.. && pwd -P)
   fi
fi

if [[ -d ~/github/editor ]]
then
   base=$HOME
else
   # REPOS_BASE non null for the above reasons or because set from:
   # after/ssh.alt shared@...
   base=$REPOS_BASE
fi

# XDG
export XDG_CONFIG_HOME=$base/.config
export   XDG_DATA_HOME=$base/.local/share

# zsh
mkdir -p {$XDG_CONFIG_HOME,$XDG_DATA_HOME}/zsh
export ZDOTDIR=$XDG_CONFIG_HOME/zsh

# no ~/.config/zsh links in shared user home (mkconfig will take care of this)
if [[ $base != $HOME ]]
then
   for config in .zprofile .zshrc autoload
   do
      if [[ ! -L $XDG_CONFIG_HOME/zsh/$config ]]
      then
         ln -sr $REPOS_BASE/zsh/$config $XDG_CONFIG_HOME/zsh
      fi
   done
fi
