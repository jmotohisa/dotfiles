#!/bin/sh

ln -s `pwd`/.tmux.conf ~/.tmux.conf
ln -s `pwd`/dotzshd ~/.zsh.d
ln -s `pwd`/jmdot-emacs-d ~/.emacs.d
echo 'export ZDOTDIR=$HOME/.zsh.d' > ~/.zshenv

