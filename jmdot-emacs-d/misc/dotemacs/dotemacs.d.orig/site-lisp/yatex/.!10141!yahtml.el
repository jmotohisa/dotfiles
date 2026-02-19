;;; -*- Emacs-Lisp -*-
;;; (c) 1994-2012 by HIROSE Yuuji [yuuji(@)yatex.org]
;;; Last modified Thu May 10 11:06:39 2012 on firestorm
;;; $Id: yahtml.el,v 1.76 2012/05/14 10:55:57 yuuji Rel $

(defconst yahtml-revision-number "1.76"
  "Revision number of running yahtml.el")

;;;[Installation]
;;; 
;;; First, you have to install YaTeX and make sure it works fine.  Then
;;; put these expressions into your ~/.emacs
;;; 
;;; 	(setq auto-mode-alist
;;; 		(cons (cons "\\.html$" 'yahtml-mode) auto-mode-alist))
;;; 	(autoload 'yahtml-mode "yahtml" "Yet Another HTML mode" t)
;;; 	(setq yahtml-www-browser "firefox")
;;;      ;Write your favorite browser.  But firefox is advantageous.
;;; 	(setq yahtml-path-url-alist
;;; 	      '(("/home/yuuji/public_html" . "http://www.mynet/~yuuji")
;;; 		("/home/staff/yuuji/html" . "http://www.othernet/~yuuji")))
;;;      ;Write correspondence alist from ABSOLUTE unix path name to URL path.
;;; 
