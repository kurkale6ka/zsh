setopt auto_pushd
setopt pushd_minus
setopt correct
setopt extended_glob
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt inc_append_history
setopt interactivecomments
setopt list_rows_first

unsetopt auto_name_dirs # shorter names in CWD
unsetopt case_glob
unsetopt complete_aliases
unsetopt clobber
unsetopt flow_control # no ^s freezing the screen

HISTFILE=$XDG_DATA_HOME/zsh/history
HISTSIZE=11000
SAVEHIST=11000

alias zn='zsh -f'

## Paths
if [[ -d $XDG_CONFIG_HOME/zsh ]]
then
   fpath=($XDG_CONFIG_HOME/zsh/{autoload,after} $XDG_CONFIG_HOME/zsh/{autoload,after}/*(N/) $fpath)
   autoload -z $XDG_CONFIG_HOME/zsh/{autoload,after}/**/*~*~(N.:t)
fi

if ((EUID == 0))
then
   path=(/root/bin /usr/local/sbin /usr/local/bin /sbin /bin /usr/sbin /usr/bin $path)
fi

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

path=(~/bin $path)
typeset -U path

## Prompts
psvar[1]=1
if [[ -z $SSH_CONNECTION ]]
then
   if ! who | 'grep' -q '([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\})'
   then
      psvar[1]=
      start_ssh_agent
   fi
fi

autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' formats '%b' # branch

precmd() {
   if ((!psvar[1]))
   then
      local vcs_info_msg_0_
      vcs_info
      psvar[2]=$vcs_info_msg_0_
   fi

   # Set the terminal title to [$PWD] host
   print -nP '\e]0;[%~] %M\a'
}

# %F{color}...%f
# %~: cwd, %2v: psvar[2], %m: hostname, %n: username %#: % or #
# %(x/true/false), !: root, ?(0): $? == 0, j1: jobs >= 1, V2: psvar[2] != empty
if [[ $TERM != *linux* ]]
then
   PROMPT=$'\n[%F{69}%~%f] %(2V.%F{238}%2v%f.)\n%(1V.%F{140}.%F{221})%m%f %(!.%F{9}%#%f.%#) '
   RPROMPT='%(1j.%F{9}%%%j%f ❬ .)%(!.%F{9}.%F{221})%n%f %(?/%T/%F{red}%T%f)'
else
   PROMPT=$'\n[%B%F{blue}%~%f%b] %2v\n%(1V.%F{magenta}.%F{yellow})%m%f %(!.%F{red}%#%f.%#) '
   RPROMPT='%(1j.%F{red}%%%j%f ❬ .)%(!.%F{red}.%F{yellow})%n%f %(?/%T/%F{red}%T%f)'
fi

## Processes and jobs (see Mac section too ^)
alias pg=$REPOS_BASE/scripts/pg.pl

alias k=kill
alias kg='kill -- -'

# jobs
alias z=fg
alias -- --='fg %-'

## Colors
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
   [[ -n $REPOS_BASE ]] && eval "$(dircolors $REPOS_BASE/config/dotfiles/.dir_colors)"
fi

# Linux virtual console colors
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

## zle bindings and terminal key settings
bindkey -e # emacs like line editing

# Home keys
typeset -A key

key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}

[[ -n ${key[Insert]}   ]] && bindkey ${key[Insert]}   overwrite-mode
[[ -n ${key[Delete]}   ]] && bindkey ${key[Delete]}   delete-char
[[ -n ${key[Home]}     ]] && bindkey ${key[Home]}     beginning-of-line
[[ -n ${key[End]}      ]] && bindkey ${key[End]}      end-of-line
[[ -n ${key[PageUp]}   ]] && bindkey ${key[PageUp]}   beginning-of-buffer-or-history
[[ -n ${key[PageDown]} ]] && bindkey ${key[PageDown]} end-of-buffer-or-history

# History navigation
autoload -Uz history-search-end

zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end  history-search-end

[[ -n ${key[Up]}   ]] && bindkey ${key[Up]}   history-beginning-search-backward-end
[[ -n ${key[Down]} ]] && bindkey ${key[Down]} history-beginning-search-forward-end

# Left and right arrows
[[ -n ${key[Left]}  ]] && bindkey ${key[Left]}  backward-char
[[ -n ${key[Right]} ]] && bindkey ${key[Right]} forward-char

# Make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} ))
then
   function zle-line-init () {
      printf '%s' "${terminfo[smkx]}"
   }
   function zle-line-finish () {
      printf '%s' "${terminfo[rmkx]}"
   }
   zle -N zle-line-init
   zle -N zle-line-finish
fi

# Use EDITOR/VISUAL to edit the command line
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^x^e' edit-command-line

# Bash like custom Ctrl + w delete
custom-backward-kill-word () {
  local WORDCHARS=${WORDCHARS}'`"+:@'"'"'|\,'
  WORDCHARS=${WORDCHARS}'-/.'
  zle backward-kill-word
}

zle -N custom-backward-kill-word
bindkey '^W' custom-backward-kill-word

# Remove -/. from words to improve alt + backspace/d
WORDCHARS=${WORDCHARS//[-\/.]}

## zle snippets

zle_highlight=(region:none special:standout suffix:bold isearch:underline paste:none)

### ^x= bc
bindkey -s '^x=' "bc <<< 'scale=20; '^b"

### ^x/ find
bindkey -s '^x/' "find . -name '^@' -printf '%M %u %g %P\\\n'^x^x"

### ^x\ GNU parallel
bindkey -s '^x\\' " | parallel -X ^@ {} ^x^x"

### ^x0/1/2/3 IPs
bindkey -s '^x0' '127.0.0.1'
bindkey -s '^x1' '192.168.0.'
bindkey -s '^x2' '10.0.0.'
bindkey -s '^x3' '172.16.0.'

### ^x- Ranges
bindkey -s '^x-' '{1\e ..}^b'
bindkey -s '^x.' '{1\e ..}^b'

### ^x| Output in columns
bindkey -s '^x|' ' | column -t'

### ^x_ /dev/null
bindkey -s '^x_' '/dev/null'

### ^xa awk
bindkey -s '^xa' "awk '^@{print $}' \e3^b"
bindkey -s '^xA' "awk '{sum += $1} END {print sum}' "

### ^xb Braces
bindkey -s '^xb' '(())\e2^b'
bindkey -s '^xB' '{}^b'
bindkey -s '^x[' '[[  ]]\e3^b'
bindkey -s '^x]' '[[  ]]\e3^b'

### ^xc Counting row occurrences in a stream
bindkey -s '^xc' ' | sort | uniq -c | sort -rn'
bindkey -s '^xC' 'comm -13 <(sort ^@) <(sort )^b'

### ^xd diff
bindkey -s '^xd' 'diff -u <() <(^@)\eb\e2^b'
bindkey -s '^xD' 'diff -uq^@ --from-file '

### ^xe ed
bindkey -s '^xe' "printf '%s\\\n' H ^@ wq | 'ed' -s "
bindkey -s '^xE' "printf '%s\\\n' H 0i ^@ . wq | 'ed' -s "

### ^xf Loops
bindkey -s '^xf' 'for i in '
bindkey -s '^xF' 'for i in ^@; do  $i; done\e2\eb^b'
bindkey -s '^xu' 'until ^@; do ; done\eb\e2^b'
bindkey -s '^xw' 'while ^@; do ; done\eb\e2^b'

### ^xl lsof
bindkey -s '^xl' 'lsof -i :'

### ^xm File renaming (mv)
bindkey -s '^xm' "find . -maxdepth 1 -name '^@' ! -path . -printf \"mv '%P' '%P'\\\n\" | v -c\"%EasyAlign/'.\\\{-}'/dal\" -c'se ft=sh' -^x^x"
bindkey -s '^xM' 'parallel mv -- {} {.}.^@ ::: *.'

### ^xn Directory statistics
bindkey -s '^xn' '*(om[1]D)^i'
bindkey -s '^xN' 'print -P "%F{39}Newest%f:"; lld *^@(om[1]D)'

bindkey -s '^x\eOB' '~/Downloads/*(om[1]D)^i'

bindkey -s '^xo' '*(Om[1]D)^i'
bindkey -s '^xO' 'print -P "%F{39}Oldest%f:"; lld *^@(Om[1]D)'

bindkey -s '^x@' 'inodes=(*^@(NDoN)); echo There are ${#inodes} items'

### ^xp printf
bindkey -s '^xp' 'print -l '

### ^xr/R rsync
bindkey -s '^xr' "rsync -ai "
bindkey -s '^xR' "rsync -ai^@ -e'ssh -q' -f'- '^b"

### ^x` Backticks
bindkey -s '^x`' '$()^b'

### ^xs systemd
bindkey -s '^xs' 'systemctl status'
bindkey -s '^xS' 'systemctl ^@start\C-x\C-x'

### ^xt Test
bindkey -s '^xt' ' && echo ok'

### ^xT tcpdump
bindkey -s '^xT' 'tcpdump -iany -s0 -nnq '

## Completion
setopt menu_complete # select the first item straight away
setopt auto_param_keys # use [ after completing a ${parameter}

zmodload zsh/complist
bindkey -M menuselect '^M' .accept-line
bindkey -M menuselect "\e[1;5B" accept-and-infer-next-history # ^<Down> to enter a directory
bindkey -M menuselect "\e[1;5A" undo # ^<Up> to get out of a directory

bindkey "\e[Z" reverse-menu-complete # <S-Tab> to go back in a menu selection
bindkey '^xh' _complete_help # show tags in current context
bindkey '^i' expand-or-complete-prefix # myf<tab>xxx -> myfilexxx
bindkey '^u' backward-kill-line

if autoload -Uz compinit
then
   if [[ -n $ZDOTDIR/.zcompdump(#qN.mh+24) ]]
   then
      compinit
   else
      compinit -C
   fi
fi

# zstyle context style '...' '...'
#        \
#         :completion:function:completer:command:argument:tag

zstyle ':completion:*' completer _complete _ignored _approximate
zstyle ':completion:*:approximate:::' max-errors 3 numeric

zstyle ':completion:*' verbose true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' menu select=2
zstyle ':completion:*' select-prompt '%S%F{186}Scrolling active: current selection at %p%f%s'
zstyle ':completion:*' list-prompt '%S%F{186}Scrolling active: current selection at %p (<s-tab> to go up)%s' # needed by zsh -<tab>
zstyle ':completion:*' list-colors 'ma=01;07;35' ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-separator '#' # --<tab> # description
zstyle ':completion:*' ignored-patterns '*(~|.swp|.o)'

# insert a tab vs displaying an overly long completion list when no characters on the left
zstyle ':completion:*' insert-tab true

# cd ~/my-dow<tab> -> cd ~/my_Downloads
# ll tar<tab> -> ll updates.tar.gz
# mv 01srt<tab> -> mv subtitles01_movieX.srt
zstyle ':completion:*' matcher-list '' \
                                    'm:{[:lower:][:upper:]-_}={[:upper:][:lower:]_-}' \
                                    '+l:|=* r:|=*' \
                                    'r:[[:ascii:]]||[[:ascii:]]=**'

zstyle -e ':completion:*:*:ssh:*' hosts 'reply=($(sed -n "/^\s*host\s\+[^*?]\+$/Is/\(host\)\?\s\+/\n/gIp" ~/.ssh/config | sort -u))'

# ls f/b/b<tab> results in fob/bar/bing/ fob/baz/bing/ foo/bar/bing/ ... vs (fob|foo)/b/b
zstyle ':completion:*' list-suffixes true

# Group matches in related categories
zstyle ':completion:*' group-name ''

zstyle ':completion:*' auto-description 'Help: %d'
zstyle ':completion:*:descriptions' format '%F{170}%d%f'
zstyle ':completion:*:warnings' format 'No matches for: %B%d%b'
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals*' ignored-patterns 'zshcompctl'

zstyle ':completion:*:processes' format '%BPID EUSER START CMD%b'
if ((EUID == 0))
then
   zstyle ':completion:*:processes' command 'command ps faxww o pid,euser,start_time,cmd'
else
   zstyle ':completion:*:processes' command 'command ps fxww o pid,euser,start_time,cmd'
fi

# =(#b)..(pattern1)..(pattern2)..=format0=format1=format2
#      ..(pattern1)..(pattern2).. must match the whole line
# format0 is for everything unmatched
zstyle ':completion:*:processes' list-colors '=(#b) #([0-9]##) ##[^ ]## ##([^ ]##)?##=0=32=34'
zstyle ':completion:*:processes' force-list always

compdef m=man

## (n)Vim and ed
if (( $+commands[nvim] ))
then
   alias v=nvim
else
   if [[ -n $REPOS_BASE ]]
   then
      alias v="vim -u $REPOS_BASE/vim/.vimrc"
   fi
fi

alias ed='ed -v -p:'

## global aliases
alias -g V='| v -'
alias -g P='| perl -00lnE "say;exit"'
alias -g J='| python -mjson.tool'

## ls and echo
if [[ $(uname) != OpenBSD ]]
then
   _ls_date_old="$(tput setaf 242 || tput AF 242)%e %b$_res"
   _ls_time_old="$(tput setaf 238 || tput AF 238) %Y$_res"

   _ls_date="$(tput setaf 242 || tput AF 242)%e %b$_res"
   _ls_time="$(tput setaf 238 || tput AF 238)%H:%M$_res"

   _ls_no_baks='-B'
   _ls_color='--color=auto'
   _time_style="--time-style=$'+$_ls_date_old $_ls_time_old\n$_ls_date $_ls_time'"
fi

# Make sure existing aliases won't prevent function definitions
unalias ln sl 2>/dev/null

alias  l.="ls -Fd   $_ls_color .*~.*~"
alias ll.="ls -Fdhl $_ls_color $_time_style .*~.*~"

alias  l="ls -F   $_ls_no_baks $_ls_color"
alias ll="ls -Fhl $_ls_no_baks $_ls_color $_time_style"

alias  la="ls -FA   $_ls_no_baks $_ls_color"
alias lla="ls -FAhl $_ls_no_baks $_ls_color $_time_style"

alias  ld="ls -Fd   $_ls_no_baks $_ls_color"
alias lld="ls -Fdhl $_ls_no_baks $_ls_color $_time_style"

alias  l/='ld *(/D)'
alias ll/='lld *(/D)'

alias  lx="ls -Fd   $_ls_color *~*~(*D)"
alias llx="ls -Fdhl $_ls_color $_time_style *~*~(*D)"

alias  lm="ls -Ftr   $_ls_no_baks $_ls_color"
alias llm="ls -Fhltr $_ls_no_baks $_ls_color $_time_style"

# Sort by size
alias  lk="ls -FS   $_ls_no_baks $_ls_color"
alias llk="ls -FShl $_ls_no_baks $_ls_color $_time_style"

# A single column
alias l1="ls -F1 $_ls_no_baks $_ls_color"

alias  lr="tree -FAC -I '*~|*.swp' --noreport"
alias llr="ls -FRhl $_ls_no_baks $_ls_color $_time_style"

alias vl="ls -F1 $_ls_no_baks V"

# Links (there is also ln() as an autoload)
alias ln.='ll .*(@)'
alias lnn='ll *(@D)'

alias e=echo

## sudo
alias  sd=sudo
alias sde=sudoedit

## cd
alias -- -='cd - >/dev/null'

alias 1='cd ..'
alias 2='cd ../..'
alias 3='cd ../../..'
alias 4='cd ../../../..'
alias 5='cd ../../../../..'
alias 6='cd ../../../../../..'
alias 7='cd ../../../../../../..'
alias 8='cd ../../../../../../../..'
alias 9='cd ../../../../../../../../..'

# Hook functions
if [[ -w $XDG_DATA_HOME/marks/marks.sqlite ]]
then
   chpwd_functions+=(update_marks)
   typeset -U chpwd_functions
fi

## File system operations
alias md='mkdir -p'
alias pw='pwd -P'

alias to=touch

## Safer cp/mv(autoload) + rm
# problem with cp/mv is I don't usually check the destination
alias cp='cp -i'
alias rm='rm -I'

## Permissions + debug
alias zx='zsh -xv'

alias    setuid='chmod u+s'
alias    setgid='chmod g+s'
alias setsticky='chmod  +t'

alias cg=chgrp
alias co=chown
alias cm=chmod

## Partitions
alias umn=umount
alias fu='sudo fuser -mv' # what uses the named files, sockets, or filesystems
alias df='df -hPT -x{dev,}tmpfs'

## Networking + firewall aliases
alias whois='whois -H'
alias myip='curl ipinfo.io/ip'
alias il='iptables -nvL --line-numbers'

## Head/Tail and cat
alias ha=$REPOS_BASE/scripts/headall.pl
alias tf='tail -f -n0'

if (( $+commands[bat] ))
then
   alias bat='bat --style snip --italic-text always --theme zenburn -mconf:ini'
fi
alias cn='cat -n'

## Help
alias mm='man -k'
alias mp="$REPOS_BASE/scripts/man.pl"
alias h="ex -d $REPOS_BASE/help"

unalias run-help 2>/dev/null
alias help="LESS='-XF $LESS' run-help"
autoload -Uz run-help

# print info about a command, alias, function...
alias '?=qmark'

## Find stuff and diffs
alias lo='locate -i'
alias ldapsearch='ldapsearch -x -LLL'

# Grep, ripgrep aliases
if (( $+commands[rg] ))
then
   alias rg='rg -S --hidden -g"!.git" -g"!.svn" -g"!.hg" --ignore-file ~/.gitignore'
   alias gr=rg
   alias g=rg
else
   alias gr='grep -IRiE --exclude-dir=.git --exclude-dir=.svn --exclude-dir=.hg --color=auto --exclude="*~" --exclude tags'
   alias g='grep -iE --color=auto --exclude="*~" --exclude tags'
fi

alias vd='v -d'
alias _=combine

## pacman
if (( $+commands[pacaur] ))
then
   alias pacs='pacaur -Ss'
   alias pacsync='pacaur -Syu'
else
   alias pacs=pacsearch
   alias pacsync='pacman -Syu'
fi

## Various applications aliases
if [[ $(uname) == Darwin ]]
then
   alias xclip=pbcopy
else
   alias open=xdg-open
fi
alias wgetpaste='wgetpaste -s dpaste -n kurkale6ka -Ct'
alias parallel='parallel --no-notice'
alias msg=dmesg
alias os='tail -n99 /etc/*(release|version) 2>/dev/null | cat -s'
alias password='apg -a1 -n1 -m11 -x11 -MSNCL'
alias ff='ffplay -v error -vf scale=220:-1'
alias rr=$REPOS_BASE/scripts/rrepl.pl
alias ssh=$REPOS_BASE/scripts/ssh.pl

## Git
alias ga='git add'
alias gb='git branch'
alias gc='git commit -v'
alias gd='git diff --word-diff=color'
alias gf='git fetch'
alias gl='git log --oneline --decorate'
alias gll='git log -U1 --word-diff=color' # -U1: 1 line of context (-p implied)
alias go='git checkout'
alias gp='git push origin HEAD'
alias gs='git status -sb'
alias gsa='mkconfig -s'

## tmux
alias tmux='tmux -2'
alias tl='tmux ls'
alias ta='tmux attach-session'

## fzf
[[ -f ~/.fzf.zsh ]] && . ~/.fzf.zsh

## Local zshrc file
[[ -r $XDG_CONFIG_HOME/zsh/.zshrc_after ]] && . $XDG_CONFIG_HOME/zsh/.zshrc_after

# vim: fdm=expr fde=getline(v\:lnum)=~'^\\s*##'?'>'.(len(matchstr(getline(v\:lnum),'###*'))-1)\:'='
