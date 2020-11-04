(setq user-full-name "Junichi Motohisa")
(setq user-mail-address "motohisa@ist.hokudai.ac.jp")
(setq user-id-string "jmotohisa")

;; taken from http://d.hatena.ne.jp/tomoya/20090807/1249601308
(defun x->bool (elt) (not (not elt)))

;; emacs-version predicates
(setq emacs23-p (string-match "^23" emacs-version)
	  emacs24-p (string-match "^24" emacs-version)
	  emacs24.3-p (string-match "^24\.3" emacs-version)
	  emacs24.4-p (string-match "^24\.4" emacs-version)
	  emacs24.5-p (string-match "^24\.5" emacs-version)
	  emacs26.3-p (string-match "^26\.3" emacs-version))

;; system-type predicates
(setq darwin-p  (eq system-type 'darwin)
      ns-p      (eq window-system 'ns)
      carbon-p  (eq window-system 'mac)
      linux-p   (eq system-type 'gnu/linux)
      colinux-p (when linux-p
                  (let ((file "/proc/modules"))
                    (and
                     (file-readable-p file)
                     (x->bool
                      (with-temp-buffer
                        (insert-file-contents file)
                        (goto-char (point-min))
                        (re-search-forward "^cofuse\.+" nil t))))))
      cygwin-p  (eq system-type 'cygwin)
      nt-p      (eq system-type 'windows-nt)
      meadow-p  (featurep 'meadow)
      windows-p (or cygwin-p nt-p meadow-p))

(if darwin-p
    (progn
      (require 'package)
      (add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
      (add-to-list 'package-archives '("marmalade" . "http://marmalade-repo.org/packages/"))
      (package-initialize))
  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; path
;;;; based on http://sakito.jp/emacs/emacsshell.html#path
;;;; and http://github.com/ryseto
;; (dolist (dir (list
;; 			  "/sbin"
;;               "/usr/sbin"
;;               "/bin"
;;               "/usr/bin"
;;               "/usr/local/bin"
;;               (expand-file-name "~/bin")
;;               ))
;;   (when (and (file-exists-p dir) (not (member dir exec-path)))
;;     (setenv "PATH" (concat dir ":" (getenv "PATH")))
;;     (setq exec-path (append (list dir) exec-path))))

;;(add-to-list 'load-path "/usr/local/share/emacs/site-lisp/")

;;(setq load-path (cons (expand-file-name "~/.emacs.d") load-path))

;;(setq exec-path (append exec-path '("/opt/local/bin")))

;; (setenv "PATH" (concat "/opt/bin:/opt/local/bin:" (getenv "PATH")))
;; (setenv "LTDL_LIBRARY_PATH"
;; 		(concat "/opt/local/lib:" (getenv "LTDL_LIBRARY_PATH")))

;; コマンドサーチパスの設定

(if darwin-p
	(progn
	  (add-to-list 'exec-path "/opt/local/bin")
	  (add-to-list 'exec-path "/Users/motohisa/bin")
	  (setenv "PATH"
			  (concat "/usr/local/bin:/opt/local/bin:/Users/motohisa/bin:" (getenv "PATH"))))
  (progn
	  (add-to-list 'exec-path "/home/motohisa/bin")
	  (setenv "PATH"
			  (concat "/usr/local/bin:/home/motohisa/bin:" (getenv "PATH"))))
  )
(setenv "PATH"
	(concat "/usr/local/bin:/opt/local/bin:/Users/motohisa/bin:" (getenv "PATH")))

;; 引数を load-path へ追加
;; normal-top-level-add-subdirs-to-load-path はディレクトリ中で
;; [A-Za-z] で開始する物だけ追加する。
;; 追加したくない物は . や _ を先頭に付与しておけばロードしない
;; dolist は Emacs 21 から標準関数なので積極的に利用して良い
(defun add-to-load-path (&rest paths)
  (let (path)
    (dolist (path paths paths)
      (let ((default-directory
              (expand-file-name (concat user-emacs-directory path))))
        (add-to-list 'load-path default-directory)
        (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
            (normal-top-level-add-subdirs-to-load-path))))))

(add-to-load-path "lisp" ;; 
                  "local-lisp";; 変更したり、自作の Emacs Lisp
                  "private"
				  "site-start.d" ;; 初期設定ファイル
				  )

(setenv "MANPATH" (concat "/usr/local/man:/usr/share/man:/Developer/usr/share/man:/opt/local/share/man" (getenv "MANPATH")))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; start emacsclient server
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(if window-system
	(progn 
	  (require 'server)
	  (unless (server-running-p) (server-start))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Japanese setting
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(set-language-environment 'utf-8)
(prefer-coding-system 'utf-8)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Appearence
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; スタートアップメッセージを非表示
(setq inhibit-startup-message t)
;; ツールバー/メニューバーの非表示
(if (window-system)
	(progn (tool-bar-mode nil)
		   (menu-bar-mode nil)))
(if (window-system)
	(progn 
	  (setq initial-frame-alist '((width . 100) (height . 40)))
	  ;;  (set-background-color "RoyalBlue4")
	  ;;  (set-foreground-color "LightGray")
	  ;;  (set-cursor-color "Gray")
	  ))

;; color theme
;;(load "color-theme.el")
(load "color-theme-solarized.el")
(if (window-system)
	(progn 
	  (color-theme-solarized-dark) ;; solarized
	  (defun light-theme ()
		(interactive)
		(load-theme 'solarized-light t))
	  (defun dark-theme ()
		(interactive)
		(load-theme 'solarized-dark t))
))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; font
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  originally from http://sakito.jp/emacs/emacs23.html
;;
;(when (>= emacs-major-version 23)
; (set-face-attribute 'default nil
;                     :family "monaco"
;                     :height 140)
; (set-fontset-font
;  (frame-parameter nil 'font)
;  'japanese-jisx0208
;  '("Hiragino Maru Gothic Pro" . "iso10646-1"))
; (set-fontset-font
;  (frame-parameter nil 'font)
;  'japanese-jisx0212
;  '("Hiragino Maru Gothic Pro" . "iso10646-1"))
; (set-fontset-font
;  (frame-parameter nil 'font)
;  'mule-unicode-0100-24ff
;  '("monaco" . "iso10646-1"))
; (setq face-font-rescale-alist
;      '(("^-apple-hiragino.*" . 1.2)
;        (".*osaka-bold.*" . 1.2)
;        (".*osaka-medium.*" . 1.2)
;        (".*courier-bold-.*-mac-roman" . 1.0)
;        (".*monaco cy-bold-.*-mac-cyrillic" . 0.9)
;        (".*monaco-bold-.*-mac-roman" . 0.9)
;        ("-cdac$" . 1.3))))
;;(set-default-font
;;"-*-Osaka-normal-normal-normal-*-12-*-*-*-m-0-iso10646-1")

	  
;;(setq mac-allow-anti-aliasing t) ;; http://macemacsjp.sourceforge.jp/index.php?cmd=read&page=MacFontSetting#c9eebb82

;; フォントの設定 ; 09/04/18 taken from emacs.el.txt but I do not know its source
;(create-fontset-from-fontset-spec
; (concat
;  "-*-fixed-medium-r-normal-*-16-*-*-*-*-*-fontset-monaco16,"
;  "japanese-jisx0208:-apple-osaka-medium-r-normal--16-160-75-75-m-160-jisx0208.1983-sjis,"
;  "katakana-jisx0201:apple-helvetica-medium-r-normal--14-140-75-75-m-140-mac-roman,"
;  "ascii:-apple-monaco-medium-r-normal-*-14-*-*-*-*-*-mac-roman"))
;(set-default-font "fontset-monaco16")
;;(when (/= window-system 'x)
;(setq default-frame-alist (append '((font . "fontset-monaco16"))))
;;)
;;解像度により上記が大きい場合は以下
;(create-fontset-from-fontset-spec
; (concat
;  "-*-fixed-medium-r-normal-*-12-*-*-*-*-*-fontset-monaco12,"
;  "japanese-jisx0208:-apple-osaka-medium-r-normal--14-140-*-m-140-jisx0208.1983-sjis,"
;  "ascii:-apple-monaco-medium-r-normal-*-12-*-*-*-*-*-mac-roman"))
;(set-default-font "fontset-monaco12")
;(setq default-frame-alist (append '((font . "fontset-monaco12"))))

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

  ;; 	  )
  ;; ) ;; end (if (window-system))

(if (window-system)
	(progn
	  (create-fontset-from-ascii-font "Menlo-14:weight=normal:slant=normal" nil "menlokakugo")
	  (set-fontset-font "fontset-menlokakugo"
						'unicode
						(font-spec :family "Hiragino Kaku Gothic ProN" :size 12)
						nil
						'append)
	  (add-to-list 'default-frame-alist '(font . "fontset-menlokakugo"))
))
;; font end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; keybords and key-binding
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq scroll-step 1)
(setq c-tab-always-indent t)
(setq default-tab-width 4)
(setq indent-line-function 'indent-relative-maybe) ; 前と同じ行の幅にインデント

;;(setq mac-allow-anti-aliasing nil)  ; mac 固有の設定; should be commented out 13/01/05
(if darwin-p
	  ;; (setq mac-option-modifier 'meta)
	(progn 
	  (setq mac-option-key-is-meta nil)
	  (setq mac-command-key-is-meta t)
	  (setq mac-command-modifier 'meta)
	  (setq mac-option-modifier nil)
	  )) ; mac 用の command キーバインド
;;(mac-key-mode 1) ; MacKeyModeを使う

(global-set-key "\C-x\C-i" 'indent-region) ; 選択範囲をインデント
(global-set-key "\C-m" 'newline-and-indent) ; リターンで改行とインデント
;; (global-set-key "\C-j" 'newline)  ; 改行

(global-set-key "\C-cc" 'comment-region)    ; C-c c を範囲指定コメントに
(global-set-key "\C-cu" 'uncomment-region)  ; C-c u を範囲指定コメント解除に

(global-unset-key "\C-t") ;; 無効化

(show-paren-mode t) ; 対応する括弧を光らせる。
(transient-mark-mode t) ; 選択部分のハイライト

(setq require-final-newline t)          ; always terminate last line in file
(setq default-major-mode 'text-mode)    ; default mode is text mode

(setq completion-ignore-case t) ; file名の補完で大文字小文字を区別しない
(setq partial-completion-mode 1) ; 補完機能を使う

;; dedicated window
(defun toggle-window-dedicated ()
  "Toggle whether the current active window is dedicated or not"
  (interactive)
  (message
   (if (let (window (get-buffer-window (current-buffer)))
		 (set-window-dedicated-p window
								 (not (window-dedicated-p window))))
	   "Window '%s' is dedicated"
	 "Window '%s' is normal")
   (current-buffer)))
(global-set-key "\C-x\C-x" 'toggle-window-dedicated)

;; zsh control
;; taken from http://sakito.jp/emacs/emacsshell.html

;; shell の存在を確認
(defun skt:shell ()
  (or (executable-find "zsh")
	  (executable-find "bash")
	  ;; (executable-find "f_zsh") ;; Emacs + Cygwin を利用する人は Zsh の代りにこれにしてください
	  ;; (executable-find "f_bash") ;; Emacs + Cygwin を利用する人は Bash の代りにこれにしてください
	  (executable-find "cmdproxy")
	  (error "can't find 'shell' command in PATH!!")))

;; Shell 名の設定
(setq shell-file-name (skt:shell))
(setenv "SHELL" shell-file-name)
(setq explicit-shell-file-name shell-file-name)

;; (cond
;;  ((or (eq window-system 'mac) (eq window-system 'ns))
;;   ;; Mac OS X の HFS+ ファイルフォーマットではファイル名は NFD (の様な物)で扱うため以下の設定をする必要がある
;;   (require 'ucs-normalize)
;;   (setq file-name-coding-system 'utf-8-hfs)
;;   (setq locale-coding-system 'utf-8-hfs))
;;  (or (eq system-type 'cygwin) (eq system-type 'windows-nt)
;; 	 (setq file-name-coding-system 'utf-8)
;; 	 (setq locale-coding-system 'utf-8)
;; 	 ;; もしコマンドプロンプトを利用するなら sjis にする
;; 	 ;; (setq file-name-coding-system 'sjis)
;; 	 ;; (setq locale-coding-system 'sjis)
;; 	 ;; 古い Cygwin だと EUC-JP にする
;; 	 ;; (setq file-name-coding-system 'euc-jp)
;; 	 ;; (setq locale-coding-system 'euc-jp)
;; 	 )
;;  (t
;;   (setq file-name-coding-system 'utf-8)
;;   (setq locale-coding-system 'utf-8)))

;; taken from http://d.hatena.ne.jp/mooz/20090613/p1
;;
;; コントロールシーケンスを利用した色指定が使えるように
(autoload 'ansi-color-for-comint-mode-on "ansi-color"
  "Set `ansi-color-for-comint-mode' to t." t)

(add-hook 'shell-mode-hook
		  '(lambda ()
			 ;; zsh のヒストリファイル名を設定
			 (setq comint-input-ring-file-name "~/.histfile")
			 ;; ヒストリの最大数
			 (setq comint-input-ring-size 1024)
			 ;; 既存の zsh ヒストリファイルを読み込み
			 (comint-read-input-ring t)
			 ;; zsh like completion (history-beginning-search)
			 (local-set-key "\M-p" 'comint-previous-matching-input-from-input)
			 (local-set-key "\M-n" 'comint-next-matching-input-from-input)
			 ;; 色の設定
			 (setq ansi-color-names-vector
				   ["#000000"           ; black
					"#ff6565"           ; red
					"#93d44f"           ; green
					"#eab93d"           ; yellow
					"#204a87"           ; blue
					"#ce5c00"           ; magenta
					"#89b6e2"           ; cyan
					"#ffffff"]          ; white
				   )
			 (ansi-color-for-comint-mode-on)
			 )
		  )

;;; multi-term
;; taken from http://sakito.jp/emacs/emacsshell.html

(require 'multi-term)
(setq multi-term-program shell-file-name)

(add-to-list 'term-unbind-key-list '"M-x")

(add-hook 'term-mode-hook
		  '(lambda ()
			 ;; C-h を term 内文字削除にする
			 (define-key term-raw-map (kbd "C-h") 'term-send-backspace)
			 ;; C-y を term 内ペーストにする
			 (define-key term-raw-map (kbd "C-y") 'term-paste)
			 ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; various modes
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;
;; skk
;;
(require 'skk-autoloads)
(global-set-key "\C-x\C-j" 'skk-mode)
(global-set-key "\C-xj" 'skk-auto-fill-mode)
(global-set-key "\C-xt" 'skk-tutorial)

;; C-j の機能を別のキーに割り当て
(global-set-key (kbd "C-m") 'newline-and-indent)
;; C-\ でも SKK に切り替えられるように設定
(setq default-input-method "japanese-skk")
;; 送り仮名が厳密に正しい候補を優先して表示
(setq skk-henkan-strict-okuri-precedence t)
;;漢字登録時、送り仮名が厳密に正しいかをチェック
(setq skk-check-okurigana-on-touroku t)

;; Specify dictionary location
(if darwin-p
	(progn
	  (setq skk-large-jisyo "/Users/motohisa/Library/Application Support/AquaSKK/SKK-JISYO.L")
	  (setq skk-extra-jisyo-file-list
			(list '("/Users/motohisa/Library/Application Support/AquaSKK/npiiii.l.euc")))
	  ;; Specify tutorial location
	  (setq skk-tut-file "/Users/motohisa/.emacs.d/share/skk/SKK.tut"))
  (if cygwin-p
	  (progn
		(setq skk-large-jisyo "/cygdrive/c/Users/motohisa/.emacs.d/share/skk/SKK-JISYO.L")
		;; (setq skk-extra-jisyo-file-list
		;; 	  (list '("/Users/motohisa/Library/Application Support/AquaSKK/npiiii.l.euc")))
		;; Specify tutorial location
		(setq skk-tut-file "/cygdrive/c/Users/motohisa/.emacs.d/share/skk/SKK.tut"))
	(progn
	  (setq skk-large-jisyo "/home/motohisa/.emacs.d/share/skk/SKK-JISYO.L")
	  ;; (setq skk-extra-jisyo-file-list
	  ;; 		(list '("//motohisa/Library/Application Support/AquaSKK/npiiii.l.euc")))
	  ;; Specify tutorial location
	  (setq skk-tut-file "/home/motohisa/.emacs.d/share/skk/SKK.tut"))
  )
)	
	  
;; 変換の学習
(require 'skk-study)

;; ;;; skk-list-chars 非表示: taken from http://garin.jp/doc/unix/skk_skk_list_chars
;; (defun skk-list-chars (&optional arg)
;;   (interactive "P")
;;   ;; skk-list-chars が呼ばれた時点で元の▽モードが終了してしまうので、再度▽モードを呼び出す
;;   (skk-set-henkan-point-subr)
;;   )
(setq skk-kcode-method 'this-key)

;;Emacs上でのコントロールキー入力をOSXに奪われないようにする
(setq mac-pass-control-to-system nil)

;; setting of ddskk : based on http://d.hatena.ne.jp/tomoya/20080903/1220406574

;; Add pahts to SKK and APEL

;; (defvar system-load-path load-path)
;; (setq my-load-path '("/usr/share/emacs/22.1/site-lisp/skk" 
;; 		     "/usr/share/emacs/22.1/site-lisp/apel" 
;; 		     "/usr/share/emacs/22.1/site-lisp/emu"))
;; (setq load-path (append my-load-path system-load-path))

;; (let ((default-directory (expand-file-name "~/.emacs.d/lisp")))
;;  (add-to-list 'load-path default-directory)
;;  (if (fboundp 'normal-top-level-add-subdirs-to-load-path)
;;      (normal-top-level-add-subdirs-to-load-path)))

;;(add-to-list 'load-path "/Applications/Emacs.app/Contents/Resources/site-lisp/skk/")

;; Configure for SKK

;; (add-hook 'isearch-mode-hook
;; 	  (function (lambda ()
;; 		      (and (boundp 'skk-mode) skk-mode
;; 			   (skk-isearch-mode-setup)))))

;; (add-hook 'isearch-mode-end-hook
;; 	  (function
;; 	   (lambda ()
;; 	     (and (boundp 'skk-mode) skk-mode (skk-isearch-mode-cleanup))
;; 	     (and (boundp 'skk-mode-invoked) skk-mode-invoked
;; 		  (skk-set-cursor-properly)))))

;; ;; (setq mac-pass-control-to-system nil)

;; ;; taken from http://d.hatena.ne.jp/cocoatomo/20091102/1257170428

;; ;; command key as meta key
;; (setq ns-command-modifier 'meta)
;; ;; option + yen(jis keyboard) => backslash
;; (setq ns-alternate-modifier 'option)

;; 
;; Aqua SKK (http://sakito.jp/emacs/emacs23.html)
;; 
(setq skk-server-host "localhost")
(setq skk-server-portnum 1178)

;;
;; skk end
;;

;;
;; YaTeX
;;
(if darwin-p
	(progn
	  ;;(setq mac-command-key-is-meta nil)
	  (autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
	  (setq auto-mode-alist
			(append '(("\\.tex$" . yatex-mode)
					  ("\\.ltx$" . yatex-mode)
					  ("\\.cls$" . yatex-mode)
					  ("\\.sty$" . yatex-mode)
					  ("\\.clo$" . yatex-mode)
					  ("\\.bbl$" . yatex-mode)) auto-mode-alist))
	  (setq YaTeX-inhibit-prefix-letter t)
	  (setq YaTeX-kanji-code nil)
	  (setq YaTeX-latex-message-code 'utf-8)
	  (setq YaTeX-use-LaTeX2e t)
	  (setq YaTeX-use-AMS-LaTeX t)
	  (setq YaTeX-dvi2-command-ext-alist
			'(("TeXworks\\|texworks\\|texstudio\\|mupdf\\|SumatraPDF\\|Preview\\|Skim\\|TeXShop\\|evince\\|okular\\|zathura\\|qpdfview\\|Firefox\\|firefox\\|chrome\\|chromium\\|Adobe\\|Acrobat\\|AcroRd32\\|acroread\\|pdfopen\\|xdg-open\\|open\\|start" . ".pdf")))
	  (setq tex-command "/opt/local/bin/ptex2pdf -u -l -ot '-synctex=1'")
										;(setq tex-command "/opt/local/bin/platex-ng -synctex=1")
										;(setq tex-command "/opt/local/bin/pdflatex -synctex=1")
										;(setq tex-command "/opt/local/bin/lualatex -synctex=1")
										;(setq tex-command "/opt/local/bin/luajitlatex -synctex=1")
										;(setq tex-command "/opt/local/bin/xelatex -synctex=1")
										;(setq tex-command "/opt/local/bin/latexmk -e '$latex=q/uplatex %O -synctex=1 %S/' -e '$bibtex=q/upbibtex %O %B/' -e '$biber=q/biber %O --bblencoding=utf8 -u -U --output_safechars %B/' -e '$makeindex=q/upmendex %O -o %D %S/' -e '$dvipdf=q/dvipdfmx %O -o %D %S/' -norc -gg -pdfdvi")
										;(setq tex-command "/opt/local/bin/latexmk -e '$latex=q/uplatex %O -synctex=1 %S/' -e '$bibtex=q/upbibtex %O %B/' -e '$biber=q/biber %O --bblencoding=utf8 -u -U --output_safechars %B/' -e '$makeindex=q/upmendex %O -o %D %S/' -e '$dvips=q/dvips %O -z -f %S | convbkmk -u > %D/' -e '$ps2pdf=q/ps2pdf %O %S %D/' -norc -gg -pdfps")
										;(setq tex-command "/opt/local/bin/latexmk -e '$pdflatex=q/platex-ng %O -synctex=1 %S/' -e '$bibtex=q/upbibtex %O %B/' -e '$biber=q/biber %O --bblencoding=utf8 -u -U --output_safechars %B/' -e '$makeindex=q/upmendex %O -o %D %S/' -norc -gg -pdf")
										;(setq tex-command "/opt/local/bin/latexmk -e '$pdflatex=q/pdflatex %O -synctex=1 %S/' -e '$bibtex=q/bibtex %O %B/' -e '$biber=q/biber %O --bblencoding=utf8 -u -U --output_safechars %B/' -e '$makeindex=q/makeindex %O -o %D %S/' -norc -gg -pdf")
										;(setq tex-command "/opt/local/bin/latexmk -e '$pdflatex=q/lualatex %O -synctex=1 %S/' -e '$bibtex=q/upbibtex %O %B/' -e '$biber=q/biber %O --bblencoding=utf8 -u -U --output_safechars %B/' -e '$makeindex=q/upmendex %O -o %D %S/' -norc -gg -pdf")
										;(setq tex-command "/opt/local/bin/latexmk -e '$pdflatex=q/luajitlatex %O -synctex=1 %S/' -e '$bibtex=q/upbibtex %O %B/' -e '$biber=q/biber %O --bblencoding=utf8 -u -U --output_safechars %B/' -e '$makeindex=q/upmendex %O -o %D %S/' -norc -gg -pdf")
										;(setq tex-command "/opt/local/bin/latexmk -e '$pdflatex=q/xelatex %O -synctex=1 %S/' -e '$bibtex=q/upbibtex %O %B/' -e '$biber=q/biber %O --bblencoding=utf8 -u -U --output_safechars %B/' -e '$makeindex=q/upmendex %O -o %D %S/' -norc -gg -pdf")
	  (setq bibtex-command "/opt/local/bin/latexmk -e '$latex=q/uplatex %O -synctex=1 %S/' -e '$bibtex=q/upbibtex %O %B/' -e '$biber=q/biber %O --bblencoding=utf8 -u -U --output_safechars %B/' -e '$makeindex=q/upmendex %O -o %D %S/' -e '$dvipdf=q/dvipdfmx %O -o %D %S/' -norc -gg -pdfdvi")
	  (setq makeindex-command "/opt/local/bin/latexmk -e '$latex=q/uplatex %O -synctex=1 %S/' -e '$bibtex=q/upbibtex %O %B/' -e '$biber=q/biber %O --bblencoding=utf8 -u -U --output_safechars %B/' -e '$makeindex=q/upmendex %O -o %D %S/' -e '$dvipdf=q/dvipdfmx %O -o %D %S/' -norc -gg -pdfdvi")
	  ;;(setq dvi2-command "/usr/bin/open -a Skim")
	  (setq dvi2-command "/Users/motohisa/bin/skim_reload2.sh")
	  ;;(setq dvi2-command "/usr/bin/open -a Preview")
										;(setq dvi2-command "/usr/bin/open -a TeXShop")
										;(setq dvi2-command "/Applications/TeXworks.app/Contents/MacOS/TeXworks")
										;(setq dvi2-command "/Applications/texstudio.app/Contents/MacOS/texstudio --pdf-viewer-only")
	  ;;(setq tex-pdfview-command "/usr/bin/open -a Skim")
	  (setq tex-pdfview-command "/Users/motohisa/bin/skim_reload2.sh")
										;(setq tex-pdfview-command "/usr/bin/open -a Preview")
										;(setq tex-pdfview-command "/usr/bin/open -a TeXShop")
										;(setq tex-pdfview-command "/Applications/TeXworks.app/Contents/MacOS/TeXworks")
										;(setq tex-pdfview-command "/Applications/texstudio.app/Contents/MacOS/texstudio --pdf-viewer-only")
	  (setq dviprint-command-format "/usr/bin/open -a \"Adobe Acrobat Reader DC\" `echo %s | gsed -e \"s/\\.[^.]*$/\\.pdf/\"`")
	  
	  (add-hook 'yatex-mode-hook
				'(lambda ()
				   (auto-fill-mode -1)))
	  
	  ;;
	  ;; RefTeX with YaTeX
	  ;;
										;(add-hook 'yatex-mode-hook 'turn-on-reftex)
	  (add-hook 'yatex-mode-hook
				'(lambda ()
				   (reftex-mode 1)
				   (define-key reftex-mode-map (concat YaTeX-prefix ">") 'YaTeX-comment-region)
				   (define-key reftex-mode-map (concat YaTeX-prefix "<") 'YaTeX-uncomment-region)))
	  
	  ;; taken from https://github.com/ryseto/emacs_and_tex/blob/master/my_yatex.el
;;; インデント (YaTeXのインデントを使わない）
;;; http://www.hit.ac.jp/~wachi/misc/latexindent.html
	  (autoload 'latex-indent-command "~/Dropbox/emacs/latex-indent"
		"Indent current line accroding to LaTeX block structure.")
	  (autoload 'latex-indent-region-command "~/Dropbox/emacs/latex-indent"
		"Indent each line in the region according to LaTeX block structure.")
	  
;;;; Skim PDF カーソル位置表示
;;; Emacs から Skim へ
;;; この機能を使うためには、
;;; pdflatex/platex にオプション -synctex=1 が必要
;;;
;;; Thanks to Tsuchiya-san's corrections (yatex ML [yatex:04810,04811])
	  (defun skim-forward-search ()
		(interactive)
		(process-kill-without-query
		 (start-process  
		  "displayline"
		  nil
		  "/Applications/Skim.app/Contents/SharedSupport/displayline"
		  (number-to-string (save-restriction
							  (widen)
							  (count-lines (point-min) (point))))
		  (expand-file-name
		   (concat (file-name-sans-extension (or YaTeX-parent-file
												 (save-excursion
												   (YaTeX-visit-main t)
												   buffer-file-name)))
				   ".pdf"))
		  buffer-file-name)))
	  
;;;; Preview.app で開く
	  (defun MyTeX-open-PreviewApp ()
		(interactive)
		(let* ((mtf)
			   (pf)
			   (cmd "open -a Preview.app"))
		  (setq mtf YaTeX-parent-file)
		  (setq pf (concat (car (split-string mtf "\\.")) ".pdf"))
		  (process-kill-without-query
		   (start-process-shell-command "Open Preview.app" nil cmd pf))))
	  
	  (defun MyTeX-open-SkimApp ()
		(interactive)
		(let* ((mtf)
			   (pf)
			   (cmd "open -a Skim.app"))
		  (setq mtf YaTeX-parent-file)
		  (setq pf (concat (car (split-string mtf "\\.")) ".pdf"))
		  (process-kill-without-query
		   (start-process-shell-command "Open Skim.app" nil cmd pf))))
	  
;;; YaTeX用キーバインドの設定
	  (add-hook 'yatex-mode-hook
				'(lambda ()
				   (turn-off-auto-fill) ; 勝手に改行しない
				   ;; (define-key YaTeX-mode-map [?\s-t] 
				   ;;   (lambda ()
				   ;; 	 (interactive)
				   ;; 	 (YaTeX-typeset-menu nil ?j)))
				   ;; (define-key YaTeX-mode-map [?\s-b] 
				   ;;   (lambda ()
				   ;; 	 (interactive)
				   ;; 	 (YaTeX-typeset-menu nil ?j)))
				   ;; (define-key YaTeX-mode-map [?\s-P]
				   ;;   (lambda (arg)
				   ;; 	 (interactive "P")
				   ;; 	 (let ((current-prefix-arg (not arg)))
				   ;; 	   (YaTeX-typeset-menu 'dummy ?p))))
				   ;; (define-key YaTeX-mode-map [?\s-B] 
				   ;;   (lambda ()
				   ;; 	 (interactive)
				   ;; 	 (YaTeX-typeset-menu nil ?b)))
				   ;; (define-key YaTeX-mode-map [?\s-I] 
				   ;;   (lambda ()
				   ;; 	 (interactive)
				   ;; 	 (YaTeX-typeset-menu nil ?i)))
				   ;;			 (define-key YaTeX-mode-map [?\s-J] 'MyTeX-open-item-BibDesk)
				   (define-key YaTeX-mode-map (kbd "C-c s") 'skim-forward-search)
				   ;;             (define-key YaTeX-mode-map "\t" 'latex-indent-command)
				   ;;             (define-key YaTeX-mode-map (kbd "C-c TAB") 'latex-indent-region-command)
				   ;;             (define-key YaTeX-mode-map [?\s-_] 'MyTeX-insert-subscript_rm)
				   ;;             (define-key YaTeX-mode-map [?\C-\s-J] 'YaTeX-goto-corresponding-*)
				   ;;             (define-key YaTeX-mode-map (kbd "C-c d") 'MyTeX-latexmk-cleanup)
				   ;;             (define-key YaTeX-mode-map [?\s-H] 'YaTeX-display-hierarchy)
				   ;;             (define-key YaTeX-mode-map [?\s-1] 'YaTeX-visit-main)
				   ;;             (define-key YaTeX-mode-map [?\s-2] 'MyTeX-switch-to-previousbuffer)
				   ;;             (define-key YaTeX-mode-map [?\M-\s-B] 'MyTool-open-bibdesk)
				   ;;             (define-key YaTeX-mode-map [?\s-ı] 'MyTool-open-bibdesk)
				   ;;             (define-key YaTeX-mode-map [?\M-\s-P] 'MyTeX-open-PreviewApp)
				   ;;             (define-key YaTeX-mode-map (kbd "s-") 'MyTeX-open-SkimApp)
				   ;;             (define-key YaTeX-mode-map [?\M-\s-P] 'MyTeX-open-PreviewApp)
				   (define-key YaTeX-mode-map [?\s-∏] 'MyTeX-open-PreviewApp)
				   (define-key YaTeX-mode-map [?\M-∏] 'MyTeX-open-PreviewApp)
				   ;;            (define-key YaTeX-mode-map [?\M-∏] 'MyTeX-open-SkimApp)
				   ;;             (define-key YaTeX-mode-map [?\s-\)] 'MyTeX-speech-region)
				   ;;             (define-key YaTeX-mode-map [?\s-C] 'MyTeX-open-article)
				   ))

	  ;; taken from http://macwiki.osdn.jp/wiki/index.php/CarbonEmacsAndYatex
	  ;; SKKで「かなモード」のときに「$」を入力すると自動的に「アスキーモード」に切り替える
	  ;;　http://www.math.s.chiba-u.ac.jp/~matsu/emacs/emacs21/yatex.html
	  (add-hook 'skk-mode-hook
				(lambda ()
				  (if (eq major-mode 'yatex-mode)
					  (progn
						(define-key skk-j-mode-map "¥¥" 'self-insert-command)
						(define-key skk-j-mode-map "$" 'YaTeX-insert-dollar)
						))
				  ))
	  
	  ;; ;; previous setting of yatex
	  ;; ;; 13/01/04
	  ;; ;; YaTeX
	  ;; ;; taken from http://oku.edu.mie-u.ac.jp/~okumura/texwiki/?YaTeX
	  
	  ;; (add-to-list 'load-path "~/.emacs.d/site-lisp/yatex")
	  ;; (autoload 'yatex-mode "yatex" "Yet Another LaTeX mode" t)
	  ;; (setq auto-mode-alist
	  ;;       (append '(("\\.tex$" . yatex-mode)
	  ;;                 ("\\.ltx$" . yatex-mode)
	  ;;                 ("\\.cls$" . yatex-mode)
	  ;;                 ("\\.sty$" . yatex-mode)
	  ;;                 ("\\.clo$" . yatex-mode)
	  ;;                 ("\\.bbl$" . yatex-mode)) auto-mode-alist))
	  ;; (setq YaTeX-inhibit-prefix-letter t)
	  ;; (setq YaTeX-kanji-code nil)
	  ;; (setq YaTeX-use-LaTeX2e t)
	  ;; (setq YaTeX-use-AMS-LaTeX t)
	  ;; (setq YaTeX-dvipdf-command "/opt/local/bin/dvipdfmx")
	  ;; (setq YaTeX-dvi2-command-ext-alist
	  ;;       '(("[agx]dvi\\|PictPrinter" . ".dvi")
	  ;;         ("gv" . ".ps")
	  ;;         ("Preview\\|TeXShop\\|TeXworks\\|Skim\\|mupdf\\|xpdf\\|Adobe" . ".pdf")))
	  ;; ;(setq tex-command "/opt/local/bin/latexmk")
	  ;; ;(setq tex-command "/opt/local/bin/latexmk -e '$latex=q/platex -synctex=1/' -e '$bibtex=q/pbibtex/' -e '$makeindex=q/mendex/' -e '$dvipdf=q/dvipdfmx %O -o %D %S/' -norc -gg -pdfdvi")
	  ;; ;(setq tex-command "/opt/local/bin/latexmk -e '$latex=q/platex -synctex=1/' -e '$bibtex=q/pbibtex/' -e '$makeindex=q/mendex/' -e '$dvips=q/dvips %O -z -f %S | convbkmk -g > %D/' -e '$ps2pdf=q/ps2pdf %O %S %D/' -norc -gg -pdfps")
	  ;; ;(setq tex-command "/opt/local/bin/latexmk -e '$latex=q/uplatex -synctex=1/' -e '$bibtex=q/upbibtex/' -e '$makeindex=q/mendex/' -e '$dvipdf=q/dvipdfmx %O -o %D %S/' -norc -gg -pdfdvi")
	  ;; ;(setq tex-command "/opt/local/bin/latexmk -e '$latex=q/uplatex -synctex=1/' -e '$bibtex=q/upbibtex/' -e '$makeindex=q/mendex/' -e '$dvips=q/dvips %O -z -f %S | convbkmk -u > %D/' -e '$ps2pdf=q/ps2pdf %O %S %D/' -norc -gg -pdfps")
	  ;; ;(setq tex-command "/opt/local/bin/latexmk -e '$pdflatex=q/pdflatex -synctex=1/' -e '$bibtex=q/bibtex/' -e '$makeindex=q/makeindex/' -norc -gg -pdf")
	  ;; ;(setq tex-command "/opt/local/bin/latexmk -e '$pdflatex=q/lualatex -synctex=1/' -e '$bibtex=q/bibtexu/' -e '$makeindex=q/texindy/' -norc -gg -pdf")
	  ;; ;(setq tex-command "/opt/local/bin/latexmk -e '$pdflatex=q/xelatex -synctex=1/' -e '$bibtex=q/bibtexu/' -e '$makeindex=q/texindy/' -norc -gg -xelatex")
	  ;; ;(setq tex-command "/opt/local/bin/platex -synctex=1")
	  ;; ;(setq tex-command "/usr/local/bin/pdfplatex")
	  ;; ;(setq tex-command "/opt/local/bin/pdfplatex2")
	  ;; ;(setq tex-command "/opt/local/bin/uplatex -synctex=1")
	  ;; ;(setq tex-command "/opt/local/bin/pdfuplatex")
	  ;; ;(setq tex-command "/opt/local/bin/pdfuplatex2")
	  ;; ;(setq tex-command "/opt/local/bin/pdflatex -synctex=1")
	  ;; ;(setq tex-command "/opt/local/bin/lualatex -synctex=1")
	  ;; ;(setq tex-command "/opt/local/bin/xelatex -synctex=1")
	  ;; (setq bibtex-command (cond ((string-match "uplatex" tex-command) "/opt/local/bin/upbibtex")
	  ;;                            ((string-match "platex" tex-command) "/opt/local/bin/pbibtex")
	  ;;                            ((string-match "lualatex\\|xelatex" tex-command) "/opt/local/bin/bibtexu")
	  ;;                            (t "/opt/local/bin/bibtex")))
	  ;; (setq makeindex-command (cond ((string-match "uplatex" tex-command) "/opt/local/bin/mendex")
	  ;;                               ((string-match "platex" tex-command) "/opt/local/bin/mendex")
	  ;;                               ((string-match "lualatex\\|xelatex" tex-command) "/opt/local/bin/texindy")
	  ;;                               (t "/opt/local/bin/makeindex")))
	  ;; ;(setq dvi2-command (cond ((string-match "pdf\\|lua\\|xe" tex-command) "/usr/bin/open -a Preview")
	  ;; ;                        (t "/usr/bin/open -a PictPrinter")))
	  ;; (setq dviprint-command-format (cond ((string-match "pdf\\|lua\\|xe" tex-command) "/usr/bin/open -a \"Adobe Reader\" %s")
	  ;;                                     (t "/usr/bin/open -a \"Adobe Reader\" `echo %s | sed -e \"s/\\.[^.]*$/\\.pdf/\"`")))
	  
	  ;; ;(setq tex-command "/usr/local/bin/dotexshop")
	  ;; ;;(setq dvi2-command "open -a /Applications/TeXShop.app")
	  ;; (setq dvi2-command "/usr/bin/open -a /Applications/Skim.app")
	  
	  ;; (defun skim-forward-search ()
	  ;;   (interactive)
	  ;;   (let* ((ctf (buffer-name))
	  ;;          (mtf)
	  ;;          (pf)
	  ;;          (ln (format "%d" (line-number-at-pos)))
	  ;;          (cmd "/Applications/Skim.app/Contents/SharedSupport/displayline")
	  ;;          (args))
	  ;;     (if (YaTeX-main-file-p)
	  ;;         (setq mtf (buffer-name))
	  ;;       (progn
	  ;;         (if (equal YaTeX-parent-file nil)
	  ;;             (save-excursion
	  ;;               (YaTeX-visit-main t)))
	  ;;         (setq mtf YaTeX-parent-file)))
	  ;;     (setq pf (concat (car (split-string mtf "\\.")) ".pdf"))
	  ;;     (setq args (concat ln " " pf " " ctf))
	  ;;     (message (concat cmd " " args))
	  ;;     (process-kill-without-query
	  ;;      (start-process-shell-command "displayline" nil cmd args))))

	  ;; (add-hook 'yatex-mode-hook
	  ;;           '(lambda ()
	  ;;              (define-key YaTeX-mode-map (kbd "C-c s") 'skim-forward-search)))

	  ;; (add-hook 'yatex-mode-hook
	  ;;           '(lambda ()
	  ;;              (auto-fill-mode -1)))

	  ;; ;;
	  ;; ;; RefTeX with YaTeX
	  ;; ;;
	  ;; ;(add-hook 'yatex-mode-hook 'turn-on-reftex)
	  ;; (add-hook 'yatex-mode-hook
	  ;;           '(lambda ()
	  ;;              (reftex-mode 1)
	  ;;              (define-key reftex-mode-map (concat YaTeX-prefix ">") 'YaTeX-comment-region)
	  ;;              (define-key reftex-mode-map (concat YaTeX-prefix "<") 'YaTeX-uncomment-region)))

	  ;;
	  ;; was a reminder of rihobook-emacs.d-init.el
	  ;;

	  ;; 自動改行を無効
										;(add-hook 'yatex-mode-hook'(lambda ()(setq auto-fill-function nil)))
										;(add-hook 'skk-mode-hook
										;         (lambda ()
										;           (if (eq major-mode 'yatex-mode)
										;               (progn
										;                 (define-key skk-j-mode-map “¥¥“ 'self-insert-command)
										;                 (define-key skk-j-mode-map “$“ 'YaTeX-insert-dollar)
										;                 ))
										;           ))
	  ;;
	  ;; End: a reminder of rihobook-emacs.el
	  ;;

	  ;; ;; 13/01/14
	  ;; ;; YaTeX end
	  ;; ;;
	  )) ;; end of if darwin-p

;; ;; flymake
;; ;; ;; flymake (for C)
;; (require 'flymake)
;; (setq flymake-log-level 3)

;; ;; taken from http://shnya.jp/blog/?p=477
;; ;; 全てのファイルでflymakeを有効化
;; (add-hook 'find-file-hook 'flymake-find-file-hook)

;; ;; miniBufferにエラーを出力
;; (defun flymake-show-and-sit ()
;;   "Displays the error/warning for the current line in the minibuffer"
;;   (interactive)
;;   (progn
;; 	(let* ((line-no (flymake-current-line-no) )
;; 		   (line-err-info-list (nth 0 (flymake-find-err-info flymake-err-info line-no)))
;; 		   (count (length line-err-info-list)))
;; 	  (while (> count 0)
;; 		(when line-err-info-list
;; 		  (let* ((file (flymake-ler-file (nth (1- count) line-err-info-list)))
;; 				 (full-file
;; 				  (flymake-ler-full-file (nth (1- count) line-err-info-list)))
;; 				 (text (flymake-ler-text (nth (1- count) line-err-info-list)))
;; 				 (line (flymake-ler-line (nth (1- count) line-err-info-list))))
;; 			(message "[%s] %s" line text)))
;; 		(setq count (1- count)))))
;;   (sit-for 60.0))
;; (global-set-key "\C-cd" 'flymake-show-and-sit)

;; ;; flymakeの色を変更
;; (set-face-background 'flymake-errline "red4")
;; (set-face-background 'flymake-warnline "dark slate blue")

;; ;; Makefile が無くてもC/C++のチェック
;; (defun flymake-simple-generic-init (cmd &optional opts)
;;   (let* ((temp-file  (flymake-init-create-temp-buffer-copy
;; 					  'flymake-create-temp-inplace))
;; 		 (local-file (file-relative-name
;; 					  temp-file
;; 					  (file-name-directory buffer-file-name))))
;; 	(list cmd (append opts (list local-file)))))

;; (defun flymake-simple-make-or-generic-init (cmd &optional opts)
;;   (if (file-exists-p "Makefile")
;; 	  (flymake-simple-make-init)
;; 	(flymake-simple-generic-init cmd opts)))

;; (defun flymake-c-init ()
;;   (flymake-simple-make-or-generic-init
;;    "gcc" '("-Wall" "-Wextra" "-pedantic" "-fsyntax-only")))

;; (defun flymake-cc-init ()
;;   (flymake-simple-make-or-generic-init
;;    "g++" '("-Wall" "-Wextra" "-pedantic" "-fsyntax-only")))

;; (push '("\\.c\\'" flymake-c-init) flymake-allowed-file-name-masks)
;; (push '("\\.\\(cc\\|cpp\\|C\\|CPP\\|hpp\\)\\'" flymake-cc-init)
;; 	  flymake-allowed-file-name-masks)

;; ;; ;; old setting for flymake
;; ;; (defun flymake-c-init ()
;; ;;   (let* ((temp-file   (flymake-init-create-temp-buffer-copy
;; ;;          'flymake-create-temp-inplace))
;; ;;          (local-file  (file-relative-name
;; ;;                        temp-file
;; ;;                        (file-name-directory buffer-file-name))))
;; ;;     (list "gcc" (list "-Wall" "-Wextra" "-fsyntax-only" "-I/opt/local/include" "-I/opt/local/include/guile/2.0" "-I/Users/motohisa/local/include" local-file))))
;; ;; (defun flymake-h-init ()
;; ;;   (let* ((temp-file   (flymake-init-create-temp-buffer-copy
;; ;;                        'flymake-create-temp-inplace))
;; ;;          (local-file  (file-relative-name
;; ;;                        temp-file
;; ;;                        (file-name-directory buffer-file-name))))
;; ;;     (list "gcc" (list "-Wall" "-Wextra" "-I/opt/local/include" "-I/opt/local/include/guile/2.0" "-I/Users/motohisa/local/include" local-file))))

;; ;; (push '("\\.h$" flymake-h-init) flymake-allowed-file-name-masks)
;; ;; (push '("\\.c$" flymake-c-init) flymake-allowed-file-name-masks)

;; ;; (add-hook 'c-mode-hook
;; ;;    '(lambda ()
;; ;;       (flymake-mode t)))

;; ;;; flymake-tex ;; taken from http://www.hnagata.net/archives/115
;; (if darwin-p (progn 
;; (defun flymake-get-tex-args (file-name)
;;   (list "/opt/local/bin/ptex2pdf" (list "-file-line-error" "-draftmode" "-interaction=nonstopmode" file-name)))
;; ))

;; ;;
;; ;; flymake end
;; ;;

;;window
(require 'switch-window)

;; gdb:
;; for darwin, use ggdb instead of gdb
(if darwin-p
	(progn
	  (setq gud-gdb-command-name "/opt/local/bin/ggdb -i=mi"))
  (if (window-system)
	  (progn
;;; 有用なバッファを開くモード
		(setq gdb-many-windows t)
;;; 変数の上にマウスカーソルを置くと値を表示
		(add-hook 'gdb-mode-hook '(lambda () (gud-tooltip-mode t)))
;;; I/O バッファを表示
		(setq gdb-use-separate-io-buffer t)
;;; t にすると mini buffer に値が表示される
		(setq gud-tooltip-echo-area nil)
		)))

;;
;; ctl-mode
;;
(if (assoc "\\.ctl" auto-mode-alist)
	nil
;;  (nconc auto-mode-alist '(("\\.ctl" . scheme-mode))))
  (add-to-list 'auto-mode-alist '("\\.ctl\\'" . scheme-mode)))

;; ;; guile
;; (require 'gds)
  
;;
;; spice-mode 13/01/18 (originally 07/10/02)
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
;; (custom-set-variables 
;; ; '(spice-initialize-file-function (quote geert-spice-file-header)) ;; use geert-spice-file-header function (not included in this file !)
;;  ;; '(spice-initialize-empty-file t)         ;; initialize empty/new spice file
;; ; '(spice-standard '(spice2g6 (hspice eldo eldorf eldovloga layla))) ;; all 4 modes
;;  ;; '(spice-standard (quote (spice2g6 (hspice eldo))))    ;; hspice and eldo
;;  ;; '(spice-standard (quote (spice2g6 ())))               ;; spice2g6/3 only
;;  '(spice-simulator "ngspice")                           ;; default simulator
;; ; '(spice-waveform-viewer "Nutmeg")                     ;; default waveform 
;;  ;; '(spice-highlight-keywords nil)                       ;; less highlighting
;;  ;; '(spice-section-alist                                 ;; add own sections
;;  ;;   ;; this is ugly, I know ;)
;;  ;;   (append (nth 1 (nth 0 (get 'spice-section-alist 'standard-value)))
;;  ;;           (list 
;;  ;;            (list "My Header"    "MY HEADER"    nil)
;;  ;;            )))
;;  ;; '(spice-use-func-menu t)                          ;; use func-menu (XEmacs)
;;  ;; '(spice-show-describe-mode nil)         ;; don't describe mode at startup
;;  )

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages (quote (markdown-mode lua-mode geiser)))
 '(spice-show-describe-mode nil)
 '(spice-simulator "ngspice")
 '(spice-simulator-alist
   (quote
    (("Spice3" "spice3 -b" ""
      ("\\s-*Error[	 ]+on[ 	]+line[	 ]+\\([0-9]+\\) +:.+" 0 1 nil
       (buffer-file-name))
      ("Circuit: \\(.*\\)$" 1))
     ("Hspice" "hspice" ""
      ("\\s-*\\(..?error..?[: ]\\).+" 0 spice-linenum 1
       (buffer-file-name))
      ("[* ]* [iI]nput [fF]ile: +\\([^ 	]+\\).*$" 1))
     ("Eldo" "eldo -i" ""
      ("\\s-*\\(E[rR][rR][oO][rR] +[0-9]+:\\).*" 0 spice-linenum 1
       (buffer-file-name))
      ("Running \\(eldo\\).*$" 1))
     ("Spectre" "spectre" ""
      ("\\s-*\"\\([^ 	
]+\\)\" +\\([0-9]+\\):.*" 1 2)
      ("" 0))
     ("ngspice" "ngspice" ""
      ("\\s-*Error[	 ]+on[ 	]+line[	 ]+\\([0-9]+\\) +:.+" 0 1 nil
       (buffer-file-name))
      ("Circuit: \\(.*\\)$" 1))))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;;
;; spice mode end
;;

;; 08/02/03
;; verilog mode
;; taken from http://ryusai.hp.infoseek.co.jp/veri-mode.htm
;; verilog mode is downloaded from http://www.verilog.com

;; (defun prepend-path ( my-path )
;; (setq load-path (cons (expand-file-name my-path) load-path)))

;; (defun append-path ( my-path )
;; (setq load-path (append load-path (list (expand-file-name my-path)))))

;; ;;Lood first in the directory ~/elisp for elisp files
;; (prepend-path "~/elisp")

;;Load verilog-mode only when needed
;; (autoload 'verilog-mode "verilog-mode" "Verilog mode" t )

;; Any files that end in .v should be in verilog mode
;; (setq auto-mode-alist (cons '("\\.v\\'" . verilog-mode) auto-mode-alist
							;; ))

;; Any files in verilog mode shuold have their keywords colorized
;; (add-hook 'verilog-mode-hook '(lambda () (font-lock-mode 1)))

(autoload 'verilog-mode "verilog-mode" "Verilog mode" t )
(setq auto-mode-alist (cons  '("\\.v\\'" . verilog-mode) auto-mode-alist))
(setq auto-mode-alist (cons  '("\\.dv\\'" . verilog-mode) auto-mode-alist))

;;;
;;; VHDL mode
;;;
(autoload 'vhdl-mode "vhdl-mode" "VHDL Mode" t)
(setq auto-mode-alist (cons '("\\.vhdl?\\'" . vhdl-mode) auto-mode-alist))

;;
;; 08/02/05 octave mode
;;
(autoload 'octave-mode "octave-mod" nil t)
(setq auto-mode-alist
      (cons '("\\.m$" . octave-mode) auto-mode-alist))

(add-hook 'octave-mode-hook
          (lambda ()
            (abbrev-mode 1)
            (auto-fill-mode 1)
            (if (eq window-system 'x)
                (font-lock-mode 1))))

;; ;; 
;; ;; 08/07/31 w3m, modified on 13/01/04
;; ;; 必要ならload-pathに追加
;; (add-to-list 'load-path "~/.emacs.d/elisp/emacs-w3m/share/emacs/site-lisp/w3m")
;; ;; w3mのコマンドのパスを指定
;; (setq w3m-command "/opt/local/bin/w3m")
;; (require 'w3m-load)

;; ;; 4.1. 基本
;; ;;     次の設定を ￣/.emacs に追加してください．
;; ;;(require 'w3m-load)
;; (autoload 'w3m "w3m" "Interface for w3m on Emacs." t)

;; ;;     付属プログラムを使用するには，追加の設定が必要な場合があります．詳
;; ;;     細については，個々の付属プログラムのソースファイルの先頭に記載され
;; ;;     ているコメントを参照してください．良く分からない場合は，とりあえず，
;; ;;     以下の設定を ￣/.emacs に追加しておいてください．

;; (autoload 'w3m-find-file "w3m" "w3m interface function for local file." t)
;; (autoload 'w3m-search "w3m-search" "Search QUERY using SEARCH-ENGINE." t)
;; (autoload 'w3m-weather "w3m-weather" "Display weather report." t)
;; (autoload 'w3m-antenna "w3m-antenna" "Report chenge of WEB sites." t)
;; (autoload 'w3m-namazu "w3m-namazu" "Search files with Namazu." t)

;; (setq w3m-icon-directory
;;       (cond
;;        ((featurep 'mac-carbon) "/Applications/Emacs.app/Contents/Resource/etc/w3m")
;;        ((featurep 'dos-w32) "D:/cygwin//usr/local/emacs/etc/w3m")))

;; (setq w3m-namazu-tmp-file-name
;;       (cond
;;        ((featurep 'mac-carbon) "~/.nmz.html")
;;        ((featurep 'dos-w32) "d:/cygwin/home/hoge/.nmz.html")))

;; (setq w3m-namazu-index-file "~/.w3m-namazu.index")

;; (setq w3m-bookmark-file
;;       (cond
;;        ((featurep 'mac-carbon) "~/.w3m/bookmark.html")
;;        ((featurep 'dos-w32) "d:/cygwin/home/hoge/public_html/bookmark.html")))

;; (if (featurep 'dos-w32)
;;   (setq w3m-imagick-convert-program "d:/cygwin/usr/local/bin/convert.exe"))

;; ;;; ■■ browse-url
;; ;;;   以下のように設定しておくと、URI に類似した文字列がある場所で C-x m と
;; ;;;   入力すれば、w3m で表示されるようになる。
;; (setq browse-url-browser-function 'w3m-browse-url)
;; (autoload 'w3m-browse-url "w3m" "Ask a WWW browser to show a URL." t)
;; (global-set-key "\C-xm" 'browse-url-at-point)

;; ;;; ■■ dired
;; ;;;   以下のように設定しておくと、dired-mode のバッファでファイルを選択して
;; ;;;   いる状態で C-x m と入力すれば、該当ファイルが w3m で表示されるように
;; ;;;   なる。
;; (add-hook 'dired-mode-hook
;;           (lambda ()
;;             (define-key dired-mode-map "\C-xm" 'dired-w3m-find-file)))

;; (defun dired-w3m-find-file ()
;;   (interactive)
;;   (require 'w3m)
;;   (let ((file (dired-get-filename)))
;;     (if (y-or-n-p (format "Open 'w3m' %s " (file-name-nondirectory file)))
;;         (w3m-find-file file))))
;; ;; 13/01/04
;; ;; w3m end
;; ;1;

;;
;; AppleScript Mode
;;
(autoload 'applescript-mode "applescript-mode" "major mode for editing AppleScript source." t)
(setq auto-mode-alist
     (cons '("\\.applescript$" . applescript-mode) auto-mode-alist)
     )

;;
;; igor mode 12/04/27
;;
(if darwin-p
    (if (not emacs26.3-p)
	(progn
	  (add-to-list 'load-path "~/.emacs.d/lisp/igor-mode")
	  (require 'igor-mode))
  ))

;; reftex mode 12/07/03;; commented in on 13/01/04 ;; see above yatex mode
;(add-hook 'yatex-mode-hook 'turn-on-reftex) ; with YaTeX mode

;; ;;
;; ;; evernote mode
;; ;;
;; (add-to-list 'load-path "~/.emacs.d/site-lisp")
;; (setq evernote-ruby-command "/usr/bin/ruby")
;; (require 'evernote-mode)
;; (setq evernote-username "motohisa@ist.hokudai.ac.jp") ; optional: you can use this username as default.
;; (setq evernote-enml-formatter-command '("w3m" "-dump" "-I" "UTF8" "-O" "UTF8")) ; optional
;; (global-set-key "\C-cec" 'evernote-create-note)
;; (global-set-key "\C-ceo" 'evernote-open-note)
;; (global-set-key "\C-ces" 'evernote-search-notes)
;; (global-set-key "\C-ceS" 'evernote-do-saved-search)
;; (global-set-key "\C-cew" 'evernote-write-note)
;; (global-set-key "\C-cep" 'evernote-post-region)
;; (global-set-key "\C-ceb" 'evernote-browser)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
;;; org-mode
;;;
(require 'org)
;; キーバインドの設定
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
;; 拡張子がorgのファイルを開いた時，自動的にorg-modeにする
(add-to-list 'auto-mode-alist '("\\.org$" . org-mode))
(add-to-list 'auto-mode-alist '("\\.txt\\'$" . org-mode)) 
(add-to-list 'auto-mode-alist '("\\.howm$" . org-mode))
;; org-modeでの強調表示を可能にする
(add-hook 'org-mode-hook 'turn-on-font-lock)
;; 見出しの余分な*を消す
(setq org-hide-leading-stars t)
;; org-default-notes-fileのディレクトリ
(setq org-directory "~/home/org/")
;; org-default-notes-fileのファイル名
(setq org-default-notes-file "notes.org")
;; LaTeX文を処理
(setq org-export-with-LaTeX-fragments t)
;; CDLaTeX
;;(add-hook 'org-mode-hook 'turn-on-org-cdlatex)
;; org-mode では auto-fill-mode
(add-hook 'org-mode-hook
          '(lambda ()
             (setq fill-column 80)
             (auto-fill-mode t)
             ))
;; 折り返しを切り替える
(setq org-startup-truncated t)
(defun change-truncation()
  (interactive)
  (cond ((eq truncate-lines nil)
         (setq truncate-lines t))
        (t
         (setq truncate-lines nil))))
;; LaTeX でのエクスポート
;; http://d.hatena.ne.jp/tamura70/20100217/org
(setq org-export-latex-coding-system 'utf-8)
(setq org-export-latex-date-format "%Y-%m-%d")
(setq org-export-latex-classes nil)
(add-to-list 'org-export-latex-classes
  '("jsarticle"
    "\\documentclass[10pt,a4paper]{jsarticle}
"
    ("\\section{%s}" . "\\section*{%s}")
    ("\\subsection{%s}" . "\\subsection*{%s}")
    ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
    ("\\paragraph{%s}" . "\\paragraph*{%s}")
    ("\\subparagraph{%s}" . "\\subparagraph*{%s}")
))
(add-to-list 'org-export-latex-classes
 '("jsbook"
   "\\documentclass[10pt,a4paper]{jsbook}
"
    ("\\chapter{%s}" . "\\chapter*{%s}")
    ("\\section{%s}" . "\\section*{%s}")
    ("\\subsection{%s}" . "\\subsection*{%s}")
    ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
    ("\\paragraph{%s}" . "\\paragraph*{%s}")
    ("\\subparagraph{%s}" . "\\subparagraph*{%s}")
))

;; デフォルトで読みこまれるパッケージ
;; http://tmishina.cocolog-nifty.com/blog/2010/11/org-jsarticle-l.html
(setq org-export-latex-default-packages-alist
  '(("AUTO" "inputenc"  t)
    ("T1"   "fontenc"   t)
    (""     "fixltx2e"  nil)
    (""     "graphicx"  t)
    (""     "longtable" nil)
    (""     "float"     nil)
    (""     "wrapfig"   nil)
    (""     "soul"      nil)
    (""     "textcomp"  nil)
    (""     "marvosym"  nil)
    (""     "wasysym"   nil)
    (""     "latexsym"  nil)
    (""     "amssymb"   nil)
    ("dvipdfmx"     "hyperref"  nil)
    "\\tolerance=1000"
    )
) 


;; Caption を有効に
;; http://orgmode.org/worg/org-tutorials/org-latex-export.html#sec-10_4
(org-add-link-type
 "caption" nil
 (lambda (path desc format)
   (cond
    ((eq format 'html)
     (format "<span class=\"caption\">%s</span>" desc))
    ((eq format 'latex)
     (format "\\caption[%s]{%s}" path desc)))))

;; taken from 2ch
(define-key global-map [?¥] [?\\])
(define-key global-map [?\C-¥] [?\C-\\])
(define-key global-map [?\M-¥] [?\M-\\])
(define-key global-map [?\C-\M-¥] [?\C-\M-\\])

(define-key isearch-mode-map [?¥] '(lambda () (interactive)(isearch-yank-string "\\") ))


;; aspell
(setq-default ispell-program-name "aspell") 

;;freefem++-mode
(autoload 'freefem++-mode "freefem++-mode" nil t)
(setq auto-mode-alist
      (cons '("\\.edp$" . freefem++-mode) auto-mode-alist))
(setq freefempp-program "/usr/local/ff++/openmpi-2.1/3.56/bin/FreeFem++")

;; ;; evernote mode 2014/11/26
;; (require 'evernote-mode)
;; (global-set-key "\C-cec" 'evernote-create-note)
;; (global-set-key "\C-ceo" 'evernote-open-note)
;; (global-set-key "\C-ces" 'evernote-search-notes)
;; (global-set-key "\C-ceS" 'evernote-do-saved-search)
;; (global-set-key "\C-cew" 'evernote-write-note)
;; (global-set-key "\C-cep" 'evernote-post-region)
;; (global-set-key "\C-ceb" 'evernote-browser)
;; (setq evernote-username "jmotohisa")

;; ;; imaxima mode 2015/03/10
;; ;;(setq exec-path (cons "/opt/local/bin" exec-path))
;; (autoload 'imaxima "imaxima" "Image support for Maxima." t)

;; ----------------------------------------------------------------------------
;; Geiser
;; ----------------------------------------------------------------------------
(if carbon-p
	(progn
	  (load-file "~/.emacs.d/elpa/geiser-20171217.1353/geiser.el")
	  (setq geiser-active-implementations '(guile sqw-libctl racket chicken))
	  (setq geiser-sqw-binary "/usr/local/bin/sqw-libctl")
	  (setq geisler-scheme-dir "/Users/motohisa/.emacs.d/private/geiser-sqw-libctl/scheme/")
	  ))

;; ----------------------------------------------------------------------------
;; FreeFEM++
;; ----------------------------------------------------------------------------
(if carbon-p
	(progn
;;	  (load-file "~/.emacs.d/lisp/freefem-mode/freefem++-mode.el")
	  (autoload 'freefem++-mode "freefem++-mode"
		"Major mode for editing FreeFem++ code." t)
	  (add-to-list 'auto-mode-alist '("\\.edp$" . freefem++-mode))
	  (add-to-list 'auto-mode-alist '("\\.idp$" . freefem++-mode))
	  ))

;; imaxima (taken from http://www.math.s.chiba-u.ac.jp/~matsu/emacs/emacs23/imaxima.html)
(add-to-list 'load-path "/opt/local/share/maxima/5.36.1/emacs/")
(autoload 'imaxima "imaxima" "Image support for Maxima." t)
(autoload 'imath-mode "imath" "Interactive Math minor mode." t)
(autoload 'maxima "maxima" "Maxima Interatction" t)
(setq imaxima-pt-size 12)
(setq imaxima-latex-preamble "\\usepackage{cmbright}\n")
(setq imaxima-use-maxima-mode-flag t)
(add-to-list 'auto-mode-alist '("\\.ma[cx]" . maxima-mode))

;; autoinsert (taken from )
(require 'autoinsert)
(auto-insert-mode 1)

;;insert 時の問い合わせ無効化
;;(setq auto-insert-query nil)

;; テンプレートのディレクトリ
(setq auto-insert-directory "~/.emacs.d/lisp/insert/")

;; 各ファイルによってテンプレートを切り替える
(setq auto-insert-alist
      (nconc '(
              ("\\.cpp$" . ["template.cpp" my-template])
               ("\\.c$" . ["template.c" my-template])
               ("\\.h$"   . ["template.h" my-template])
			   ("\\.tex$" . ["template.tex" my-template])
			   ("\\.html$" . ["template.html" my-template])
			   ("\\.v$" . ["template.v" my-template])
			   ("\\.py$" . ["template.py" my-template])
;;			   ("\\.ipf$" . ["template.ipf" my-template])
               ) auto-insert-alist))
(require 'cl)

;; ここが腕の見せ所: テンプレート内の置換変数/関数の定義
(defvar template-replacements-alists
  '(("%file%"             . (lambda () (file-name-nondirectory (buffer-file-name))))
    ("%file-without-ext%" . (lambda () (file-name-sans-extension (file-name-nondirectory (buffer-file-name)))))
    ("%include-guard%"    . (lambda () (format "_%s_H" (upcase (file-name-sans-extension (file-name-nondirectory buffer-file-name))))))
	("%date%" . (lambda () (format-time-string "%Y-%m-%d %H:%M:%S")))
	("%year%" . (lambda () (format-time-string "%Y")))
	("%mail%" . (lambda () (identity user-mail-address)))
    ("%name%" . (lambda () (identity user-full-name)))
    ("%id%" . (lambda () (identity user-id-string)))
	))

(defun my-template ()
  (time-stamp)
  (mapc #'(lambda(c)
        (progn
          (goto-char (point-min))
          (replace-string (car c) (funcall (cdr c)) nil)))
    template-replacements-alists)
  (goto-char (point-max))
  (message "done."))
(add-hook 'find-file-not-found-hooks 'auto-insert)

;; Time stamp (taken from seto, github and )
;;;; Time Stamp
;;;   If you put 'Time-stamp: <>' or 'Time-stamp: ""' on
;;;   top 8 lines of the file, the '<>' or '""' are filled with the date
;;;   at saving the file.
;;; 最終更新日の自動挿入
;;;   ファイルの先頭から 8 行以内に Time-stamp: <> または
;;;   Time-stamp: " " と書いてあれば、セーブ時に自動的に日付が挿入される

(require 'time-stamp)
;; (if (not (memq 'time-stamp write-file-functions))
;;     (setq write-file-functions
;;           (cons 'time-stamp write-file-functions)))

;; 日本語で日付を入れたくないのでlocaleをCにする
(defun time-stamp-with-locale-c ()
  (let ((system-time-locale "C"))
    (time-stamp)
    nil))

(if (not (memq 'time-stamp-with-locale-c write-file-hooks))
    (add-hook 'write-file-hooks 'time-stamp-with-locale-c))

(setq time-stamp-format "%3a %3b %02d %02H:%02M:%02S %Z %:y")

;; markdown ; multimarkdown
(if carbon-p
	(setq markdown-command "multimarkdown"))

;; ----------------------------------------------------------------------------
;; lua mode
;; ----------------------------------------------------------------------------
(autoload 'lua-mode "lua-mode" "Lua editing mode." t)
(add-to-list 'auto-mode-alist '("\\.lua$" . lua-mode))
(add-to-list 'interpreter-mode-alist '("lua" . lua-mode))

; Load the LAML Emacs support.
; This fragment has been inserted by the LAML configuration program.
; You can delete it if you do not want it. Do not edit it, however.

;; (load "/Users/motohisa/Documents/programming/schemedoc/emacs-support/laml-emacs-support.el")

; End of LAML Emacs configuration.

;; ;; autolisp mode
;; ;; http://xarch.tu-graz.ac.at/autocad/lsp_tools/ntemacs/autolisp.el
;; ;; https://www.emacswiki.org/emacs/AutoLispMode
;; (autoload 'autolisp-mode "autolisp" "AutoLISP" t)
;; (add-to-list 'auto-mode-alist '("\\.lsp$" . autolisp-mode))

;; arudino-mode
;; https://github.com/bookest/arduino-mode
;; ----------------------------------------------------------------------------
;; arduino-mode
;; ----------------------------------------------------------------------------
; arduino-mode.elへのパス
(add-to-list 'load-path "~/.emacs.d/lisp/arduino-mode")
; arduino-modeのセット
(autoload 'arduino-mode "arduino-mode" "Arduino editing mode." t)
; 拡張子の関連付け
(setq auto-mode-alist (cons '("\\.\\(pde\\|ino\\)$" . arduino-mode) auto-mode-alist))
;; ----------------------------------------------------------------------------

;; ----------------------------------------------------------------------------
;; gmsh mode
;; ----------------------------------------------------------------------------
; 拡張子の関連付け

(autoload 'gmsh-mode "gmsh.el" "Gmsh editing mode." t)
(setq auto-mode-alist (cons '("\\.\\(geo\\|pro\\)$" . gmsh-mode) auto-mode-alist))

;; ----------------------------------------------------------------------------
;; Python-mode
;; ----------------------------------------------------------------------------
(if darwin-p
    (progn
	  (add-to-list 'load-path "~/.emacs.d/lisp/py-autopep8/py-autopep8.el")
	  (require 'py-autopep8)
	  (add-hook 'python-mode-hook
				'(lambda ()
				   (define-key python-mode-map "\C-cF" 'py-autopep8)
				   (define-key python-mode-map "\C-cf" 'py-autopep8-region)  
				   (setq indent-tabs-mode nil)
				   (setq indent-level 4)
				   (setq python-indent 4)
				   (setq tab-width 4)))
	  
;;保存時にバッファ全体を自動整形する
	  (add-hook 'python-mode-hook 'py-autopep8-enable-on-save)
	  ))
