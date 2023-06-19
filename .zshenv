export REPOS_BASE=~/repos

if [[ -z $XDG_CONFIG_HOME ]]
then
    export XDG_CONFIG_HOME=~/.config
    export XDG_DATA_HOME=~/.local/share
fi

mkdir -p $XDG_CONFIG_HOME/zsh
mkdir -p $XDG_DATA_HOME/zsh

export ZDOTDIR=$XDG_CONFIG_HOME/zsh

export PYTHONSTARTUP=~/.pyrc

export LANG=en_GB.UTF-8
export LC_COLLATE=C

umask 022 # remove w permissions for group and others

export MANWIDTH=90

# readline
# if I wanted to run bash from within zsh
export INPUTRC=$REPOS_BASE/github/config/dotfiles/.inputrc

# Paths
if [[ -d $XDG_CONFIG_HOME/zsh ]]
then
    fpath=($XDG_CONFIG_HOME/zsh/{autoload,after} $XDG_CONFIG_HOME/zsh/{autoload,after}/*(N/) $fpath)
    autoload -z $XDG_CONFIG_HOME/zsh/{autoload,after}/**/*~*~(N.:t)
fi

path=(
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

# Mac OS specific
if [[ $(uname) == Darwin ]]
then
    brew_prefix=/usr/local/opt # brew --prefix
    path=(/usr/local/bin $path)

    typeset -A whois fzf
    whois[bin]=/usr/local/opt/whois/bin
    whois[man]=/usr/local/opt/whois/share/man
    fzf[man]=$HOME/.fzf/man

    formulae=(coreutils ed findutils gnu-sed gnu-tar grep)

    # Amend path to get GNU commands vs the default BSD ones
    # $brew_prefix/ + formula + /libexec/gnubin
    path=(${${formulae/#/$brew_prefix/}/%/\/libexec\/gnubin} $whois[bin] $path)

    MANPATH=${(j/:/)${${formulae/#/$brew_prefix/}/%/\/libexec\/gnuman}}:$fzf[man]:$whois[man]:/usr/local/share/man:"$(man --path)"

    typeset -U manpath
    export MANPATH

    # Persist Perl modules across brew updates. First install local::lib with:
    # cpanm -l ~/perl5 local::lib
    eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib=$HOME/perl5)"
fi

# Editor
if (($+commands[nvim]))
then
   export EDITOR=nvim
else
   export EDITOR=vim
fi

export VISUAL=$EDITOR

# Perl
export PERLDOC_SRC_PAGER=$EDITOR

# fzf
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse'

if (($+commands[fd])) || (($+commands[fdfind]))
then
   export FZF_DEFAULT_COMMAND='fd --strip-cwd-prefix -tf -Hup -E.git -E.venv -E"*~"' # find files
   export  FZF_CTRL_T_COMMAND='fd --strip-cwd-prefix     -Hup -E.git -E.venv -E"*~"' # find everything
   export   FZF_ALT_C_COMMAND='fd --strip-cwd-prefix -td -Hp'                        # fuzzy cd
fi

# ps
export PS_PERSONALITY=bsd
export PS_FORMAT=pid,ppid,pgid,sid,tname,tpgid,stat,euser,egroup,start_time,cmd

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

# Local zprofile
[[ -r $XDG_CONFIG_HOME/zsh/.zshenv-local.zsh ]] && . $XDG_CONFIG_HOME/zsh/.zshenv-local.zsh
