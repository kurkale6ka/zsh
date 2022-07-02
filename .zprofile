# readline
# if I wanted to run bash from within zsh
export INPUTRC=$REPOS_BASE/config/dotfiles/.inputrc

# path
path=(~/.local/bin /usr/local/sbin $REPOS_BASE/vim/plugged/fzf.vim/bin $path)
typeset -U path # remove any duplicates from the array

export PYTHONSTARTUP=~/.pyrc

export LANG=en_GB.UTF-8
export LC_COLLATE=C

# Remove w permissions for group and others
# file      default: 666 (-rw-rw-rw-) => 644 (-rw-r--r--)
# directory default: 777 (drwxrwxrwx) => 755 (drwxr-xr-x)
umask 022

# Vim
if (( $+commands[nvim] ))
then
   export EDITOR=nvim
else
   export EDITOR="vim -u $REPOS_BASE/vim/.vimrc"
fi

export VISUAL=$EDITOR

# Perl
export PERLDOC_SRC_PAGER=$EDITOR

# fzf
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse'
if (( $+commands[fd] ))
then
   export FZF_DEFAULT_COMMAND='fd -tf -H -E.git -E.svn -E.hg --ignore-file ~/.gitignore -p'
   export  FZF_CTRL_T_COMMAND='fd     -H -E.git -E.svn -E.hg --ignore-file ~/.gitignore -p'
   export   FZF_ALT_C_COMMAND='fd -td -H -E.git -E.svn -E.hg --ignore-file ~/.gitignore'
fi

# ps
export PS_PERSONALITY=bsd
export PS_FORMAT=pid,ppid,pgid,sid,tname,tpgid,stat,euser,egroup,start_time,cmd

if [[ -e ~/var/mlocate.db ]]
then
   export LOCATE_PATH=~/var/mlocate.db
fi

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
export PAGER=less

# Local zprofile file
[[ -r $XDG_CONFIG_HOME/zsh/.zprofile_after ]] && . $XDG_CONFIG_HOME/zsh/.zprofile_after

# [[ -z $DISPLAY ]] && (( XDG_VTNR == 1 )) && exec startx
