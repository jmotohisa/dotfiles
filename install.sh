#!/bin/sh

ln -s "`pwd`"/.tmux.conf ~/.tmux.conf
ln -s "`pwd`"/dotzshd ~/.zsh.d
ln -s "`pwd`"/jmdot-emacs-d ~/.emacs.d
echo 'export ZDOTDIR=$HOME/.zsh.d' > ~/.zshenv

## local setting
# cp dotzshd/.zshrc_local_skel dotzshd/.zshrc_local
## edit dotzshd/.zshrc_local

## for emacs
# cd ~/.emacs.d; mkdir lisp; mkdir site-start.d; mkdir local-lisp
## install ddskk:
# wget http://www.ring.gr.jp/archives/elisp/skk/maintrunk/ddskk-16.2.tar.gz
# cd ddskk-XX.X; cd dic; wget http://openlab.ring.gr.jp/skk/skk/dic/SKK-JISYO.L
# export EMACS=/path/to/emacs
# echo '(setq SKK_DATADIR "~/.emacs.d/share/skk")' >> SKK-CFG
# echo '(setq SKK_INFODIR "~/.emacs.d/info")' >> SKK-CFG
# echo '(setq SKK_LISPDIR "~/.emacs.d/lisp/skk")' >> SKK-CFG
# echo '(setq SKK_SET_JISYO t)' >> SKK-CFG
# make  install LISPDIR=~/.emacs.d/lisp VERSION_SPECIFIC_LISPDIR=~/.emacs.d/lisp INFODIR=~/.emacs.d/info
#
## igor-mode
# cd ~/.emacs.d/lisp
# git clone https://github.com/yamad/igor-mode.git
## FreeFem mode
# git clone https://github.com/rrgalvan/freefem-mode.git
## py-autopep8
# git clone https://github.com/paetzke/py-autopep8.el.git

## for valgrind
# ln -s `pwd`/.valgrindrc ~/.valgrindrc
# mkdir -p $(HOME)/local/share/valgrind
# ln -s `pwd`/valgrind/jm.sup ~/local/share/valgrind/jm.sup

