# Fuzzy stuff using [fzf](https://github.com/junegunn/fzf)

## fuzzy cd based on visited locations only (bookmarks)

All of the following is needed:
```sh
mkdir -p ~/.local/share/marks

sqlite3 ~/.local/share/marks/marks.sqlite << 'INIT'
CREATE TABLE marks (
  dir VARCHAR(200) UNIQUE,
  weight INTEGER
);

CREATE INDEX _dir ON marks (dir);
INIT
```
* [the fuzzy cd function](https://github.com/kurkale6ka/zsh/blob/master/.zsh/autoload/fuzzy/c)
* [the bookmarks update function](https://github.com/kurkale6ka/zsh/blob/master/.zsh/autoload/fuzzy/update_marks)
* the zsh hook function: `chpwd_functions+=(update_marks)` in `~/.zshrc`

```
Usage:
     c
  or c pattern
  or c -s
```

## fuzzy cd to anywhere + fuzzy file opening with nvim

* https://github.com/kurkale6ka/zsh/blob/master/.zsh/autoload/fuzzy/cf
* https://github.com/kurkale6ka/zsh/blob/master/.zsh/autoload/fuzzy/vf
