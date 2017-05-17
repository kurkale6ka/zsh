setopt auto_pushd
setopt correct
setopt extended_glob
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt inc_append_history
setopt interactivecomments

unsetopt auto_name_dirs # shorter names in CWD
unsetopt flow_control # no ^s freezing the screen
unsetopt case_glob

HISTFILE=$XDG_DATA_HOME/zsh/history
HISTSIZE=11000
SAVEHIST=11000

alias zn='zsh -f'

## Paths
if [[ -d $XDG_CONFIG_HOME/zsh ]]
then
   fpath=($XDG_CONFIG_HOME/zsh/{autoload,after} $XDG_CONFIG_HOME/zsh/{autoload,after}/*(N/) $fpath)
   autoload $XDG_CONFIG_HOME/zsh/{autoload,after}/**/[^_]*(N.:t)
fi

if ((EUID == 0))
then
   path=(/root/bin /sbin /usr/sbin /usr/local/sbin $path)
   typeset -U path
fi

## Prompts
autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' formats '%b' # branch

precmd() {
   local vcs_info_msg_0_
   vcs_info
   psvar[2]=$vcs_info_msg_0_

   # Set the terminal title to [$PWD] host
   print -nP '\e]0;[%~] %m\a'
}

psvar[1]=1
if [[ -z $SSH_CONNECTION ]]
then
   if ! who | 'grep' -v tmux | 'grep' -v ':S\.[0-9][0-9]*)' | 'grep' -q '(.*)'
   then
      psvar[1]=
   fi
fi

if [[ $TERM != *linux* ]]
then
   PROMPT=$'\n[%B%F{blue}%~%f%b] %(2V.%F{238}λ-%f.)%2v\n%(!.%F{9}.%F{221})%n%f %# '
   RPROMPT='%(1j.%F{9}%%%j%f ❬ .)%(1V.%F{140}.%F{221})%m%f %(?..%F{red})%T'
else
   PROMPT=$'\n[%B%F{blue}%~%f%b] %2v\n%(!.%F{red}.%F{yellow})%n%f %# '
   RPROMPT='%(1j.%F{red}%%%j%f ❬ .)%(1V.%F{magenta}.%F{yellow})%m%f %(?..%F{red})%T'
fi

## Mac OS specific
if [[ $(uname) == Darwin ]]
then
   # Amend paths to get GNU commands vs the default BSD ones
   brew_prefix="$(brew --prefix coreutils)"

   path=(/usr/local/bin              $path)
   path=($brew_prefix/libexec/gnubin $path)

   MANPATH=$brew_prefix/libexec/gnuman:"$(man -w)"

   typeset -U path manpath
   export MANPATH

   alias xclip=pbcopy
fi

## Processes and jobs (see Mac section too ^)
alias k=kill
alias kg='kill -- -'

# jobs
alias z=fg
alias -- --='fg %-'

## Colors
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
autoload -U history-search-end

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
bindkey -s '^x/' "find . -iname '*^@' -printf '%M %u %g %P\\\n'^x^x"

### ^x\ GNU parallel
bindkey -s '^x\\' " | parallel -X ^@ {} ^x^x"

### ^x0 IPs
bindkey -s '^x0' '127.0.0.1'
bindkey -s '^x1' '10.0.0.'
bindkey -s '^x7' '172.16.0.'
bindkey -s '^x9' '192.168.0.'

### ^x- Ranges
bindkey -s '^x-' '{1\e ..}^b'
bindkey -s '^x.' '{1\e ..}^b'

### ^x| Output in columns
bindkey -s '^x|' ' | column -t'

### ^x_ /dev/null
bindkey -s '^x_' '/dev/null'

### ^xa awk
bindkey -s '^xa' "awk '/^@/ {print $}' \e3^b"
bindkey -s '^xA' "awk '{sum += $1} END {print sum}' "

### ^xb Braces
bindkey -s '^xb' '(())\e2^b'
bindkey -s '^xB' '{}^b'
bindkey -s '^x[' '[[  ]]\e3^b'
bindkey -s '^x]' '[[  ]]\e3^b'

### ^xc Counting row occurrences in a stream
bindkey -s '^xc' ' | sort | uniq -c | sort -rn'

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

### ^xm File renaming (mv)
bindkey -s '^xm' "find . -maxdepth 1 -iname '*^@' ! -path . -printf \"mv '%P' '%P'\\\n\" | v -c\"Tabularize/'.\\\{-}'/l1l0\" -c'se ft=sh' -^x^x"
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
bindkey -s '^xr' "rsync -ai^@ -e'ssh -q' "
bindkey -s '^xR' "-f'- '^b"

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

compaudit() : # disable the annoying 'zsh compinit: insecure directories...'
autoload -Uz compinit && compinit

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

zstyle -e ':completion:*' hosts 'reply=($(nodeset -ea 2>/dev/null))'
zstyle -e ':completion:*:cssh:*' hosts "reply=($(awk '/^[^#]/ {print $1}' ~/.clusterssh/clusters 2>/dev/null))"

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
compdef v=vim nvim=vim

## (n)Vim and ed
if (( $+commands[nvim] ))
then
   alias v=nvim
else
   [[ -n $REPOS_BASE ]] && alias v="vim -u $REPOS_BASE/vim/.vimrc"
fi

alias vg="xclip <<< 'se nocp is hls ic scs inf nu sc report=0 dy+=lastline lz so=2 mouse=a nojs ai hid wmnu ls=2 bs=2 ve=all nosol | nn <c-l> :nohls<cr><c-l> | sy on | filet plugin indent on'"

alias -g V='| v -'
alias -g J='| python -mjson.tool'

alias ed='ed -v -p:'

## ls and echo
_ls_date_old="$(tput setaf 4   || tput AF 4  )%e %b$_res"
_ls_time_old="$(tput setaf 238 || tput AF 238) %Y$_res"

_ls_date="$(tput setaf 4   || tput AF 4  )%e %b$_res"
_ls_time="$(tput setaf 238 || tput AF 238)%H:%M$_res"

# Make sure existing aliases won't prevent function definitions
unalias ln sl 2>/dev/null

alias  l.='ls -Fd   --color=auto .*~.*~'
alias ll.="ls -Fdhl --color=auto --time-style=$'+$_ls_date_old $_ls_time_old\n$_ls_date $_ls_time' .*~.*~"

alias  l='ls -FB   --color=auto'
alias ll="ls -FBhl --color=auto --time-style=$'+$_ls_date_old $_ls_time_old\n$_ls_date $_ls_time'"

alias  la='ls -FBA   --color=auto'
alias lla="ls -FBAhl --color=auto --time-style=$'+$_ls_date_old $_ls_time_old\n$_ls_date $_ls_time'"

alias  ld='ls -FBd   --color=auto'
alias lld="ls -FBdhl --color=auto --time-style=$'+$_ls_date_old $_ls_time_old\n$_ls_date $_ls_time'"

alias  l/='ld *(/D)'
alias ll/='lld *(/D)'

alias  lx='ls -Fd   --color=auto *~*~(*D)'
alias llx="ls -Fdhl --color=auto --time-style=$'+$_ls_date_old $_ls_time_old\n$_ls_date $_ls_time' *~*~(*D)"

alias  lm='ls -FBtr   --color=auto'
alias llm="ls -FBhltr --color=auto --time-style=$'+$_ls_date_old $_ls_time_old\n$_ls_date $_ls_time'"

# Sort by size
alias  lk='ls -FBS   --color=auto'
alias llk="ls -FBShl --color=auto --time-style=$'+$_ls_date_old $_ls_time_old\n$_ls_date $_ls_time'"

# A single column
alias l1='ls -FB1 --color=auto'

alias  lr="tree -FAC -I '*~|*.swp' --noreport"
alias llr='ll **/*(-.,%,=ND)'

alias vl='ls -FB1 V'

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

## Safer cp/mv + rm
# problem with these is I don't usually check the destination
alias cp='cp -i'
alias mv='mv -i'

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

## Networking + firewall aliases
alias myip='curl icanhazip.com'

alias il='iptables -nvL --line-numbers'

reg() { whois -H $1 | egrep -A1 -i registrar:; }

## Head/Tail and cat
alias h=head

alias t=tail
alias tf='tail -f -n0'

alias cn='cat -n'

## Help
alias mm='man -k'

if [[ -n $REPOS_BASE ]]
then
   alias rg="cat $REPOS_BASE/help/regex.txt" # Regex  help
   alias pf=$REPOS_BASE'/help/printf.sh'     # printf help
fi

# print info about a command, alias, function...
alias '?=whence -ca'

## Find stuff and diffs
alias lo='locate -i'
alias ldapsearch='ldapsearch -x -LLL'

# Grep or silver searcher aliases
if (( $+commands[ag] ))
then
   alias ag='ag -S --hidden --ignore=.git --ignore=.svn --ignore=.hg --color-line-number="00;32" --color-path="00;35" --color-match="01;31"'
   alias gr=ag
   alias g=ag
else
   alias g='grep -iE --color=auto --exclude="*~" --exclude tags'
   alias gr='grep -IriE --exclude-dir=.git --exclude-dir=.svn --exclude-dir=.hg --color=auto --exclude="*~" --exclude tags'
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
[[ $(uname) != Darwin ]] && alias open=xdg-open
alias wgetpaste='wgetpaste -s dpaste -n kurkale6ka -Ct'
alias parallel='parallel --no-notice'
alias msg=dmesg
alias os='tail -n99 /etc/*(release|version) 2>/dev/null | cat -s'
alias password='apg -a1 -n1 -m11 -x11 -MSNCL'
alias ff='ffplay -v error -vf scale=220:-1'

## Git
alias gp='git push origin master'
alias gm='git checkout master'
alias ga='git add'
alias gb='git branch'
alias gf='git fetch'
alias gl='git log --oneline --decorate'
alias gll='git log -U1 --word-diff=color' # -U1: 1 line of context (-p implied)

## tmux
alias tmux='tmux -2'
alias tl='tmux ls'
alias ta='tmux attach-session'

## Calendar
if (( $+commands[ncal] ))
then
   alias  cal='env LC_TIME=bg_BG.utf8 ncal -3 -M -C'
   alias call='env LC_TIME=bg_BG.utf8 ncal -y -M -C'
else
   alias  cal='env LC_TIME=bg_BG.utf8 cal -m3'
   alias call='env LC_TIME=bg_BG.utf8 cal -my'
fi

## fzf
[[ -f ~/.fzf.zsh ]] && . ~/.fzf.zsh

## Local zshrc file
[[ -r $XDG_CONFIG_HOME/zsh/.zshrc_after ]] && . $XDG_CONFIG_HOME/zsh/.zshrc_after

# vim: fdm=expr fde=getline(v\:lnum)=~'^\\s*##'?'>'.(len(matchstr(getline(v\:lnum),'###*'))-1)\:'='
