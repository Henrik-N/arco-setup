#!/bin/bash

# logging
log() { echo -e "\e[37mlog:\e[0m $1"; } # normal log (white)
log_i() { echo -e "\e[32minfo:\e[0m $1"; } # info (green)
log_w() { echo -e "\e[33mwarn:\e[0m $1"; } # warning (yellow)
log_e() { echo -e "\e[31merr:\e[0m $1"; } # error (error)

# install package if not already up to date
inst() { yay -S $1 --needed --noconfirm; }

# install if package isn't already installed
inst_if_none() { yay -Qi $1 >/dev/null || inst $1; }

system_update() {
    sudo pacman -Syyu || {
        # if upgrade fails, we may be lacking the keyrings
        log_i "pacman -Syyu failed, will try to upgrade keys"
        inst archlinux-keyring || log_w "there was a problem upgrading the keyrings"
        sudo pacman -Syyu || log_e "sudo pacman -Syyu failed" && exit 1
    }

    # install yay
    sudo pacman -S yay-bin --needed

    # update aur packages as well
    yay -Syyu --aur
}

# get or update folder from github
github_path="https://github.com/"
get_git() {
    local folder=$(basename $1)
    # pull if folder exists, otherwise clone from github
    [ -d $folder ] && git -C $folder pull || git clone $github_path$1
}

setup_keybindings() {
    get_git Henrik-N/swevi
    mkdir -p ~/.config/swevi
    cp -r swevi/linux/* ~/.config/swevi/
    sudo bash ~/.config/swevi/bindkeys.sh
}

main() {
    system_update

    # install git
    inst git

    #
    setup_keybindings

    # steam meta package
    inst arcolinux-meta-steam-nvidia

    # nerd fonts meta package
    inst_if_none nerd-fonts-complete

    inst gitkraken
}

main

