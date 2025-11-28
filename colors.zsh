# Colors
if [[ $(uname) != OpenBSD ]]
then
    export GROFF_NO_SGR=1

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

    export EZA_COLORS='uu=0:gu=0:da=38;5;242'
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
