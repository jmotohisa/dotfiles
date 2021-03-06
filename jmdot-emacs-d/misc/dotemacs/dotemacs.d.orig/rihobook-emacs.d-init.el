(setq user-full-name "Junichi Motohisa")
(setq user-mail-address "motohisa@ist.hokudai.ac.jp")

(set-language-environment 'Japanese)

;; taken from sakito --started--
;(set-default-coding-systems 'euc-jp)
(prefer-coding-system 'utf-8) ; uncomment out by JM, 09/06/20
(set-keyboard-coding-system 'sjis-mac)
;(set-terminal-coding-system 'euc-jp)
(set-terminal-coding-system 'utf-8) ; by JM, 09/06/20
(setq file-name-coding-system 'utf-8)
;(set-buffer-process-coding-system 'utf-8)
(set-clipboard-coding-system 'sjis-mac)
(setq network-coding-system-alist
      '(("nntp" . (junet-unix . junet-unix))
       (110 . (no-conversion . no-conversion))
       (25 . (no-conversion . no-conversion))
       ))
;;taken from sakito --end

(setq default-coding-system 'utf-8)
;(setq default-coding-system 'sjis)

;; sgml-modc完全移行
;;; YaTeX & yahtml (野鳥、HTML屋)
;; yatex-mode
(setq auto-mode-alist
      (cons (cons "\\.tex$" 'yatex-mode) auto-mode-alist))
(autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)

;; yahtml-mode
(setq auto-mode-alist
      (cons (cons "\\.html$" 'yahtml-mode) auto-mode-alist))
(autoload 'yahtml-mode "yahtml" "Yet Another HTML mode" t)

(defvar YaTeX-dvi2-command-ext-alist
 '(("xdvi" . ".dvi")
   ("ghostview\\|vg" . ".ps")
   ("acroread\\|pdf\\Preview\\|TeXShop" . ".pdf")))
(setq  tex-command "/usr/local/bin/dotexshop"
           dvi2-command "open -a /Applications/TeXShop.app")

;; 自動改行を無効
(add-hook 'yatex-mode-hook'(lambda ()(setq auto-fill-function nil)))
(add-hook 'skk-mode-hook
         (lambda ()
           (if (eq major-mode 'yatex-mode)
               (progn
                 (define-key skk-j-mode-map “¥¥“ 'self-insert-command)
                 (define-key skk-j-mode-map “$“ 'YaTeX-insert-dollar)
                 ))
           ))

;; taken from http://blumec8.aees.kyushu-u.ac.jp/~satoru/emacs.html		   
;;encoding
;(set-default-coding-systems 'euc-jp-unix)
;(set-default-coding-systems 'sjis-unix)
;(set-buffer-file-coding-system 'sjis-mac)
;(set-terminal-coding-system 'utf-8)
;(set-keyboard-coding-system
; (if (eq window-system 'mac) 'sjis-unix 'utf-8))
;	;(set-clipboard-coding-system 'utf-8)
;(set-clipboard-coding-system 'sjis-mac)
;	;(set-file-name-coding-system 'utf-8)
;(require 'utf-8m)
;(set-file-name-coding-system 'utf-8m)
;(if (eq window-system 'mac)
;	(progn
;	  (setq YaTeX-kanji-code '1)
	;;   1=Shift JIS
	;;   2=JIS
	;;   3=EUC
;	  (setq YaTeX-latex-message-code 'sjis-mac)
;	  ))
;(add-hook 'f90-mode-hook
;		  (function
;		   (lambda ()
;			 (set-buffer-file-coding-system 'euc-jp-unix)
;			 )))

;;Color
(if window-system (progn
					(setq initial-frame-alist '((width . 100) (height . 40)))
	;;  (set-background-color "RoyalBlue4")
	;;  (set-foreground-color "LightGray")
	;;  (set-cursor-color "Gray")
					))

;;mac-option-key set to meta-key 
;(setq mac-option-modifier 'meta)
;(setq YaTeX-kanji-code 1)
;(setq YaTeX-latex-message-code 'sjis)
;(set-default-coding-systems 'utf-8-unix)
;(set-default-coding-systems 'sjis-unix)
;(set-terminal-coding-system 'utf-8-unix)
;(set-keyboard-coding-system 'sjis-mac)
;(set-clipboard-coding-system 'sjis-mac)
;(setq-default buffer-file-coding-system 'utf-8)
;(prefer-coding-system 'utf-8)
;(prefer-coding-system 'sjis)

(setq load-path (cons (expand-file-name "~/.emacs.d") load-path))
(server-start)

(setq c-tab-always-indent t)
(setq default-tab-width 4)
(setq indent-line-function 'indent-relative-maybe) ; 前と同じ行の幅にインデント

(setq mac-allow-anti-aliasing nil)  ; mac 固有の設定
(setq mac-option-modifier 'meta) ; mac 用の command キーバインド
(mac-key-mode 1) ; MacKeyModeを使う

(global-set-key "\C-x\C-i" 'indent-region) ; 選択範囲をインデント
(global-set-key "\C-m" 'newline-and-indent) ; リターンで改行とインデント
(global-set-key "\C-j" 'newline)  ; 改行

(global-set-key "\C-cc" 'comment-region)    ; C-c c を範囲指定コメントに
(global-set-key "\C-cu" 'uncomment-region)  ; C-c u を範囲指定コメント解除に

(show-paren-mode t) ; 対応する括弧を光らせる。
(transient-mark-mode t) ; 選択部分のハイライト

(setq require-final-newline t)          ; always terminate last line in file
(setq default-major-mode 'text-mode)    ; default mode is text mode

(setq completion-ignore-case t) ; file名の補完で大文字小文字を区別しない
(setq partial-completion-mode 1) ; 補完機能を使う

;; spice-mode (07/10/02)
;;
(autoload 'spice-mode "spice-mode" "Spice/Layla Editing Mode" t)
(setq auto-mode-alist (append (list (cons "\\.sp$" 'spice-mode)
                                     (cons "\\.cir$" 'spice-mode)
                                     (cons "\\.ckt$" 'spice-mode)
                                     (cons "\\.mod$" 'spice-mode)
                                     (cons "\\.cdl$" 'spice-mode)
                                     (cons "\\.chi$" 'spice-mode) ;eldo outpt
                                     (cons "\\.inp$" 'spice-mode))
                               auto-mode-alist))

;; スタートアップメッセージを非表示
(setq inhibit-startup-message t)
(if window-system (progn
; ツールバーの非表示
(tool-bar-mode nil)))

(if (assoc "\\.ctl" auto-mode-alist)
	nil
  (nconc auto-mode-alist '(("\\.ctl" . scheme-mode))))
  
; 08/02/03
; verilog mode
; taken from http://ryusai.hp.infoseek.co.jp/veri-mode.htm
; verilog mode is downloaded from http://www.verilog.com

(defun prepend-path ( my-path )
(setq load-path (cons (expand-file-name my-path) load-path)))

(defun append-path ( my-path )
(setq load-path (append load-path (list (expand-file-name my-path)))))

;;Lood first in the directory ~/elisp for elisp files
(prepend-path "~/elisp")

;;Load verilog-mode only when needed
(autoload 'verilog-mode "verilog-mode" "Verilog mode" t )

;; Any files that end in .v should be in verilog mode
(setq auto-mode-alist (cons '("\\.v\\'" . verilog-mode) auto-mode-alist))

;; Any files in verilog mode shuold have their keywords colorized
(add-hook 'verilog-mode-hook '(lambda () (font-lock-mode 1)))

; 08/02/05 octave mode
;
;
(autoload 'octave-mode "octave-mod" nil t)
(setq auto-mode-alist
      (cons '("\\.m$" . octave-mode) auto-mode-alist))

(add-hook 'octave-mode-hook
          (lambda ()
            (abbrev-mode 1)
            (auto-fill-mode 1)
            (if (eq window-system 'x)
                (font-lock-mode 1))))

; 08/07/31 w3m
;; 4.1. 基本
;;     次の設定を ￣/.emacs に追加してください．
(require 'w3m-load)
(autoload 'w3m "w3m" "Interface for w3m on Emacs." t)

;;     付属プログラムを使用するには，追加の設定が必要な場合があります．詳
;;     細については，個々の付属プログラムのソースファイルの先頭に記載され
;;     ているコメントを参照してください．良く分からない場合は，とりあえず，
;;     以下の設定を ￣/.emacs に追加しておいてください．

(autoload 'w3m-find-file "w3m" "w3m interface function for local file." t)
(autoload 'w3m-search "w3m-search" "Search QUERY using SEARCH-ENGINE." t)
(autoload 'w3m-weather "w3m-weather" "Display weather report." t)
(autoload 'w3m-antenna "w3m-antenna" "Report chenge of WEB sites." t)
(autoload 'w3m-namazu "w3m-namazu" "Search files with Namazu." t)

(setq w3m-icon-directory
      (cond
       ((featurep 'mac-carbon) "/Applications/Emacs.app/Contents/Resource/etc/w3m")
       ((featurep 'dos-w32) "D:/cygwin//usr/local/emacs/etc/w3m")))

(setq w3m-namazu-tmp-file-name
      (cond
       ((featurep 'mac-carbon) "~/.nmz.html")
       ((featurep 'dos-w32) "d:/cygwin/home/hoge/.nmz.html")))

(setq w3m-namazu-index-file "~/.w3m-namazu.index")

(setq w3m-bookmark-file
      (cond
       ((featurep 'mac-carbon) "~/.w3m/bookmark.html")
       ((featurep 'dos-w32) "d:/cygwin/home/hoge/public_html/bookmark.html")))

(if (featurep 'dos-w32)
  (setq w3m-imagick-convert-program "d:/cygwin/usr/local/bin/convert.exe"))

;;; ■■ browse-url
;;;   以下のように設定しておくと、URI に類似した文字列がある場所で C-x m と
;;;   入力すれば、w3m で表示されるようになる。
(setq browse-url-browser-function 'w3m-browse-url)
(autoload 'w3m-browse-url "w3m" "Ask a WWW browser to show a URL." t)
(global-set-key "\C-xm" 'browse-url-at-point)

;;; ■■ dired
;;;   以下のように設定しておくと、dired-mode のバッファでファイルを選択して
;;;   いる状態で C-x m と入力すれば、該当ファイルが w3m で表示されるように
;;;   なる。

(add-hook 'dired-mode-hook
          (lambda ()
            (define-key dired-mode-map "\C-xm" 'dired-w3m-find-file)))

(defun dired-w3m-find-file ()
  (interactive)
  (require 'w3m)
  (let ((file (dired-get-filename)))
    (if (y-or-n-p (format "Open 'w3m' %s " (file-name-nondirectory file)))
        (w3m-find-file file))))

;;;
;;; verilog mode
;;;

(autoload 'verilog-mode "verilog-mode" "Verilog mode" t )
(setq auto-mode-alist (cons  '("\\.v\\'" . verilog-mode) auto-mode-alist))
(setq auto-mode-alist (cons  '("\\.dv\\'" . verilog-mode) auto-mode-alist))

;;;
;;; VHDL mode
;;;
(autoload 'vhdl-mode "vhdl-mode" "VHDL Mode" t)
(setq auto-mode-alist (cons '("\\.vhdl?\\'" . vhdl-mode) auto-mode-alist))

;; AppleScript Mode
;;
(autoload 'applescript-mode "applescript-mode" "major mode for editing AppleScript source." t)
(setq auto-mode-alist
     (cons '("\\.applescript$" . applescript-mode) auto-mode-alist)
     )

; フォントの設定 ; 09/04/18 taken from emacs.el.txt but I do not know its source
(create-fontset-from-fontset-spec
 (concat
  "-*-fixed-medium-r-normal-*-16-*-*-*-*-*-fontset-monaco16,"
  "japanese-jisx0208:-apple-osaka-medium-r-normal--16-160-75-75-m-160-jisx0208.1983-sjis,"
  "katakana-jisx0201:apple-helvetica-medium-r-normal--14-140-75-75-m-140-mac-roman,"
  "ascii:-apple-monaco-medium-r-normal-*-14-*-*-*-*-*-mac-roman"))
(set-default-font "fontset-monaco16")
;;(when (/= window-system 'x)
(setq default-frame-alist (append '((font . "fontset-monaco16"))))
;;)
;;解像度により上記が大きい場合は以下
(create-fontset-from-fontset-spec
 (concat
  "-*-fixed-medium-r-normal-*-12-*-*-*-*-*-fontset-monaco12,"
  "japanese-jisx0208:-apple-osaka-medium-r-normal--14-140-*-m-140-jisx0208.1983-sjis,"
  "ascii:-apple-monaco-medium-r-normal-*-12-*-*-*-*-*-mac-roman"))
(set-default-font "fontset-monaco12")
(setq default-frame-alist (append '((font . "fontset-monaco12"))))


;;以下は参考です、エラーになる物もあります
;"japanese-jisx0201:,"  
;(require 'bitmap)
;(set-face-font 'default "-*-fixed-medium-r-normal-*-18-*")
;(set-face-font 'default "-*-courier-medium-r-normal-*-18-*")
;(set-face-font 'default "-*-monaco-medium-r-normal-*-14-*")
;(if (fboundp 'new-fontset)
;    (progn
;      (create-fontset-from-fontset-spec
;       "-*-fixed-medium-r-normal-*-18-*-*-*-*-*-fontset-mac,
;        mac-roman-lower:-*-Monaco-*-*-*-*-14-*-*-*-*-*-mac-roman,
;        mac-roman-upper:-*-Monaco-*-*-*-*-14-*-*-*-*-*-mac-roman,
;        thai-tis620:-ETL-Fixed-*-*-*-*-16-*-*-*-*-*-tis620.2529-1,
;        lao:-Misc-Fixed-*-*-*-*-16-*-*-*-*-*-MuleLao-1,
;        vietnamese-viscii-lower:-ETL-Fixed-*-*-*-*-16-*-*-*-*-*-viscii1.1-1,
;        vietnamese-viscii-upper:-ETL-Fixed-*-*-*-*-16-*-*-*-*-*-viscii1.1-1,
;        chinese-big5-1:-*-Nice Taipei Mono-*-*-*-*-12-*-*-*-*-*-big5,
;        chinese-big5-2:-*-Nice Taipei Mono-*-*-*-*-12-*-*-*-*-*-big5,
;        chinese-gb2312:-*-Beijing-*-*-*-*-16-*-*-*-*-*-gb2312,
;        japanese-jisx0208:-apple-osaka-medium-r-normal--18-180-75-75-m-180-jisx0208.1983-sjis,
;        katakana-jisx0201:-*-*-*-*-*-*-16-*-*-*-*-*-JISX0201.1976-0,
;        korean-ksc5601:-*-Seoul-*-*-*-*-16-*-*-*-*-*-ksc5601"
;       t)))
;(load "~/src/intlfonts-1.2/bdf_intn")
;(load "~/src/intlfonts-1.2/bdf_intn24")

; igor mode 12/04/27
  (add-to-list 'load-path "/Applications/Emacs.app/Contents/Resources/site-lisp/igor-mode")
  (require 'igor-mode)

;; reftex mode 12/07/03
(add-hook 'yatex-mode-hook 'turn-on-reftex) ; with YaTeX mode
