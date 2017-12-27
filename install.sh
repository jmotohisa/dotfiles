#!/bin/sh

ln -s `pwd`/.tmux.conf ~/.tmux.conf
ln -s `pwd`/dotzshd ~/.zsh.d
ln -s `pwd`/jmdot-emacs-d ~/.emacs.d
echo 'export ZDOTDIR=$HOME/.zsh.d' > ~/.zshenv

## for emacs
# cd ~/.emacs.d; mkdir lisp; mkdir site-start.d
## install ddskk:
## igor-mode
# git clone https://github.com/yamad/igor-mode.git
