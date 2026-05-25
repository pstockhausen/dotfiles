#!/bin/bash

set -euo pipefail

# copy dotfiles
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
copy_dotfiles() {
    local src="$1"
    local dest="$2"

    if [ -d "$src" ]; then
        mkdir -p "$dest"
        # Use find to get all files (including hidden), excluding . and ..
        local files=()
        while IFS= read -r -d '' f; do
            files+=("$f")
        done < <(find "$src" -mindepth 1 -maxdepth 1 -print0)
        if [ ${#files[@]} -gt 0 ]; then
            cp -r "${files[@]}" "$dest/"
        else
            echo "No files to copy from $src."
        fi
    else
        echo "Source directory $src does not exist."
    fi
}

# Copy dotfiles to home directory
copy_dotfiles "$DOTFILES_DIR/.bash.d" "$HOME/.bash.d"

copy_dotfiles "$DOTFILES_DIR/bash" "$HOME/"

copy_dotfiles "$DOTFILES_DIR/git" "$HOME/"

copy_dotfiles "$DOTFILES_DIR/gpg" "$HOME/.gnupg"

copy_dotfiles "$DOTFILES_DIR/run-commands" "$HOME/"

# copy whole directories
copy_dotfiles "$DOTFILES_DIR/common" "$HOME/common"

