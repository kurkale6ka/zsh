#! /usr/bin/env zsh
# Author: kurkale6ka <Dimitar Dimitrov>

setopt extended_glob
setopt auto_pushd

setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt inc_append_history

HISTFILE=~/.zsh_history
HISTSIZE=7000
SAVEHIST=7000

fpath=(~/.zsh/autoload ~/.zsh/autoload/* $fpath)
autoload ~/.zsh/autoload/**/*(.:t)

## Colors
# These can't reside in .profile since there is no terminal for tput
     Bold="$(tput bold)"
Underline="$(tput smul)"
   Purple="$(tput setaf 5)"
    Green="$(tput setaf 2)"
     Blue="$(tput setaf 4)"
      Red="$(tput setaf 1)"
  LPurple="$(printf %s $Bold; tput setaf 5)"
   LGreen="$(printf %s $Bold; tput setaf 2)"
    LBlue="$(printf %s $Bold; tput setaf 4)"
     LRed="$(printf %s $Bold; tput setaf 1)"
    LCyan="$(printf %s $Bold; tput setaf 6)"
    Reset="$(tput sgr0)"

# Colored man pages
export LESS_TERMCAP_mb=$LGreen # begin blinking
export LESS_TERMCAP_md=$LBlue  # begin bold
export LESS_TERMCAP_me=$Reset  # end mode

# so -> stand out - info box
export LESS_TERMCAP_so="$(printf %s $Bold; tput setaf 3; tput setab 4)"
# se -> stand out end
export LESS_TERMCAP_se="$(tput rmso; printf %s $Reset)"

# us -> underline start
export LESS_TERMCAP_us="$(printf %s%s $Bold$Underline; tput setaf 5)"
# ue -> underline end
export LESS_TERMCAP_ue="$(tput rmul; printf %s $Reset)"

[[ -r ~/.dir_colors ]] && eval "$(dircolors ~/.dir_colors)"

## Vim
if command -v nvim >/dev/null 2>&1
then nvim='nvim -u ~/.vimrc'
else nvim='vim -u ~/.vimrc'
fi

alias v=$nvim
alias vd="$nvim -d"
alias vt="$nvim -t"

alias -g L="| $nvim -"
alias vl="ls -FB1 L"

alias ed='ed -v -p:'

## sudo
alias  sd=sudo
alias sde=sudoedit

## Prompts
autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' formats 'λ %b' # branch

precmd() {
   psvar[3]=$SSH_CONNECTION

   local vcs_info_msg_0_
   vcs_info
   psvar[4]=$vcs_info_msg_0_
}

PROMPT=$'\n[%B%(!.%F{red}.%F{blue})%~%f%b] %4v\n%F{yellow}%n %f%# '
RPROMPT='%(1j.%F{red}%%%j%f ❬ .)%(3V.%F{purple}.%F{yellow})%(?..%F{red})%m%f %T'

## Directory functions and aliases: cd, md, rd, pw
alias  cd-='cd - >/dev/null'
alias -- -='cd - >/dev/null'
alias    1='cd ..'
alias    2='cd ../..'
alias    3='cd ../../..'
alias    4='cd ../../../..'
alias cd..='cd ..'
alias   ..='cd ..'

. /etc/profile.d/autojump.zsh
alias c=j

alias to=touch
alias md='command mkdir -p --'
alias pw='pwd -P'

## Networking: myip, iptables, netstat
alias myip='curl icanhazip.com'

# Security
alias il='iptables -nvL --line-numbers'
alias nn=netstat

## Processes and jobs
ppfields=pid,ppid,pgid,sid,tname,tpgid,stat,euser,egroup,start_time,cmd
pfields=pid,stat,euser,egroup,start_time,cmd

alias pp="command ps faxww o $ppfields --headers"
alias pg="command ps o $pfields --headers | head -1 && ps faxww o $pfields | command grep -v grep | command grep -iEB1 --color=auto"
alias ppg="command ps o $ppfields --headers | head -1 && ps faxww o $ppfields | command grep -v grep | command grep -iEB1 --color=auto"

alias k=kill
alias pk='pkill -f'
alias kg='kill -- -'

# jobs
alias z=fg
alias -- --='fg %-'

## Permissions + debug
alias zx='zsh -xv'

alias    setuid='chmod u+s'
alias    setgid='chmod g+s'
alias setsticky='chmod  +t'

alias cg=chgrp
alias co=chown
alias cm=chmod

## ls
alias  l.='ls -Fd   --color=auto .*~.*~'
alias ll.='ls -Fdhl --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M" .*~.*~'

alias  l='ls -FB   --color=auto'
alias ll='ls -FBhl --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M"'

alias  la='ls -FBA   --color=auto'
alias lla='ls -FBAhl --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M"'

alias  ld='ls -FBd   --color=auto'
alias lld='ls -FBdhl --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M"'

alias  l/='ld (.*|*)(/)'
alias ll/='lld (.*|*)(/)'

alias  lx='ls -Fd   --color=auto (.*~.*~|*~*~)(*)'
alias llx='ls -Fdhl --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M" (.*~.*~|*~*~)(*)'

alias  lm='ls -FBtr   --color=auto'
alias llm='ls -FBhltr --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M"'

# Sort by size
alias  lk='ls -FBS   --color=auto'
alias llk='ls -FBShl --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M"'

# A single column
alias l1='ls -FB1 --color=auto'

alias lr="tree -AC -I '*~' --noreport"

ln() {
   if (($#))
   then command ln $@
   else ll (.*|*)(@)
   fi
}

## Help
alias mm='man -k'

alias rg="cat $HOME/github/help/it/regex.txt" # Regex  help
alias pf="$HOME/github/help/it/printf.sh"     # printf help

# which-like function
_type() {
   (($#)) || { type -a -- "$FUNCNAME"; return; }

   echo "${Bold}type -a (exe, alias, builtin, func):$Reset"
   type -a -- "$@" 2>/dev/null
   echo

   echo "${Bold}whereis -b (bin):$Reset"
   whereis -b "$@"
   echo

   echo "${Bold}file -L (deref):$Reset"
   local f
   for f in "$@"
   do
      file -L "$(type -P -- "$f")"
   done
}

alias '?=_type'

## rm and cp like functions and aliases
# Delete based on inodes (use ls -li first)
di() {
   (($#)) || return 1
   local inode inodes=()
   # skip the last inode
   for inode in "${@:1:$#-1}"; do
      inodes+=(-inum "$inode" -o)
   done
   # last inode
   inodes+=(-inum "${@:$#}")
   # -inum 38 -o -inum 73
   find . \( "${inodes[@]}" \) -exec rm -i -- {} +
}

alias y='cp -i --'
alias d='rm -i --preserve-root --'

## Find stuff and diffs
alias lo='command locate -i'
alias ldapsearch='ldapsearch -x -LLL'

# Grep or silver searcher aliases
if command -v ag >/dev/null 2>&1; then
   alias g='ag -S --color-line-number="00;32" --color-path="00;35" --color-match="01;31"'
   alias gr='ag -S --color-line-number="00;32" --color-path="00;35" --color-match="01;31"'
   alias ag='ag -S --color-line-number="00;32" --color-path="00;35" --color-match="01;31"'
else
   alias g='command grep -niE --color=auto --exclude="*~" --exclude tags'
   alias gr='command grep -nIriE --color=auto --exclude="*~" --exclude tags'
fi

alias _=combine

## Calendar
if command -v ncal >/dev/null 2>&1; then
   alias  cal='env LC_TIME=bg_BG.utf8 ncal -3 -M -C'
   alias call='env LC_TIME=bg_BG.utf8 ncal -y -M -C'
else
   alias  cal='env LC_TIME=bg_BG.utf8 cal -m3'
   alias call='env LC_TIME=bg_BG.utf8 cal -my'
fi

## uname + os
u() {
   uname -r
   echo "$(uname -mpi) (machine, proc, platform)"
}

alias os='tail -n99 /etc/*{release,version} 2>/dev/null | cat -s'

## Backup functions and aliases
b() {
   (($#)) || { echo 'Usage: bak {file} ...' 1>&2; return 1; }
   local arg
   for arg in "$@"
   do
      command cp -i -- "$arg" "$arg".bak
   done
}

# Usage: sw file [file.bak]. file.bak is assumed by default so it can be omitted
bs() {
   if [[ $1 == -@(h|-h)* ]] || (($# != 1 && $# != 2)); then
      info='Usage: sw file [file.bak]'
      if (($#))
      then echo "$info"    ; return 0
      else echo "$info" >&2; return 1
      fi
   fi
   file1="$1"
   if (($# == 1))
   then file2="$1".bak
   else file2="$2"
   fi
   if [[ -e $file1 && -e $file2 ]]
   then
      local tmpfile=$(mktemp)
      if [[ $tmpfile ]]
      then
         'mv' -- "$file1"   "$tmpfile" &&
         'mv' -- "$file2"   "$file1"   &&
         'mv' -- "$tmpfile" "$file2"
      fi
   else
      head -n2 "$file1" "$file2" # to get an error message
   fi
}

br() {
   if (($#))
   then
      find . \( -name '*~' -o -name '.*~' \) -a ! -name '*.un~' -delete
   else
      find . \( -name '*~' -o -name '.*~' \) -a ! -name '*.un~' -printf '%P\n'
   fi
}

alias dump='dump -u'

## Disk: df, du, hdparm, mount
df() { command df -hT "$@" | sort -k6r; }

duu() {
   local args=()
   (($#)) && args=("$@") || args=(*)
   du -xsk -- "${args[@]}" | sort -n | while read -r size f
   do
      for u in K M G T P E Z Y
      do
         if ((size < 1024))
         then
            case "$u" in
               K) unit="${Green}$u${Reset}";;
               M) unit="${Blue}$u${Reset}";;
               G) unit="${Red}$u${Reset}";;
               *) unit="${LRed}$u${Reset}"
            esac
            if [[ -h $f ]]; then
               file="${LCyan}$f${Reset}"
            elif [[ -d $f ]]; then
               file="${LBlue}$f${Reset}"
            else
               file="$f"
            fi
            printf '%5d%s\t%s\n' "$size" "$unit" "$file"
            break
         fi
         ((size = size / 1024))
      done
   done
}

hd() { if ((1 == $#)); then hdparm -I -- "$1"; else hdparm "$@"; fi; }

mn() {
   if (($#))
   then command mount "$@"
   else command mount | cut -d" " -f1,3,5,6 | column -t
   fi
}

alias umn=umount
alias fu='sudo fuser -mv'

## Misc: options, app aliases, rc(), b(), e()
# Options
alias  a=alias
alias ua=unalias

# Application aliases
alias open=xdg-open
alias weechat='TERM=xterm-256color weechat'
alias wgetpaste='wgetpaste -s dpaste -n kurkale6ka -Ct'
alias parallel='parallel --no-notice'
alias bc='bc -ql'

# More aliases
alias msg=dmesg
alias cmd=command
alias hg='history | command grep -iE --color=auto'

alias pl=perl
alias py=python
alias rb=irb

# # rbenv: run multiple versions of ruby side-by-side
# command -v rbenv >/dev/null 2>&1 && eval "$(rbenv init -)"

# Banners using figlet
bn() {
   if   (($# == 1)); then figlet -f smslant -- "$1"
   elif (($# == 2)); then figlet -f "$1"    -- "${@:2}"
   else                   figlist | column -c"$COLUMNS"
   fi
}

## Head/tail + cat-like functions
h() { if (($#)) || [[ ! -t 0 ]]; then head "$@"; else history; fi; }

alias t=tail
alias tf='tail -f -n0'

alias cn='cat -n --'

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

## Typos
alias cta=cat
alias ecex=exec
alias akw=awk
alias rmp=rpm
alias shh=ssh
alias xlcip=xclip

## Completion
setopt menu_complete # select the first item straight away

zmodload zsh/complist
bindkey -M menuselect '^M' .accept-line

compaudit() : # disable the annoying 'zsh compinit: insecure directories...'
autoload -Uz compinit && compinit

zstyle ':completion:*' menu select=2
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' # cd ~/dow<tab> -> cd ~/Downloads

# extensions ignored in <tab> completion
zstyle ':completion:*' ignored-patterns '*~'

compdef m=man

## tmux
alias tmux='tmux -2'
alias tm='tmux -2'
alias tl='tmux ls'
alias ta='tmux attach-session'
alias tn='tmux new -s'

## zle (~readline)

bindkey -e # emacs like line editing

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

[[ ${key[Insert]}   ]] && bindkey ${key[Insert]}   overwrite-mode
[[ ${key[Delete]}   ]] && bindkey ${key[Delete]}   delete-char
[[ ${key[Home]}     ]] && bindkey ${key[Home]}     beginning-of-line
[[ ${key[End]}      ]] && bindkey ${key[End]}      end-of-line
[[ ${key[PageUp]}   ]] && bindkey ${key[PageUp]}   beginning-of-buffer-or-history
[[ ${key[PageDown]} ]] && bindkey ${key[PageDown]} end-of-buffer-or-history

autoload -U history-search-end

zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

[[ ${key[Up]}    ]] && bindkey ${key[Up]}    history-beginning-search-backward-end
[[ ${key[Down]}  ]] && bindkey ${key[Down]}  history-beginning-search-forward-end
[[ ${key[Left]}  ]] && bindkey ${key[Left]}  backward-char
[[ ${key[Right]} ]] && bindkey ${key[Right]} forward-char

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

## zle snippets

### ^x[ Array
bindkey -s '^x[' '${[@]}\e4^b'

### ^x= bc
bindkey -s '^x=' "command bc <<< 'scale=20; '^b"

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
bindkey -s '^x]' '[[]]\e2^b'

### ^xc Counting row occurrences in a stream
bindkey -s '^xc' ' | sort | uniq -c | sort -rn'

### ^xd Diff
bindkey -s '^xd' 'diff -uq^@ --from-file '

### ^xe ed
bindkey -s '^xe' "printf '%s\\\n' H ^@ wq | 'ed' -s "
bindkey -s '^xE' "printf '%s\\\n' H 0i ^@ . wq | 'ed' -s "

### ^xf Loops
bindkey -s '^xf' 'for i in ^@; do  $i; done\e2\eb^b'
bindkey -s '^xF' 'for ((i = 0; i < ^@; i++)); do  $i; done\e2\eb^b'
bindkey -s '^xu' 'until ^@; do ; done\eb\e2^b'
bindkey -s '^xw' 'while ^@; do ; done\eb\e2^b'

### ^xg groff
bindkey -s '^xg' ' | groff -man -Tascii | less^m'

### ^xm File renaming (mv)
bindkey -s '^xm' "find . -maxdepth 1 -iname '*^@' ! -path . -printf \"mv '%P' '%P'\\\n\" | v -c\"Ta/'.\\\{-}'/l1l0\" -c'se ft=sh' -^x^x"
bindkey -s '^xM' 'parallel mv -- {} {.}.^@ ::: *.'

### ^xn Directory statistics
bindkey -s '^xn' 'ls -d (.*|*)(om[1])\eb^f^f'
bindkey -s '^xo' '(setopt nullglob; unset oldest; for file in *^@; do [[ $file -ot $oldest || ! $oldest ]] && oldest=$file; done; echo $oldest)^x^x'
bindkey -s '^x*' '(setopt nullglob dotglob; inodes=(*[\^\~]); echo There are ${#inodes[@]} inodes)'

### ^xp printf
bindkey -s '^xp' "printf '%s\\\n' "

### ^x` Backticks
bindkey -s '^x`' '$()^b'

### ^xs systemd
bindkey -s '^xs' 'systemctl status'

### ^xt tcpdump
bindkey -s '^xt' 'tcpdump -iany -s0 -nnq '

### ^xT Test
bindkey -s '^xT' ' && echo hmm'

## Business specific or system dependant stuff
[[ -r $HOME/.zshrc_after ]] && . "$HOME"/.zshrc_after

# vim: fdm=expr fde=getline(v\:lnum)=~'^\\s*##'?'>'.(len(matchstr(getline(v\:lnum),'###*'))-1)\:'='
