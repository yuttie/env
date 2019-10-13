#!/bin/sh
REMOTE=$1
ssh $REMOTE sudo add-apt-repository ppa:neovim-ppa/stable
ssh $REMOTE sudo apt update
ssh $REMOTE sudo apt upgrade
ssh $REMOTE sudo apt install neovim tmux python3.7{,-dev} python3-distutils build-essential nodejs inotify-tools
ssh $REMOTE curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
ssh $REMOTE python3.7 get-pip.py --user
ssh $REMOTE pip3.7 install --user --upgrade pip pipenv pynvim neovim-remote
ssh $REMOTE mkdir -p ~/.local/bin
ssh $REMOTE mkdir -p ~/.config
rsync -avSHAXz ~/.config/coc ~/.config/nvim $REMOTE:.config/
rsync -avSHAXz ~/dotfiles/{.git{attributes,config,ignore},.npmrc,.tmux.conf} $REMOTE:
rsync -avSHAXz ~/.local/bin/{antibody,fzf} $REMOTE:.local/bin/
rsync -avSHAXz ~/{zdotdir,.zlogin,.zlogout,.zprofile,.zshenv,.zshrc,.zfunc,.zsh.d,.zsh_plugins.sh} $REMOTE:
