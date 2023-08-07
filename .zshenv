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

export MANWIDTH=90

# readline
# if I wanted to run bash from within zsh
export INPUTRC=$REPOS_BASE/github/config/dotfiles/.inputrc

# Paths
if [[ -d $XDG_CONFIG_HOME/zsh ]]
then
    fpath=($XDG_CONFIG_HOME/zsh/{autoload,local} $XDG_CONFIG_HOME/zsh/{autoload,local}/*(N/) $fpath)
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

# Colors
if [[ $(uname) != OpenBSD ]]
then
    # Colored man pages with less
    # These can't reside in .zprofile since there is no terminal for tput
    _bld="$(tput bold || tput md)"
    _udl="$(tput smul || tput us)"
    _lgrn=$_bld"$(tput setaf 2 || tput AF 2)"
    _lblu=$_bld"$(tput setaf 4 || tput AF 4)"
    _res="$(tput sgr0 || tput me)"

    export LESS_TERMCAP_mb=$_lgrn # begin blinking
    export LESS_TERMCAP_md=$_lblu # begin bold
    export LESS_TERMCAP_me=$_res  # end mode

    # Stand out (reverse) - info box (yellow on blue bg)
    export LESS_TERMCAP_so=$_bld"$(tput setaf 3 || tput AF 3)$(tput setab 4 || tput AB 4)"
    export LESS_TERMCAP_se="$(tput rmso || tput se)"$_res

    # Underline
    export LESS_TERMCAP_us=${_bld}${_udl}"$(tput setaf 5 || tput AF 5)" # purple
    export LESS_TERMCAP_ue="$(tput rmul || tput ue)"$_res

    # Set LS_COLORS
    [[ -n $REPOS_BASE ]] && eval "$(dircolors $REPOS_BASE/github/config/dotfiles/.dir_colors)"
fi

# Linux virtual console colors
# TODO: keep here or move to .zshrc?
if [[ $TERM == linux ]]
then
    echo -en "\e]P0262626" #  0. black
    echo -en "\e]P8605958" #  8. darkgrey

    echo -en "\e]P18c4665" #  1. darkred
    echo -en "\e]P9cd5c5c" #  9. red

    echo -en "\e]P2287373" #  2. darkgreen
    echo -en "\e]PA7ccd7c" # 10. green

    echo -en "\e]P3ffa54f" #  3. brown
    echo -en "\e]PBeedc82" # 11. yellow

    echo -en "\e]P43465A4" #  4. darkblue
    echo -en "\e]PC87ceeb" # 12. blue

    echo -en "\e]P55e468c" #  5. darkmagenta
    echo -en "\e]PDee799f" # 13. magenta

    echo -en "\e]P631658c" #  6. darkcyan
    echo -en "\e]PE76eec6" # 14. cyan

    echo -en "\e]P7787878" #  7. lightgrey
    echo -en "\e]PFbebebe" # 15. white

    clear # reset to default input colours
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

# Local zprofile
[[ -r $XDG_CONFIG_HOME/zsh/.zshenv-local.zsh ]] && . $XDG_CONFIG_HOME/zsh/.zshenv-local.zsh
