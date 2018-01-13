#!/bin/sh

ln -s `pwd`/.tmux.conf ~/.tmux.conf
ln -s `pwd`/dotzshd ~/.zsh.d
ln -s `pwd`/jmdot-emacs-d ~/.emacs.d
echo 'export ZDOTDIR=$HOME/.zsh.d' > ~/.zshenv

## local setting
# cp dotzshd/.zshrc_local_skel dotzshd/.zshrc_local
## edit dotzshd/.zshrc_local

## for emacs
# cd ~/.emacs.d; mkdir lisp; mkdir site-start.d
## install ddskk:
## igor-mode
# git clone https://github.com/yamad/igor-mode.git
## FreeFem mode
# git clone https://github.com/rrgalvan/freefem-mode.git

## for valgrind
# ln -s `pwd`/.valgrindrc ~/.valgrindrc
# ln -s `pwd`/valgrind/jm.sup ~/local/share/valgrind/jm.sup

