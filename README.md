# dotfiles_server

# Optional manual
- Make vicd based on vifm. In .bashrc add the following
```sh
vicd()
{
    local dst="$(command vifm --choose-dir - "$@")"
    if [ -z "$dst" ]; then
        echo 'Directory picking cancelled/failed'
        return 1
    fi
    cd "$dst"
}
```
and source ~/.bashrc
