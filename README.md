# Fuzzy cd based on bookmarks

_Every cd is bookmarked and assigned a weight so you can later on jump to it quickly_

## All of the following is needed:

1. **Install** [fzf](https://github.com/junegunn/fzf)

2. **XDG setup**:

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

4. **Autoload functions** ([ZSH Functions](http://zsh.sourceforge.net/Doc/Release/Functions.html)):  
     * [fuzzy cd](https://github.com/kurkale6ka/zsh/blob/master/autoload/fuzzy/c)
     * [bookmarks update](https://github.com/kurkale6ka/zsh/blob/master/autoload/fuzzy/update_marks)
     * [bookmarks cleanup](https://github.com/kurkale6ka/zsh/blob/master/autoload/fuzzy/ccleanup)

5. **PWD hook function**: `chpwd_functions+=(update_marks)` in `~/.zshrc`

## Usage:
```
c             # choose where to cd from all bookmarks
c pattern ... # cd to a matching path
c -s          # statistics

ccleanup
```
