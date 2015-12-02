#! /usr/bin/env zsh
# Author: Dimitar Dimitrov
#         kurkale6ka

path=(~/bin $path)
typeset -U path # remove any duplicates from the array

export PYTHONSTARTUP=~/.pyrc

export LANG=en_GB.UTF-8
export LC_COLLATE=C

# Remove w permissions for group and others
# file      default: 666 (-rw-rw-rw-) => 644 (-rw-r--r--)
# directory default: 777 (drwxrwxrwx) => 755 (drwxr-xr-x)
umask 022

## Vim
if (( $+commands[nvim] ))
then nvim=nvim
else nvim=vim
fi

export EDITOR=$nvim
export VISUAL=$nvim

export MYVIMRC=~/.vimrc
export MYGVIMRC=~/.gvimrc

## ps
export PS_PERSONALITY=bsd
export PS_FORMAT=pid,ppid,pgid,sid,tname,tpgid,stat,euser,egroup,start_time,cmd

export LOCATE_PATH=~/var/mlocate.db

# -i   : ignore case
# -r/R : raw control characters
# -s   : Squeeze multiple blank lines
# -W   : Highlight first new line after any forward movement
# -M   : very verbose prompt
# -PM  : customize the very verbose prompt (there is also -Ps and -Pm)
# ?letterCONTENT. - if test true display CONTENT (the dot ends the test) OR
# ?letterTRUE:FALSE.
# ex: ?L%L lines, . - if number of lines known: display %L lines,
export LESS='-i -r -s -W -M -PM?f%f - :.?L%L lines, .?ltL\:%lt:.?pB, %pB\% : .?e(Bottom)%t'

if [[ -x =keychain ]]
then
   eval "$(keychain --eval --agents ssh -Q --quiet id_rsa id_rsa_git)"
fi

# Business specific or system dependant stuff
[ -r ~/.zprofile_after ] && . ~/.zprofile_after

# [[ -z $DISPLAY ]] && (( XDG_VTNR == 1 )) && exec startx
