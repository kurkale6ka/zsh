# Repos
if id -u dimitar >/dev/null 2>&1
then
   my_home=~dimitar
elif id -u mitko >/dev/null 2>&1
then
   my_home=~mitko
fi

if [[ -z $REPOS_BASE ]]
then
   if [[ -d $my_home/github ]]
   then
      # - zsh local startup (or su -)
      # - ssh own@...
      export REPOS_BASE=$my_home/github
   else
      # command ssh (or /usr/bin/ssh) shared@... (then . .zshenv + exec zsh)
      # REPOS_BASE set to ~shared/my_folder
      export REPOS_BASE=$(cd ${${(%):-%x}%/*}/.. && pwd -P)
   fi
fi

if [[ -d $my_home/github ]]
then
   base=$my_home
else
   # REPOS_BASE non null for the above reasons or because set from:
   # after/ssh.alt shared@...
   base=$REPOS_BASE
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
