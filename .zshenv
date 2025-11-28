export REPOS_BASE=~/repos

if [[ -z $XDG_CONFIG_HOME ]]
then
    export XDG_CONFIG_HOME=~/.config
    export XDG_DATA_HOME=~/.local/share
fi

mkdir -p $XDG_CONFIG_HOME/zsh
mkdir -p $XDG_DATA_HOME/zsh

export ZDOTDIR=$XDG_CONFIG_HOME/zsh

# Paths
path=(
    ~/.cargo/bin
    ~/.local/bin
    ~/bin
    /usr/local/sbin
    /usr/local/bin
    $XDG_DATA_HOME/npm/bin
    $path
)

if ((EUID == 0))
then
    path=(/sbin /bin /usr/sbin /usr/bin $path)
fi

typeset -U path # remove any duplicates from the array

fpath=(
    $XDG_CONFIG_HOME/zsh/{autoload,local}
    $XDG_CONFIG_HOME/zsh/{autoload,local}/*(N/)
    $fpath
)

# Editor
if (($+commands[nvim]))
then export EDITOR=nvim
else export EDITOR=vim
fi

export VISUAL=$EDITOR

# Misc
export LANG=en_GB.UTF-8
export LC_COLLATE=C
export MANWIDTH=90
export PYTHONSTARTUP=~/.pyrc
export PERLDOC_SRC_PAGER=$EDITOR
export PS_PERSONALITY=bsd
export PS_FORMAT=pid,ppid,pgid,sid,tname,tpgid,stat,euser,egroup,start_time,cmd

# Fzf
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse'

if (($+commands[fd])) || (($+commands[fdfind]))
then
   export FZF_DEFAULT_COMMAND='fd --strip-cwd-prefix -tf -Hup -E.git -E.venv -E"*~"' # find files
   export  FZF_CTRL_T_COMMAND='fd --strip-cwd-prefix     -Hup -E.git -E.venv -E"*~"' # find everything
   export   FZF_ALT_C_COMMAND='fd --strip-cwd-prefix -td -Hp'                        # fuzzy cd
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

# history
HISTFILE=$XDG_DATA_HOME/zsh/history
HISTSIZE=10000
SAVEHIST=10000
HISTORY_IGNORE='(v|c|c *|cd|<1-9>|-)'

# Colors
. $XDG_CONFIG_HOME/zsh/colors.zsh

# Mac OS
[[ $(uname) == Darwin ]] && . $XDG_CONFIG_HOME/zsh/darwin.zsh

# Local
[[ -r $XDG_CONFIG_HOME/zsh/.zshenv-local.zsh ]] && . $XDG_CONFIG_HOME/zsh/.zshenv-local.zsh
