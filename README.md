# Fuzzy stuff using [fzf](https://github.com/junegunn/fzf)

## fuzzy cd based on visited locations only (bookmarks)

All of the following is needed:  
**Install in** `~/.zshenv`:
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
  or c pattern
  or c -s

TODO:
  consider file names
  file="$(locate -Ai -0 $ALL_NON_CONTAINED_PATHS_FROM_DB $@ | grep -z -vE '~$' | fzf +s --read0 -0 -1)"
```

## fuzzy cd to anywhere + fuzzy file opening with nvim

* https://github.com/kurkale6ka/zsh/blob/master/autoload/fuzzy/cf
* https://github.com/kurkale6ka/zsh/blob/master/autoload/fuzzy/vf
