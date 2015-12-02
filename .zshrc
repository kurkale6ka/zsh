#! /usr/bin/env zsh
# Author: kurkale6ka <Dimitar Dimitrov>

setopt auto_pushd
setopt correct
setopt extended_glob
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt inc_append_history
setopt auto_name_dirs # shorter names in CWD without cd ~dir
setopt noclobber # prevent > from truncating an existing file
setopt interactivecomments

unsetopt flow_control # no ^s freezing the screen

HISTFILE=~/.zsh_history
HISTSIZE=7000
SAVEHIST=7000

## Paths
fpath=(~/.zsh/autoload ~/.zsh/autoload/*(/) $fpath)
autoload ~/.zsh/autoload/**/[^_]*(.:t)

if ((EUID == 0))
then
   path=(/root/bin /sbin /usr/sbin /usr/local/sbin $path)
   typeset -U path
fi

## Prompts
autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' formats 'λ-%b' # branch

precmd() {
   psvar[1]=$SSH_CONNECTION

   local vcs_info_msg_0_
   vcs_info
   psvar[2]=$vcs_info_msg_0_

   # Set the terminal title to [$PWD] host
   print -nP '\e]0;[%~] %m\a'
}

PROMPT=$'\n[%B%F{blue}%~%f%b] %2v\n%(!.%F{9}.%F{221})%n%f %# '
RPROMPT='%(1j.%F{9}%%%j%f ❬ .)%(1V.%F{140}.%F{221})%m%f %(?..%F{red})%T'

## Mac OS specific
if [[ $(uname) == Darwin ]]
then
   # Amend paths to get GNU commands vs the default BSD ones
   path=(/usr/local/bin $path)
   path=("$(brew --prefix coreutils)"/libexec/gnubin $path)

   manpath=("$(brew --prefix coreutils)"{/libexec/gnuman,/share/man} $manpath)
   for pkg in ed findutils ag ctags tree gnu-sed homebrew/dupes/grep vim
   do
      manpath=("$(brew --prefix $pkg)"/share/man $manpath)
   done

   typeset -U path manpath

   # BSD ps
   ppfields=pid,ppid,pgid,sess,tty,tpgid,stat,user,group,start,command
   pfields=pid,stat,user,group,start,command

   alias pg="command ps -o $pfields -h | head -1 && ps axww -o $pfields | grep -v grep | grep -iEB1 --color=auto"
   alias ppg="command ps -o $ppfields -h | head -1 && ps axww -o $ppfields | grep -v grep | grep -iEB1 --color=auto"
else
   # Linux ps
   ppfields=pid,ppid,pgid,sid,tname,tpgid,stat,euser,egroup,start_time,cmd
   pfields=pid,stat,euser,egroup,start_time,cmd

   alias pg="command ps o $pfields --headers | head -1 && ps faxww o $pfields | grep -v grep | grep -iEB1 --color=auto"
   alias ppg="command ps o $ppfields --headers | head -1 && ps faxww o $ppfields | grep -v grep | grep -iEB1 --color=auto"
fi

## Processes and jobs (see Mac section too ^)
alias k=kill
alias kg='kill -- -'

# jobs
alias z=fg
alias -- --='fg %-'

## Colors
[[ $TERM == xterm ]] && TERM='xterm-256color'

# These can't reside in .zprofile since there is no terminal for tput
     Bold="$(tput bold)"
Underline="$(tput smul)"
     Blue="$(tput setaf 4)"
   LGreen="$(printf %s $Bold; tput setaf 2)"
    LBlue="$(printf %s $Bold; tput setaf 4)"
    Reset="$(tput sgr0)"

# Viewing man pages with less
export LESS_TERMCAP_mb=$LGreen # blinking start
export LESS_TERMCAP_md=$LBlue  # bold     start
export LESS_TERMCAP_me=$Reset  #          end

# so -> stand out start
# se -> stand out end
export LESS_TERMCAP_so="$(printf %s $Bold; tput setaf 3; tput setab 4)"
export LESS_TERMCAP_se="$(tput rmso; printf %s $Reset)"

# us -> underline start
# ue -> underline end
export LESS_TERMCAP_us="$(printf %s%s $Bold$Underline; tput setaf 5)"
export LESS_TERMCAP_ue="$(tput rmul; printf %s $Reset)"

# Ls
[[ -r ~/.dir_colors ]] && eval "$(dircolors ~/.dir_colors)"

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

# pangoterm
bindkey -s '^[OM' '^M'
bindkey -s '^[[54;5u' '^^'

## zle snippets

zle_highlight=(region:none special:standout suffix:bold isearch:underline)

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
bindkey -s '^x[' '[[]]\e2^b'
bindkey -s '^x]' '[[]]\e2^b'

### ^xc Counting row occurrences in a stream
bindkey -s '^xc' ' | sort | uniq -c | sort -rn'

### ^xd Diff
bindkey -s '^xd' 'diff -uq^@ --from-file '

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
bindkey -s '^xn' 'echo -n "Newest: "; ld *(om[1]D)\eb^f'

bindkey -s '^xo' 'echo -n "Oldest: "; ld *(Om[1]D)\eb^f'

bindkey -s '^x*' 'inodes=(*(ND)); echo There are ${#inodes} inodes'

### ^xp printf
bindkey -s '^xp' "print -l "

### ^x` Backticks
bindkey -s '^x`' '$()^b'

### ^xs systemd
bindkey -s '^xs' 'systemctl status'

### ^xt tcpdump
bindkey -s '^xt' 'tcpdump -iany -s0 -nnq '

### ^xT Test
bindkey -s '^xT' ' && echo hmm'

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
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # cd ~/dow<tab> -> cd ~/Downloads
zstyle ':completion:*' insert-tab false

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
then nvim='nvim -u ~/.config/nvim/init.vim'
else nvim='vim -u ~/.vimrc'
fi

alias v=$nvim
alias vg="xclip <<< 'se nocp is hls ic scs inf nu sc report=0 dy+=lastline lz so=2 mouse=a nojs ai hid wmnu ls=2 bs=2 ve=all nosol | nn <c-l> :nohls<cr><c-l> | sy on | filet plugin indent on'"

alias -g L="| v -"
alias -g J="| python -mjson.tool"

alias ed='ed -v -p:'

## sudo
alias  sd=sudo
alias sde=sudoedit

## cd
alias -- -='cd - >/dev/null'

alias 1='cd ..'
alias 2='cd ../..'
alias 3='cd ../../..'
alias 4='cd ../../../..'

# Hook functions
chpwd_functions+=(update_marks)

## File system operations
alias md='mkdir -p --'
alias pw='pwd -P'

alias to=touch

# cp and rm aliases
alias y='cp -i --'
alias d='rm -i --preserve-root --'

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

## ls and echo
alias  l.='ls -Fd   --color=auto .*~.*~'
alias ll.='ls -Fdhl --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M" .*~.*~'

alias  l='ls -FB   --color=auto'
alias ll='ls -FBhl --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M"'

alias  la='ls -FBA   --color=auto'
alias lla='ls -FBAhl --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M"'

alias  ld='ls -FBd   --color=auto'
alias lld='ls -FBdhl --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M"'

alias  l/='ld *(/D)'
alias ll/='lld *(/D)'

alias  lx='ls -Fd   --color=auto *~*~(*D)'
alias llx='ls -Fdhl --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M" *~*~(*D)'

alias  lm='ls -FBtr   --color=auto'
alias llm='ls -FBhltr --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M"'

# Sort by size
alias  lk='ls -FBS   --color=auto'
alias llk='ls -FBShl --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M"'

# A single column
alias l1='ls -FB1 --color=auto'

alias lr="tree -FAC -I '*~|*.swp' --noreport"

alias vl='ls -FB1 L'

# Links (there is also ln() as an autoload)
alias ln.='ll .*(@)'
alias lnn='ll *(@D)'

alias e=echo

## Head/Tail and cat
alias h=head

alias t=tail
alias tf='tail -f -n0'

alias cn='cat -n --'

## Help
alias mm='man -k'

alias rg='cat ~/github/help/regex.txt' # Regex  help
alias pf='~/github/help/printf.sh'     # printf help

# print info about a command, alias, function...
alias '?=whence -ca --'

## Find stuff and diffs
alias lo='locate -i'
alias ldapsearch='ldapsearch -x -LLL'

# Grep or silver searcher aliases
if (( $+commands[ag] ))
then
   alias g='ag -S --hidden --color-line-number="00;32" --color-path="00;35" --color-match="01;31"'
   alias gr='ag -S --hidden --color-line-number="00;32" --color-path="00;35" --color-match="01;31"'
   alias ag='ag -S --hidden --color-line-number="00;32" --color-path="00;35" --color-match="01;31"'
else
   alias g='grep -iE --color=auto --exclude="*~" --exclude tags'
   alias gr='grep -IriE --color=auto --exclude="*~" --exclude tags'
fi

alias vd='v -d'
alias _=combine

## Various applications aliases
alias open=xdg-open
alias wgetpaste='wgetpaste -s dpaste -n kurkale6ka -Ct'
alias parallel='parallel --no-notice'
alias msg=dmesg
alias os='tail -n99 /etc/*(release|version) 2>/dev/null | cat -s'
alias password='apg -a1 -n1 -m11 -x11 -MSNCL'

## Git
alias gc='git commit -v'
alias gp='git push origin master'
alias gs='git status -sb'
alias go='git checkout'
alias gm='git checkout master'
alias ga='git add'
alias gb='git branch'
alias gd='git diff --word-diff=color'
alias gf='git fetch'
alias gl='git log --oneline --decorate'
alias gll='git log -U1 --word-diff=color' # -U1: 1 line of context (-p implied)

## tmux
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

## Business specific or system dependant stuff
[[ -r ~/.zshrc_after ]] && . ~/.zshrc_after

# vim: fdm=expr fde=getline(v\:lnum)=~'^\\s*##'?'>'.(len(matchstr(getline(v\:lnum),'###*'))-1)\:'='
