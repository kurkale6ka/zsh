# Fuzzy cd based on bookmarks

**SUMMARY**  
_Every cd is bookmarked and assigned a weight so you can later on jump to it quickly_

All of the following is needed:  

**Install** [fzf](https://github.com/junegunn/fzf)

**Put this snippet in** `~/.zshenv`:
```sh
# XDG data home
if [[ -z $XDG_DATA_HOME ]]
then
   export XDG_DATA_HOME=$HOME/.local/share
fi
```
**Then run**:
```sh
mkdir -p $XDG_DATA_HOME/marks

sqlite3 $XDG_DATA_HOME/marks/marks.sqlite << 'INIT'
CREATE TABLE marks (
  dir VARCHAR(200) UNIQUE,
  weight INTEGER
);

CREATE INDEX _dir ON marks (dir);
INIT
```
**Functions + hook**:
* [the fuzzy cd function](https://github.com/kurkale6ka/zsh/blob/master/autoload/fuzzy/c)
* [the bookmarks update function](https://github.com/kurkale6ka/zsh/blob/master/autoload/fuzzy/update_marks)
* [cleanup](https://github.com/kurkale6ka/zsh/blob/master/autoload/fuzzy/ccleanup)
* the zsh hook function: `chpwd_functions+=(update_marks)` in `~/.zshrc`

**Usage**:
```
     c
  or c pattern ...
  or c -s

TODO:
  take file names into consideration
  file="$(locate -Ai -0 $ALL_NON_CONTAINED_PATHS_FROM_DB $@ | grep -z -vE '~$' | fzf +s --read0 -0 -1)"
```

## And the generic version...

* [Generic fuzzy cd](https://github.com/kurkale6ka/zsh/blob/master/autoload/fuzzy/cf)
* [Generic fuzzy file opening](https://github.com/kurkale6ka/zsh/blob/master/autoload/fuzzy/vf)

# XDG setup

`/etc/zsh/zshenv`:
```sh
# XDG configuration home
if [[ -z $XDG_CONFIG_HOME ]]
then
   export XDG_CONFIG_HOME=$HOME/.config
fi

# XDG data home
if [[ -z $XDG_DATA_HOME ]]
then
   export XDG_DATA_HOME=$HOME/.local/share
fi

# zsh dot files
export ZDOTDIR=$XDG_CONFIG_HOME/zsh
```
