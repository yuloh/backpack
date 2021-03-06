#!/usr/bin/env bash

if [ ! -n "$dotfiles_path" ]; then
    dotfiles_path=~"$BACKPACK_HOME/dotfiles"
fi

app_cfg_path=$BACKPACK/plugins/dotfiles/apps
custom_app_cfg_path=$BACKPACK_HOME/plugins/dotfiles/apps

print_info "Syncing dotfiles..."

if [ -${#dotfiles[@]} -eq 0 ]; then
    dotfiles=()
fi

for app in "${dotfiles[@]}"; do
    # get the list of files to sync
    if [ -f "$custom_app_cfg_path/$app.cfg" ]; then
        cfg="$custom_app_cfg_path/$app.cfg"
    elif [ -f "$app_cfg_path/$app.cfg" ]; then
        cfg="$app_cfg_path/$app.cfg"
    else
        cfg='dev/null'
    fi

    while read -u 3 -r file; do
        # If we have a file or directory backed up,
        # there isn't already a symlink for it,
        # and we aren't syncing an OSX file on linux
        if ( [ -f "$dotfiles_path/$file" ] || [ -d "$dotfiles_path/$file" ] ) &&
            [ ! "$dotfiles_path/$file" -ef "$HOME/$file" ] &&
            ( bp_is_linux || [[ ! $file == $HOME/Library* ]] )
        then
            # If a file/dir/symlink exists, confirm before we replace it
            if [ -e "$HOME/$file" ] || [ -d "$HOME/$file" ]; then
               if bp_confirm "Overwrite $file with the backup?"; then
                   bp_trash "$HOME/$file"
                   print_info "$dotfiles_path/$file > $HOME/$file"
                   mkdir -p "$(dirname "$HOME/$file")"
                   ln -s "$dotfiles_path/$file" "$HOME/$file"
                fi
            else
                # othewise we can just link our backup to the destination path
                print_info "$dotfiles_path/$file > $HOME/$file"
                mkdir -p "$(dirname "$HOME/$file")"
                ln -s "$dotfiles_path/$file" "$HOME/$file"
            fi
        fi
    done 3< "$cfg"
done
