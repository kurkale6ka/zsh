setopt auto_pushd
setopt pushd_minus
setopt correct
setopt extended_glob
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt inc_append_history
setopt interactivecomments
setopt list_rows_first
setopt prompt_subst # do expansions $..., $(...) ``, $((...)) before any substitutions %~, %#, %F{}...%f

unsetopt auto_name_dirs # shorter names in CWD
unsetopt case_glob
unsetopt complete_aliases
unsetopt clobber
unsetopt flow_control # no ^s freezing the screen

umask 022 # remove w permissions for group and others

alias history='history -t "%d/%b/%H:%M"'
alias hg='\history 1 | sed "s/^ [0-9]\+  //" | g'

alias zn='zsh -f'

# autoloading functions
autoload -z $XDG_CONFIG_HOME/zsh/{autoload,local}/**/*~*~(N.:t)

## Prompts
psvar[1]=1
if [[ -z $SSH_CONNECTION ]]
then
    if ! who | 'grep' -q '([0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\})'
    then
        psvar[1]=
    fi
fi

precmd() {
    # Set the terminal title to [$PWD] host
    print -nP '\e]0;[%~] %M\a'
}

# %F{color}...%f
# %~: cwd, %2v: psvar[2], %m: hostname, %n: username %#: % or #
# %(x/true/false), !: root, ?(0): $? == 0, j1: jobs >= 1, 2V: psvar[2] != empty
if [[ $TERM != *linux* ]]
then
    eval "$(starship init zsh)"
    RPROMPT='$(date +"%d %b %H:%M")'
else
    PROMPT=$'\n[%B%F{blue}%~%f%b]\n%(1V.%F{magenta}.%F{yellow})%m%f %(!.%F{red}%#%f.%#) '
    RPROMPT='%(1j.%F{red}%%%j%f ❬ .)%(!.%F{red}.%F{yellow})%n%f %(?/%T/%F{red}%T%f)'
fi

## Processes and jobs (see Mac section too ^)
alias pg=$REPOS_BASE/github/scripts/pg.pl

alias k=kill
alias kg='kill -- -'

# jobs
alias z=fg
alias -- --='fg %-'

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
[[ -n ${key[PageDown]} ]] && bindkey ${key[PageDown]} end-of-buffer-or-history
[[ -n ${key[PageUp]}   ]] && bindkey ${key[PageUp]}   beginning-of-buffer-or-history

# ctrl-a, ctrl-e
[[ -n ${key[Home]} ]] && bindkey ${key[Home]} beginning-of-line
[[ -n ${key[End]}  ]] && bindkey ${key[End]}  end-of-line
bindkey "\e[1;5D" beginning-of-line # Ctrl + <-
bindkey "\e[1;5C" end-of-line       # Ctrl + ->

# History navigation
autoload -Uz history-search-end

zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end  history-search-end

[[ -n ${key[Up]}   ]] && bindkey ${key[Up]}   history-beginning-search-backward-end
[[ -n ${key[Down]} ]] && bindkey ${key[Down]} history-beginning-search-forward-end

# Left and right arrows
[[ -n ${key[Left]}  ]] && bindkey ${key[Left]}  backward-char
[[ -n ${key[Right]} ]] && bindkey ${key[Right]} forward-char

# jump to char (vim f/F), or use ^x^v f ...
bindkey "^]" .vi-find-next-char
bindkey "^[" .vi-find-prev-char

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

# completions from Bash
autoload bashcompinit && bashcompinit
complete -C aws_completer aws # complete aws with command (-C) aws_completer
complete -C packer packer
complete -C terraform terraform
complete -C vault vault

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

# ls f/b/b<tab> results in fob/bar/bing/ fob/baz/bing/ foo/bar/bing/ ... vs (fob|foo)/b/b
zstyle ':completion:*' list-suffixes true

# Group matches in related categories
zstyle ':completion:*' group-name ''

zstyle ':completion:*' auto-description 'Help: %d'
zstyle ':completion:*:descriptions' format '%F{170}%d%f'
zstyle ':completion:*:warnings' format 'No matches for: %B%d%b'
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals*' ignored-patterns 'zshcompctl'

compdef m=man bat=cat mg=git

# =(#b)..(pattern1)..(pattern2)..=format0=format1=format2
#      ..(pattern1)..(pattern2).. must match the whole line
# format0 is for everything unmatched
zstyle ':completion:*:processes' list-colors '=(#b) #([0-9]##) ##[^ ]## ##([^ ]##)?##=0=32=34'
zstyle ':completion:*:processes' force-list always

# ps
zstyle ':completion:*:processes' format '%BPID EUSER START CMD%b'
if ((EUID == 0))
then
    zstyle ':completion:*:processes' command 'command ps faxww o pid,euser,start_time,cmd'
else
    zstyle ':completion:*:processes' command 'command ps fxww o pid,euser,start_time,cmd'
fi

# ssh
zstyle -e ':completion:*:*:ssh:*' hosts 'reply=($(sed -n "/^\s*host\s\+[^*?]\+$/Is/\(host\)\?\s\+/\n/gIp" ~/.ssh/config | sort -u))'

# kubernetes
if (( $+commands[kubectl] ))
then
    . <(kubectl completion zsh)
fi

## (n)Vim and ed
if (( $+commands[nvim] ))
then
    alias v=nvim
else
    if [[ -n $REPOS_BASE ]]
    then
        alias v="vim -u $REPOS_BASE/github/vim/.vimrc"
    fi
fi

alias ed='ed -v -p:'

## global aliases
alias -g F='| fzf'
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
alias ha=$REPOS_BASE/github/scripts/headall.pl
alias tf='tail -f -n0'

alias cn='cat -n'

## Help
alias mm='man -k'
alias mp="$REPOS_BASE/github/scripts/man.pl"
alias h="ex -s $REPOS_BASE/github/help"

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
    alias rg='rg -S --hidden'
    alias gr=rg
    alias g=rg
elif (( $+commands[ag] ))
then
    alias ag='ag -S --hidden --color-line-number="00;32" --color-path="00;35" --color-match="01;31"'
    alias gr=ag
    alias g=ag
else
    alias gr='grep -IRiE --exclude-dir=.git --exclude-dir=.svn --exclude-dir=.hg --color=auto --exclude="*~" --exclude tags'
    alias g='grep -iE --color=auto --exclude="*~" --exclude tags'
fi

alias ge='env | grep -Ei'
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

## python
export PYENV_ROOT="$HOME/.pyenv"
(( $+commands[pyenv] )) || export PATH="$PYENV_ROOT/bin:$PATH"
(( $+commands[pyenv] )) && eval "$(pyenv init -)"

alias py=python3
alias python=python3

## Various applications aliases
if [[ $(uname) == Darwin ]]
then
    alias xclip=pbcopy
elif [[ -n $WSL_DISTRO_NAME || $(uname -r) == *microsoft* ]]
then
    alias xclip=clip.exe
    alias open=wslview
else
    alias open=xdg-open
fi

alias csv="perl -pe 's/(?:(?<=^)|(?<=,)),/ ,/g'"
alias wgetpaste='wgetpaste -s dpaste -n kurkale6ka -Ct'
alias parallel='parallel --no-notice'
alias msg=dmesg
alias os='tail -n99 /etc/*(release|version) 2>/dev/null | cat -s'
alias password='apg -a1 -n1 -m11 -x11 -MSNCL'
alias ff='ffplay -v error -vf scale=220:-1'
alias cal=$REPOS_BASE/github/scripts/cal.py
alias rr=$REPOS_BASE/github/scripts/rrepl.pl
alias sc='v ~/.ssh/known_hosts -c "e config"'

## Git
alias ga='git a'
alias gb='git -P b'
alias gbd='git bd'
alias gc='git c'
alias gd='git d'
alias gl='git -P l'
alias gll='git ll'
alias go='git checkout'
alias gf='git f'
alias gg='git g'
alias gp='git p'
alias gpu='git pu'
alias gs='git s'
alias gsa='mkconfig -s'

## tmux
alias tmux='tmux -2'
alias tl='tmux ls'
alias ta='tmux attach-session'

## fzf
[[ -f ~/.fzf.zsh ]] && . ~/.fzf.zsh

## Local zshrc file
[[ -r $XDG_CONFIG_HOME/zsh/.zshrc-local.zsh ]] && . $XDG_CONFIG_HOME/zsh/.zshrc-local.zsh

# vim: fdm=expr fde=getline(v\:lnum)=~'^\\s*##'?'>'.(len(matchstr(getline(v\:lnum),'###*'))-1)\:'='
