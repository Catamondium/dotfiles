#!/bin/sh

fixGnome() {
    gsettings set org.gnome.settings-daemon.peripherals.touchscreen orientation-lock true
    gsettings set org.gnome.settings-daemon.plugins.orientation active false
    xrandr -o normal
    echo "Fixed gnome"
}

prelude() {
    echo "PRELUDE"
    echo "Setup git over ssh"
    read -n 1

    if ! [ $( command -v python3 ) ] ; then
        echo "Install Python3 & py3 venv"
        read -n 1
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

    if ! [ -d ~/git/dotfiles ] ; then
        git clone git@github.com:Catamondium/dotfiles.git
    fi

    git clone git@github.com:Catamondium/scratch.git
    git clone git@github.com:Catamondium/projects.git
    cd
}

linkBash() {
    echo "Linking Bash scripts"
    sudo ln ~/git/projects/Bash/fsplit.sh /usr/bin/fsplit
    sudo ln ~/git/projects/Bash/cropdir.sh /usr/bin/cropdir
    echo "Installed fsplit & cropdir"

    echo "Preparing configs"
    if [ -f ~/.bash_aliases ] ; then
        mv ~/.bash_aliases ~/bash_aliases.bak
    fi
    ln -s ~/git/dotfiles/bash/bash_aliases.sh ~/.bash_aliases

    if [ -f ~/.bashrc ] ; then
        mv ~/.bashrc ~/bashrc.bak
    fi
    ln -s ~/git/dotfiles/bash/bashrc.sh ~/.bashrc

    if [ -f ~/.bash_profile ] ; then
        mv ~/.bash_profile ~/bash_profile.bak
    fi
    ln -s ~/git/dotfiles/bash/bash_profile.sh ~/.bash_profile

    echo "Prepared aliases & bashrc & bash_profile"
}

prepareRust() {
    echo "Preparing Rust"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    . ~/.cargo/env
}

linkRusts() {
    echo "Installing Rust binaries"
    cd ~/git/projects/Rust

    cd addtime
    cargo build --release
    sudo cp ./target/release/addtime /usr/bin/addtime
    echo "Installed addtime"

    cd ../mol
    cargo build --release
    sudo cp ./target/release/mol /usr/bin/mol
    echo "Installed mol"

    cd ../rname/bin
    cargo build --release --bin client --features="build-bin"
    cargo build --release --bin rnamed --features="build-daemon"
    cd ..
    sudo cp ./target/release/client /usr/bin/rname
    sudo cp ./target/release/rnamed /usr/bin/rnamed
    echo "Installed rname & rnamed"
    cd
}

forcePython3() {
    sudo cp /usr/bin/python3 /usr/bin/python
    echo "Forced Python3"
}

linkPythons() {
    echo "Linking python scripts"
    echo "Preparing venvs"

    sudo ln -s ~/git/projects/Python/envrun.py /usr/bin/envrun
    sudo ln -s ~/git/projects/Python/envrun.py /bin/envrun

    sudo ln -s ~/git/projects/Python/dedupDir/dedupDir.py /usr/bin/dedupdir
    echo "Linked envrun & dedupdir"

    cd ~/git/projects/Python3/upDir
    python3 -m venv .
    . bin/activate
    pip install -r requirements
    deactivate
    echo "Get upDir token.secret for Dropbox API"
    read -n 1
    sudo ln -s ~/git/projects/Python/upDir/upDir.py /usr/bin/updir
    echo "Installed updir"

    cd ../calbot
    python3 -m venv .
    . bin/activate
    pip install -r requirements
    deactivate
    echo "Get calbot credentials.json for Google API"
    read -n 1
    sudo ln -s ~/git/projects/Python/calbot/bot.py /usr/bin/calbot
    echo "Installed calbot"
    cd
}

init() {
    if [ $( command -v gsettings ) ] ; then
        fixGnome
    fi

    prelude
    prepareGit
    prepareRust
    forcePython3
    echo "Initialization complete"
}

init
linkRusts
linkPythons
linkBash
echo "Dotfiles installation complete"