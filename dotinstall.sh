#!/bin/sh

# USAGE notes
# read -n 1, doesn't always work
# causing this installer to work autonomously unless interrupted by sudo
# may need redesign for several runs

prelude() {
    echo "PRELUDE"
    echo "Setup git over ssh"
    #read -n 1

    if ! [ $( command -v python3 ) ] ; then
        if ! [ $( command -v apt )] ; then
            echo "Install Python3 & py3 venv"
            #read -n 1
        else # Self serve on apt-based systems (Ubuntu / Pop_os)
            sudo apt install -y python3 python3-venv
        fi
    fi

    if ! [ $( command -v bash ) ] ; then
        echo "Install bash"
    fi
}

prepareGit() {
    echo "Preparing git"
    if ! [ -d ~/git ] ; then
        mkdir ~/git
    fi

    cd ~/git

    git clone git@github.com:Catamondium/dotfiles.git
    cd
}

linkBash() {
    echo "Linking Bash scripts"
    echo "Preparing configs"
    echo "Prepared aliases & bashrc & bash_profile"
}


init() {

    prelude
    prepareGit
    prepareRust
    echo "Initialization complete"
}

init
linkBash
echo "Dotfiles installation complete"
