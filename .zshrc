#! /usr/bin/env zsh
# Author: kurkale6ka <Dimitar Dimitrov>

export HISTFILE=~/.zsh_history
export HISTSIZE=7000
export SAVEHIST=7000

## Colors
# These can't reside in .profile since there is no terminal for tput
     Bold="$(tput bold)"
Underline="$(tput smul)"
   Purple="$(tput setaf 5)"
    Green="$(tput setaf 2)"
     Blue="$(tput setaf 4)"
      Red="$(tput setaf 1)"
  LPurple="$(printf %s "$Bold"; tput setaf 5)"
   LGreen="$(printf %s "$Bold"; tput setaf 2)"
    LBlue="$(printf %s "$Bold"; tput setaf 4)"
     LRed="$(printf %s "$Bold"; tput setaf 1)"
    LCyan="$(printf %s "$Bold"; tput setaf 6)"
    Reset="$(tput sgr0)"

# Colored man pages
export LESS_TERMCAP_mb="$LGreen" # begin blinking
export LESS_TERMCAP_md="$LBlue"  # begin bold
export LESS_TERMCAP_me="$Reset"  # end mode

# so -> stand out - info box
export LESS_TERMCAP_so="$(printf %s "$Bold"; tput setaf 3; tput setab 4)"
# se -> stand out end
export LESS_TERMCAP_se="$(tput rmso; printf %s "$Reset")"

# us -> underline start
export LESS_TERMCAP_us="$(printf %s%s "$Bold$Underline"; tput setaf 5)"
# ue -> underline end
export LESS_TERMCAP_ue="$(tput rmul; printf %s "$Reset")"

[[ -r $HOME/.dir_colors ]] && eval "$(dircolors "$HOME"/.dir_colors)"

## Vim
if command -v nvim
then nvim=nvim
else nvim=vim
fi >/dev/null 2>&1

if command -v vimx; then
   my_gvim=vimx
elif command -v gvim; then
   my_gvim=gvim
fi >/dev/null 2>&1

alias  vim="command vim -u $HOME/.vimrc"
alias    v="command $nvim -u $HOME/.vimrc"
alias   vm="command $nvim -u $HOME/.vimrc -"
alias   vd="command $nvim -u $HOME/.vimrc -d"
alias   vt="command $nvim -u $HOME/.vimrc -t"
alias   vl="command ls -FB1 | $nvim -u $HOME/.vimrc -"
alias vish='sudo vipw -s'

alias ed='ed -v -p:'

vdr() {
   if (($# < 2)); then
      printf '%s\n' '  Usage: rvd {host} {file1 (local & remote)} [alt rfile]' \
                    "example: rvd qa1 ~/.bashrc '~/.bashrc'" >&2
      return 1
   fi
   command $nvim -u "$HOME"/.vimrc -d "$2" <(ssh "$1" cat "${3:-$2}")
}

if [[ $my_gvim ]]; then
   alias gvim="command $my_gvim -u $HOME/.vimrc -U $HOME/.gvimrc"
   alias   gv="command $my_gvim -u $HOME/.vimrc -U $HOME/.gvimrc"
   alias  gvd="command $my_gvim -u $HOME/.vimrc -U $HOME/.gvimrc -d"
fi

vn() {
   (($#)) && { command $nvim -NX -u NONE "$@"; return; }
   local opt opts
   local    nvm="$nvim"
   local    nvi="${Bold}$nvim$Reset"
   local    gvi="${Bold}gvim$Reset"
   local  vimrc="${LGreen}.vimrc$Reset"   _vimrc="$HOME"/.vimrc
   local gvimrc="${LGreen}.gvimrc$Reset" _gvimrc="$HOME"/.gvimrc
   local plugin="${LGreen}plugins$Reset"
    opts=("$nvi no .vimrc,           , no plugins ( \vim -nNX -u NONE                              )")
   opts+=("$nvm    $vimrc,           , no plugins ( \vim -nNX -u ~/.vimrc --noplugin               )")
   opts+=("$gvi no .vimrc, no .gvimrc, no plugins ( \gvim -nN -u NONE                              )")
   opts+=("gvim    $vimrc, no .gvimrc,    $plugin ( \gvim -nN -u ~/.vimrc -U NONE                  )")
   opts+=("gvim no .vimrc,    $gvimrc, no plugins ( \gvim -nN -u /dev/null -U ~/.gvimrc --noplugin )")
   opts+=("gvim    $vimrc, no .gvimrc, no plugins ( \gvim -nN -u ~/.vimrc -U NONE --noplugin       )")
   opts+=("gvim    $vimrc,    $gvimrc, no plugins ( \gvim -nN -u ~/.vimrc -U ~/.gvimrc --noplugin  )")
   select opt in "${opts[@]}"; do
      case "$opt" in
         "${opts[0]}") command     $nvim  -nNX -u NONE                              ; break;;
         "${opts[1]}") command     $nvim  -nNX -u "$_vimrc"               --noplugin; break;;
         "${opts[2]}") command "$my_gvim" -nN  -u NONE                              ; break;;
         "${opts[3]}") command "$my_gvim" -nN  -u "$_vimrc" -U NONE                 ; break;;
         "${opts[4]}") command "$my_gvim" -nN  -u /dev/null -U "$_gvimrc" --noplugin; break;;
         "${opts[5]}") command "$my_gvim" -nN  -u "$_vimrc" -U NONE       --noplugin; break;;
         "${opts[6]}") command "$my_gvim" -nN  -u "$_vimrc" -U "$_gvimrc" --noplugin; break;;
                    *) printf '\nInvalid choice!\n' >&2
      esac
   done
}

tags() { ctags --languages="$1"; }

## Arch Linux
# Search (or sync)
ps() {
   if (($#))
   then
      if [[ $1 == @(-|aux|fax|faux)* ]]
      then command ps "$@"
      else pacman -Ss "$@"
      fi
   else
      pacman -Syu
   fi
}

# Install
pi() {
   if [[ $1 == *.pkg.tar.xz ]]
   then pacman -U "$@"
   else pacman -S "$@"
   fi
}

# Update (or install)
pu() {
   if (($#))
   then pacman -U "$@"
   else pacman -Syu
   fi
}

# Update Neovim
nu () (
   cd /usr/local/src/neovim-git || exit 1
   if makepkg -s
   then
      shopt -s nullglob
      local latest file
      for file in *.pkg.tar.xz
      do
         [[ $file -nt $latest ]] && latest="$file"
      done
      sudo pacman -U "$latest"
   fi
)

## sudo and s()
if sudo -V |
   { read -r _ _ ver; ver="${ver%.*}"; ((${ver%.*} > 0 && ${ver#*.} > 6)); }
then alias sudo="sudo -p 'Password for %p: ' ";       sudo_version_ok=1
else alias sudo="sudo -p 'Password for %u: ' "; unset sudo_version_ok
fi

alias  sd=sudo
alias sde=sudoedit

# s///
# /etc/services lookup (ex: s ftp)
# sudo bash
s() {
   if (($# == 2)); then
      # s old new [number|cmd]
      fc -s "$1"="$2" "$3"
   elif (($# == 1)); then
      # s ftp|21
      if [[ $1 == [[:digit:]]* ]]
      then command grep -w -iE --color=auto -- "$1" /etc/services
      else command grep    -iE --color=auto -- "$1" /etc/services
      fi
   else
      history -a
      if [[ $sudo_version_ok ]]
      then sudo -E /usr/bin/zsh
      else sudo    /usr/bin/zsh
      fi
   fi
}

## Prompts
precmd() { psvar[3]="$SSH_CONNECTION" }

PS1=$'\n[%B%(!.%F{red}.%F{blue})%~%f%b]\n%F{yellow}%n %f%# '
RPS1='%(3V.%F{purple}.%F{yellow})%m%f %T'

## Directory functions and aliases: cd, md, rd, pw
# if [[ -r $HOME/github/bash/scripts/cd/cd.bash ]]
# then
#    . "$HOME"/github/bash/scripts/cd/cd.bash
#    cd_alias=c
# fi

alias  cd-="${cd_alias:-cd} - >/dev/null"
alias -- -="${cd_alias:-cd} - >/dev/null"
alias    1="${cd_alias:-cd} .."
alias    2="${cd_alias:-cd} ../.."
alias    3="${cd_alias:-cd} ../../.."
alias    4="${cd_alias:-cd} ../../../.."
alias cd..="${cd_alias:-cd} .."
alias   ..="${cd_alias:-cd} .."

alias to=touch
alias md='command mkdir -p --'

rd() {
   printf 'rd: remove directory ‘%s’?\n' "$@"
   read -p '(y/n) '
   [[ $REPLY == @(y|yes) ]] && command rm -r -- "$@"
}

pw() {
   if (($#))
   then pws --seconds 25 get "$1"
   else command pwd -P
   fi
}

## Networking: myip, dig, tunnel
alias myip='curl icanhazip.com'

dig() { command dig +noall +answer "${@#*//}"; }
dg() { dig -x $(dig +noall +answer +short "${@#*//}"); }

# Tunnel host's port to the local port
tunnel() {
   # Help
   if [[ $1 == -@(h|-h)* ]] || (($# == 0))
   then
      local info='Usage: tunnel {host} [{remote port: 80} {local port: 8080}]'
      if (($#))
      then echo "$info"    ; return 0
      else echo "$info" >&2; return 1
      fi
   fi

   if (($# == 1))
   then
      ssh -fNL "${3:-8080}":localhost:"${2:-80}" "$1" &&
      xdg-open http://localhost:"${3:-8080}" 2>/dev/null
   else
      ssh -fNL "${3:-$2}":localhost:"$2" "$1" &&
      xdg-open http://localhost:"${3:-$2}" 2>/dev/null
   fi
}

# Security
alias il='iptables -nvL --line-numbers'
alias nn=netstat

## Processes and jobs
# memory map
pm() {
   for i in "$@"; do
      printf '%s: ' "$i"; pmap -d "$(command pgrep "$i")" | tail -n1
   done | column -t | sort -k4
}

ppfields=pid,ppid,pgid,sid,tname,tpgid,stat,euser,egroup,start_time,cmd
pfields=pid,stat,euser,egroup,start_time,cmd

p() { if (($#)); then ping -c3 "$@"; else ps fww o "$ppfields" --headers; fi; }

alias pp="command ps faxww o $ppfields --headers"
alias pg="command ps o $pfields --headers | head -1 && ps faxww o $pfields | command grep -v grep | command grep -iEB1 --color=auto"
alias ppg="command ps o $ppfields --headers | head -1 && ps faxww o $ppfields | command grep -v grep | command grep -iEB1 --color=auto"
alias pgrep='pgrep -l'

alias  k=kill
alias kl='kill -l'
alias ka=killall
alias kg='kill -- -'
alias pk=pkill

# jobs
alias     j='jobs -l'
alias     z=fg
alias -- --='fg %-'

## Copy a user dir to a remote server using rsync
rs() {
   (($# == 3)) || { echo 'Usage: rs USER SERVER DIR' >&2; return 1; }
   [[ $1 == 'root' ]] && local home='' || local home=home/
   rsync -e "ssh -v -l $1" -v --recursive --links --stats --progress --exclude-from \
      "$HOME"/config/dotfiles/.rsync_exclude "${3%/}"/ "$2:/$home$1/${3%/}"
}

## Permissions + debug
x() {
   (($#)) && { chmod u+x -- "$@"; return; }

   if [[ $- == *x* ]]
   then echo 'debug OFF'; set +o xtrace
   else echo 'debug ON' ; set -o xtrace
   fi
} 2>/dev/null

alias bx='bash -x'

alias    setuid='chmod u+s'
alias    setgid='chmod g+s'
alias setsticky='chmod  +t'

alias cg=chgrp
alias co=chown
alias cm=chmod

## ls
ldot() {
   local ls
   if [[ ${FUNCNAME[1]} == 'l.' ]]
   then ls=(ls -FB   --color=auto)
   else ls=(ls -FBhl --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M")
   fi
   (($# == 0)) && {             "${ls[@]}" -d .[^.]* ; return; }
   (($# == 1)) && { (cd "$1" && "${ls[@]}" -d .[^.]*); return; }
   local i arg
   for arg in "$@"; do
      printf '%s:\n' "$arg"
      (cd -- "$arg" && "${ls[@]}" -d .[^.]*)
      (($# != ++i)) && echo
   done
}

.() {
   if (($#))
   then source "$@"
   else command ls -FB --color=auto -d .[^.]*
   fi
}

unalias l. ll. l ld la lr lk lx ll lld lla llr llk llx lm lc lu llm llc llu ln \
   2>/dev/null

 l.() { ldot "$@"; }
ll.() { ldot "$@"; }

alias   l='command ls -FB    --color=auto'
alias  ll='command ls -FBhl  --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M"'
alias  l1='command ls -FB1   --color=auto'

alias  la='command ls -FBA   --color=auto'
alias lla='command ls -FBAhl --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M"'

alias  ld='command ls -FBd   --color=auto'
alias lld='command ls -FBdhl --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M"'

alias  lk='command ls -FBS   --color=auto'
alias llk='command ls -FBShl --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M"'

alias  lr="tree -AC -I '*~' --noreport"
alias llr='command ls -FBRhl --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M"'

lm() {
   [[ -t 1 ]] && echo "$Purple${Underline}Sorted by modification date:$Reset"
   command ls -FBtr --color=auto "$@"
}

llm() {
   [[ -t 1 ]] && echo "$Purple${Underline}Sorted by modification date:$Reset"
   command ls -FBhltr --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M" "$@"
}

_lx() {
   local exes=()
   for x in *; do [[ -x $x ]] && exes+=("$x"); done
   if [[ ${FUNCNAME[1]} == 'lx' ]]; then
      command ls -FB   --color=auto                                    "${exes[@]}"
   else
      command ls -FBhl --color=auto --time-style="+${Blue}@$Reset %d-%b-%y %H:%M" "${exes[@]}"
   fi
}

 lx() { _lx "$@"; }
llx() { _lx "$@"; }

ln() {
   if (($#)); then
      command ln "$@"
   else
      ll .*(@)
      ll *(@)
   fi
}

sl() {
   printf '%-8s %-17s %-3s %-4s %-4s %-10s %-12s %-s\n'\
          'Inode' 'Permissions' 'ln' 'UID' 'GID' 'Size' 'Time' 'Name'
   local args=(); (($#)) && args=("$@") || args=(*)
   stat -c "%8i %A (%4a) %3h %4u %4g %10s (%10Y) %n" -- "${args[@]}"
}

## Help
m() {
   local choice
   (($#)) || {
      select choice in help man; do
         case "$choice" in
            help) help help; return;;
             man) man  man ; return;;
               *) echo '*** Wrong choice ***' >&2
         esac
      done
   }
   (($# >= 2)) && [[ -f $1 ]] && { command mv -i -- "$@"; return; }
   local topic arg
   for topic in "$@"; do
      ((arg++))
      [[ $topic == [1-8]* ]] && { man "$topic" -- "${@:$((arg+1))}"; return; }
      if [[ $(type -at -- $topic 2>/dev/null) == builtin*file ]]; then
         select choice in "help $topic" "man $topic"; do
            case "$choice" in
               help*) help -- "$topic"; break;;
                man*) man  -- "$topic"; break;;
                   *) echo '*** Wrong choice ***' >&2
            esac
         done
      else
         { help -- "$topic" || man -- "$topic" || type -a -- "$topic"; } 2>/dev/null
      fi
   done
}

alias mm='man -k'

mg() { man git-"${1:-help}"; }

# Search for help topics in my personal documentation
doc() {

   case "$1" in
      rg|regex)
         cat /home/mitko/github/help/it/regex.txt
         return ;;

      pf|printf)
         /home/mitko/github/help/it/printf.sh
         return ;;

      sort)
         cat /home/mitko/github/help/it/sort.txt
         return ;;
   esac

   local matches=()
   while read -r
   do
      matches+=("$REPLY")
   done < <(ag -lS --ignore '*install*' --ignore '*readme*' --ignore '*license*' "$1" "$HOME"/help/it)

   # For a single match, open the help file
   if (( ${#matches[@]} == 1 ))
   then
      command nvim -u "$HOME"/.vimrc "${matches[@]}" -c"0/$1" -c'noh|norm zv<cr>'
   elif (( ${#matches[@]} > 1 ))
   then
      ag -S --color-line-number="00;32" --color-path="00;35" --color-match="01;31" \
         "$1" "${matches[@]}"
   fi
}

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

## Display /etc/passwd, ..group and ..shadow with some formatting
db() {
   local options[0]='/etc/passwd'
         options[1]='/etc/group'
         options[2]='/etc/shadow'

   select choice in "${options[@]}"; do

      case "$choice" in

         "${options[0]}")
            header=LOGIN:PASSWORD:UID:GID:GECOS:HOME:SHELL
            sort -k7 -t: /etc/passwd | command sed -e "1i$header" -e 's/::/:-:/g' |\
               column -ts:
            break;;

         "${options[1]}")
            header=GROUP:PASSWORD:GID:USERS
            sort -k4 -t: /etc/group | command sed "1i$header" | column -ts:
            break;;

         "${options[2]}")
            header=LOGIN:PASSWORD:LAST:MIN:MAX:WARN:INACTIVITY:EXPIRATION:RESERVED
            sudo sort -k2 -t: /etc/shadow |\
               awk -F: '{print $1":"substr($2,1,3)":"$3":"$4":"$5":"$6":"$7":"$8":"$9}' |\
               command sed -e "1i$header" -e 's/::/:-:/g' | column -ts:
            break;;
      esac
      echo '*** Wrong choice ***'
   done
}

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
f() {
   if (($# == 1))
   then
      find . -iname "*$1*" -printf '%P\n'
   else
      find "$@"
   fi
}

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

diff() {
   if [[ -t 1 ]] && command -v colordiff >/dev/null 2>&1
   then         colordiff "$@"
   else command      diff "$@"
   fi
}

alias _=combine

## Convert to dec, bin, oct, hex
cv() {
   (($#)) || { echo 'Usage: cv digit ...' >&2; return 1; }
   cvs[0]='Decimal to binary'
   cvs[1]='Decimal to octal'
   cvs[2]='Decimal to hexadecimal'
   cvs[3]='Binary to decimal'
   cvs[4]='Octal to decimal'
   cvs[5]='Hexadecimal to decimal'
   local cv PS3='.? '
   select cv in "${cvs[@]}"; do
      case "$cv" in
         "${cvs[0]}")
            while read -r; do
               printf '%d -> %d\n' "$1" "$REPLY"; shift
            done < <(IFS=';'; command bc -q <<< "obase=2; $*") |\
            command sed '1iDec -> Bin' | column -t
            break;;
         "${cvs[1]}")
            while (($#)); do printf '%d -> %o\n' "$1" "$1"; shift; done |\
            command sed '1iDec -> Oct' | column -t
            break;;
         "${cvs[2]}")
            while (($#)); do printf '%d -> %x\n' "$1" "$1"; shift; done |\
            command sed '1iDec -> Hex' | column -t
            break;;
         "${cvs[3]}")
            while (($#)); do printf '%d -> %d\n' "$1" "$((2#$1))"; shift; done |\
            command sed '1iBin -> Dec' | column -t
            break;;
         "${cvs[4]}")
            while (($#)); do printf '%d -> %d\n' "$1" "$((8#$1))"; shift; done |\
            command sed '1iOct -> Dec' | column -t
            break;;
         "${cvs[5]}")
            while (($#)); do printf '%s -> %d\n' "$1" "$((16#$1))"; shift; done |\
            command sed '1iHex -> Dec' | column -t
            break;;
                   *) printf '\nInvalid choice!\n' >&2
      esac
   done
}

## Date and calendar
date() {
   if (($#))
   then command date "$@"
   else command date '+%A %d %B %Y, %H:%M %Z (%d/%m/%Y)'
   fi
}

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

alias  o='set -o'
alias oo=shopt

# Application aliases
alias open=xdg-open
alias weechat='TERM=xterm-256color weechat'
alias wgetpaste='wgetpaste -s dpaste -n kurkale6ka -Ct'
alias parallel='parallel --no-notice'
alias bc='bc -ql'

# More aliases
alias msg=dmesg
alias cmd=command
alias builtins='enable -a | cut -d" " -f2  | column'
alias hg='history | command grep -iE --color=auto'

alias pl=perl
alias py=python
alias rb=irb

# # rbenv: run multiple versions of ruby side-by-side
# command -v rbenv >/dev/null 2>&1 && eval "$(rbenv init -)"

# Helper for creating a minimal .inputrc file
rc() {
   local inputrc="printf '%s\n' "
         inputrc+="'\"\e[A\": history-search-backward' "
         inputrc+="'\"\e[B\": history-search-forward' >> $HOME/.inputrc"
   xclip -f <<< "$inputrc"
}

# Banners using figlet
bn() {
   if   (($# == 1)); then figlet -f smslant -- "$1"
   elif (($# == 2)); then figlet -f "$1"    -- "${@:2}"
   else                   figlist | column -c"$COLUMNS"
   fi
}

# Echo
e() { local status=$?; (($#)) && echo "$@" || echo "$status"; }

## Head/tail + cat-like functions
h() { if (($#)) || [[ ! -t 0 ]]; then head "$@"; else history; fi; }

alias t=tail
alias tf='tail -f -n0'

# Display the first 98 lines of all (or filtered) files in . Ex: catall .ba
catall() {
   (($#)) && local filter=(-iname "$1*")
   find . -maxdepth 1 "${filter[@]}" ! -name '*~' -type f -print0 |
   xargs -0 file | grep text | cut -d: -f1 | cut -c3- | xargs head -n98 |
   command $nvim -u "$HOME"/.vimrc -c "se fdl=0 fdm=expr fde=getline(v\:lnum)=~'==>'?'>1'\:'='" -
}

cn() { if [[ -t 1 ]]; then command cat -n -- "$@"; else command cat "$@"; fi; }

# Print nth line in a file: n 11 /my/file
n() { command sed -n "$1{p;q}" -- "$2"; }

# Display non-empty lines in a file
sq() { command grep -v '^[[:space:]]*#\|^[[:space:]]*$' -- "$@"; }

# Cleaner PATH display
pa() { awk '!_[$0]++' <<< "${PATH//:/$'\n'}"; }

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

gsa() (
   for repo in bash config help scripts vim
   do
      cd "$HOME"/github/"$repo" && {
         echo "$Bold=== $repo ===$Reset"
         if (($#)) # fetch if branch ahead of remote
         then
            git fetch
         else
            git -c color.ui=false status -sb | head -n1
            git status -s
         fi
         [[ $repo != vim ]] && echo
      }
   done
)

## GitHub: open the repo corresponding to the current pwd in a browser
gh() {
   if [[ $1 == -@(h|-h)* ]]
   then
      echo 'Usage: gh [origin|-b|-i|-p|-c]'; return 0
   fi

   local origin
   [[ $1 != -* ]] && origin="$1"
   local remote=remote."${origin:-origin}".url

   local giturl="$(git config --get "$remote")"
   [[ $giturl ]] || {
      echo "Not a git repository or no $remote set"
      return 1
   }

   local user_tmp="${giturl%/*}"
   local user_tmp="${user_tmp##*/}"
   local user="${user_tmp#*:}"
   local repo="${giturl##*/}"
   giturl=https://github.com/"$user"/"$repo"

   local branch="$(git symbolic-ref HEAD 2>/dev/null)"
   [[ $branch ]] && branch="${branch#refs/heads/}" || branch=master

   local path
   case "$1" in
      -b) path=branches;;
      -i) path=issues;;
      -p) path=pulls;;
      -c) path=commits/"$branch";;
       *) path=tree/"$branch";;
   esac
   giturl="${giturl%.git}"/"$path"

   xdg-open "$giturl" 2>/dev/null
}

## Google search: gg term
urlencode() {
   local char
   local str="$*"
   for ((i = 0; i < ${#str}; i++)); do
      char="${str:i:1}"
      case "$char" in
         [a-zA-Z0-9.~_-]) printf "$char" ;;
                     ' ') printf + ;;
                       *) printf '%%%X' "'$char"
      esac
   done
}

gg() {
   sudo -umitko xdg-open https://www.google.co.uk/search?q="$(urlencode "$@")" >/dev/null 2>&1
}

## Typos
alias cta=cat
alias ecex=exec
alias akw=awk
alias rmp=rpm
alias shh=ssh
alias xlcip=xclip

## Completion
setopt menucomplete

## tmux
alias tmux='tmux -2'
alias tm='tmux -2'
alias tl='tmux ls'
alias ta='tmux attach-session'
alias tn='tmux new -s'

## zle (~readline)

bindkey -e # emacs like line editing

autoload -U history-search-end

zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end

bindkey "\e[A" history-beginning-search-backward-end
bindkey "\e[B" history-beginning-search-forward-end

bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line

## Business specific or system dependant stuff
[[ -r $HOME/.zshrc_after ]] && . "$HOME"/.zshrc_after

# vim: fdm=expr fde=getline(v\:lnum)=~'^\\s*##'?'>'.(len(matchstr(getline(v\:lnum),'###*'))-1)\:'='
