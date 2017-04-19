# Fuzzy cd based on bookmarks or 'updatedb' indexed files

_Every cd is bookmarked and assigned a weight so you can later on jump to it quickly_

## All of the following is needed:

1. **Install** [fzf](https://github.com/junegunn/fzf)

2. **XDG setup** (see below)  

3. **Bookmarks database**:

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

4. **Autoload functions**:  
   _Pre-requirements_:  
   https://github.com/kurkale6ka/zsh/blob/master/.zshrc#L21-L26 in `~/.zshrc`  
   `mkdir -p $XDG_CONFIG_HOME/zsh/autoload/fuzzy`
     * [the fuzzy cd function](https://github.com/kurkale6ka/zsh/blob/master/autoload/fuzzy/c)
     * [the bookmarks update function](https://github.com/kurkale6ka/zsh/blob/master/autoload/fuzzy/update_marks)
     * [cleanup](https://github.com/kurkale6ka/zsh/blob/master/autoload/fuzzy/ccleanup)

5. **PWD hook function**: `chpwd_functions+=(update_marks)` in `~/.zshrc`

## Usage:
```
c             # choose to cd from all marks
c pattern ... # cd to a matching path
c -s          # statistics
```

# XDG setup

In `/etc/zsh/zshenv`, `/etc/zshenv` or `~/.zshenv`:
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
```
