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
