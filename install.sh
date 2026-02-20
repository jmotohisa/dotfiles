#!/bin/sh

ln -s "`pwd`"/.tmux.conf ~/.tmux.conf
ln -s "`pwd`"/dotzshd ~/.zsh.d
ln -s "`pwd`"/jmdot-emacs-d ~/.emacs.d
ln -s "`pwd`"/dotvim ~/.vim
ln -s "`pwd`"/dotvimrc ~/.vimrc
echo 'export ZDOTDIR=$HOME/.zsh.d' > ~/.zshenv

## local setting
# cp dotzshd/.zshrc_local_skel dotzshd/.zshrc_local
## edit dotzshd/.zshrc_local

if uname | grep -q "CYGWIN"; then
    echo "alias pbcopy='putclip'" >> "`pwd`"/dotzshd/.zshrc_`uname`
    echo "alias pbpaste='getclip'" >> "`pwd`"/dotzshd/.zshrc_`uname`
fi

if uname | grep -q "Linux"; then
    echo "alias pbcopy='xsel --input --clipboard'" >> "`pwd`"/dotzshd/.zshrc_`uname`
    echo "alias pbpaste='xsel --output --clipboard'" >> "`pwd`"/dotzshd/.zshrc_`uname`
fi

## for emacs
# cd ~/.emacs.d; mkdir lisp; mkdir site-start.d; mkdir local-lisp
# install following from package
# color-theme-sanityinc-solarized
# ddskk-20241227.2223/
# geiser
# multi-term
# py-autopep8
# spice-mode
# switch-window
# verilog-mode
# w3m-20250503.2349/
# yatex-20250224.1034/
# ddskk

# To remove deprecated warning:
# $ cd ~/.emacs.d/elpa/el-get-XXXXXXXX.XXX;sed -i -e s/\'autoload\)/\'loaddefs-gen\)/g *.el

# ansi-color-for-comint-mode-on
# latex-indent-command
# latex-indent-region-command
# vhdl
# octave
# applesciprt
# imaxima
# lua
# arduino-mode
# gmsh

# ## install ddskk:
# # wget http://www.ring.gr.jp/archives/elisp/skk/maintrunk/ddskk-16.2.tar.gz
# # cd ddskk-XX.X; cd dic; wget http://openlab.ring.gr.jp/skk/skk/dic/SKK-JISYO.L
# # cd ../
# # export EMACS=/path/to/emacs
# # echo '(setq SKK_DATADIR "~/.emacs.d/share/skk")' >> SKK-CFG
# # echo '(setq SKK_INFODIR "~/.emacs.d/info")' >> SKK-CFG
# # echo '(setq SKK_LISPDIR "~/.emacs.d/lisp/skk")' >> SKK-CFG
# # echo '(setq SKK_SET_JISYO t)' >> SKK-CFG
# # make  install LISPDIR=~/.emacs.d/lisp VERSION_SPECIFIC_LISPDIR=~/.emacs.d/lisp INFODIR=~/.emacs.d/info
#
## igor-mode
# cd ~/.emacs.d/lisp
# git clone https://github.com/yamad/igor-mode.git
## FreeFem mode
# git clone https://github.com/rrgalvan/freefem-mode.git

## py-autopep8: install from  package
### git clone https://github.com/paetzke/py-autopep8.el.git
## multiterm: install from package
## verilog-mode install from package

## how can I install ?


## for valgrind
# ln -s `pwd`/.valgrindrc ~/.valgrindrc
# mkdir -p $(HOME)/local/share/valgrind
# ln -s `pwd`/valgrind/jm.sup ~/local/share/valgrind/jm.sup

