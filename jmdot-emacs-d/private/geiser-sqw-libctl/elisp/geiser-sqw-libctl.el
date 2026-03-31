;; geiser-sqw-libctl.el -- sqw-libctl's implementation of the geiser protocols
;; based on geisler-scsh.el

;; Copyright (C) 2015, Junichi Motohisa
;; Copyright (C) 2009, 2010, 2011, 2012, 2013 Jose Antonio Ortega Ruiz
;; Copyright (C) 2013, 2014 Rich Loveland

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the Modified BSD License. You should
;; have received a copy of the license along with this program. If
;; not, see <http://www.xfree86.org/3.3.6/COPYRIGHT2.html#5>.

(require 'geiser-connection)
(require 'geiser-syntax)
(require 'geiser-custom)
(require 'geiser-base)
(require 'geiser-eval)
(require 'geiser-edit)
(require 'geiser-log)
(require 'geiser)

(require 'compile)
(require 'info-look)

(eval-when-compile (require 'cl))

;;; Customization:

(defgroup geiser-sqw-libctl nil
  "Customization for Geiser's sqw-libctl flavour."
  :group 'geiser)

(geiser-custom--defcustom geiser-sqw-libctl-binary
  (cond ((eq system-type 'windows-nt) "sqw-libctl.exe")
        ((eq system-type 'darwin) "sqw-libctl")
        (t "sqw-libctl"))
  "Name to use to call the sqw-libctl executable when starting a REPL."
  :type '(choice string (repeat string))
  :group 'geiser-sqw-libctl)

(geiser-custom--defcustom geiser-sqw-libctl-load-path nil
  "A list of paths to be added to sqw-libctl's load path when it's
started."
  :type '(repeat file)
  :group 'geiser-sqw-libctl)

(geiser-custom--defcustom geiser-sqw-libctl-init-file "~/.sqw-libctl"
  "Initialization file with user code for the sqw-libctl REPL.
If all you want is to load ~/.sqw-libctl, set
`geiser-sqw-libctl-load-init-file-p' instead."
  :type 'string
  :group 'geiser-sqw-libctl)

(geiser-custom--defcustom geiser-sqw-libctl-load-init-file-p nil
  "Whether to load ~/.sqw-libctl when starting sqw-libctl.
Note that, due to peculiarities in the way sqw-libctl loads its init
file, using `geiser-sqw-libctl-init-file' is not equivalent to setting
this variable to t."
  :type 'boolean
  :group 'geiser-sqw-libctl)



(geiser-custom--defcustom geiser-sqw-libctl-debug-show-bt-p nil
  "Whether to autmatically show a full backtrace when entering the debugger.
If `nil', only the last frame is shown."
  :type 'boolean
  :group 'geiser-sqw-libctl)

(geiser-custom--defcustom geiser-sqw-libctl-jump-on-debug-p nil
  "Whether to autmatically jump to error when entering the debugger.
If `t', Geiser will use `next-error' to jump to the error's location."
  :type 'boolean
  :group 'geiser-sqw-libctl)

(geiser-custom--defcustom geiser-sqw-libctl-show-debug-help-p nil
  "Whether to show brief help in the echo area when entering the debugger."
  :type 'boolean
  :group 'geiser-sqw-libctl)

(geiser-custom--defcustom geiser-sqw-libctl-warning-level 'none
  "Verbosity of the warnings reported by sqw-libctl.

You can either choose one of the predefined warning sets, or
provide a list of symbols identifying the ones you want. Possible
choices are arity-mismatch, unbound-variable, unused-variable and
unused-toplevel. Unrecognised symbols are ignored.

The predefined levels are:

  - Medium: arity-mismatch, unbound-variable, format
  - High: arity-mismatch, unbound-variable, unused-variable, format
  - None: no warnings

Changes to the value of this variable will automatically take
effect on new REPLs. For existing ones, use the command
\\[geiser-sqw-libctl-update-warning-level]."
  :type '(choice (const :tag "Medium (arity and unbound vars)" medium)
                 (const :tag "High (also unused vars)" high)
                 (const :tag "No warnings" none)
                 (repeat :tag "Custom" symbol))
  :group 'geiser-sqw-libctl)

(geiser-custom--defcustom geiser-sqw-libctl-extra-keywords nil
  "Extra keywords highlighted in sqw-libctl scheme buffers."
  :type '(repeat string)
  :group 'geiser-sqw-libctl)

(geiser-custom--defcustom geiser-sqw-libctl-case-sensitive-p t
  "Non-nil means keyword highlighting is case-sensitive."
  :type 'boolean
  :group 'geiser-sqw-libctl)

(geiser-custom--defcustom geiser-sqw-libctl-manual-lookup-other-window-p nil
  "Non-nil means pop up the Info buffer in another window."
  :type 'boolean
  :group 'geiser-sqw-libctl)

(geiser-custom--defcustom geiser-sqw-libctl-manual-lookup-nodes nil
  "List of info nodes that, when present, are used for manual lookups"
  :type '(repeat string)
  :group 'geiser-sqw-libctl)



;;; REPL support:

(defun geiser-sqw-libctl--binary ()
  (if (listp geiser-sqw-libctl-binary)
      (car geiser-sqw-libctl-binary)
    geiser-sqw-libctl-binary))

(defun geiser-sqw-libctl--parameters ()
  "Return a list with all parameters needed to start sqw-libctl.
This function uses `geiser-sqw-libctl-init-file' if it exists."
  '())

(defvar geiser-sqw-libctl--prompt-regexp "^[0-9]?> ")
(defvar geiser-sqw-libctl--debugger-prompt-regexp "^inspect: ")

;; This addition to the Scheme syntax table is necessary to support
;; sqw-libctl's pipe notation.
(modify-syntax-entry ?| "_ p" scheme-mode-syntax-table)

(defun geiser-sqw-libctl--syntax-in-filename-p ()
  (save-excursion
    (let ((val (re-search-backward "\\( +~\\| +/\\)" nil t 1)))
      val)))

(defun geiser-sqw-libctl--completion-for-filename ()
  (when (geiser-sqw-libctl--syntax-in-filename-p)
    (let ((comint-completion-addsuffix "\""))
      (comint-dynamic-complete-filename))))

;; ++ We override this internal geiser function to add
;; `geiser-sqw-libctl--completion-for-filename'.  This allows us to complete
;; on filenames that are not surrounded double quotes, as used in the
;; sqw-libctl process notation.
(defun geiser-completion--setup (enable)
  (set (make-local-variable 'completion-at-point-functions)
       (if enable
           '(geiser-completion--for-symbol
             geiser-completion--for-module
	     geiser-sqw-libctl--completion-for-filename
             geiser-completion--for-filename)
         (default-value 'completion-at-point-functions))))

;;; Evaluation support:

(defsubst geiser-sqw-libctl--linearize-args (args)
  (mapconcat 'identity args " "))

(defun geiser-sqw-libctl--geiser-procedure (proc &rest args)
  (let ((linearized-cdr-args (geiser-sqw-libctl--linearize-args (cdr args)))
	(linearized-args (geiser-sqw-libctl--linearize-args args)))
  (case proc
    ((eval compile)
     (cond ((string-match "ge:completions" linearized-cdr-args)
	    (format "(ge:eval '%s 'NIL)" linearized-cdr-args))
	   ((string-match "ge:macroexpand" linearized-cdr-args)
	    (format "(ge:eval '%s 'NIL)" linearized-cdr-args))
	   (t (format "(ge:eval (quote %s) 'NIL)" linearized-cdr-args))))
    ((load-file compile-file) (format ",load %s" (car args)))
    ((no-values) "")
    (t (format "(ge:%s %s)" proc linearized-args)))))

(defvar geiser-sqw-libctl--module-re
  "scheme48-package: +(\\([a-z\-]+\\))")

(defvar geiser-sqw-libctl--library-re geiser-sqw-libctl--module-re)

(defun geiser-sqw-libctl--get-module (&optional module)
  (cond ((null module)
         (save-excursion
           (ignore-errors
             (while (not (zerop (geiser-syntax--nesting-level)))
               (backward-up-list)))
           (if (or (re-search-backward geiser-sqw-libctl--module-re nil t)
                   (looking-at geiser-sqw-libctl--library-re)
                   (re-search-forward geiser-sqw-libctl--module-re nil t))
               (geiser-sqw-libctl--get-module (match-string-no-properties 1))
             :f)))
        ((listp module) module)
        ((stringp module)
         (condition-case nil
             (car (geiser-syntax--read-from-string module))
           (error :f)))
        (t :f)))



(defun geiser-sqw-libctl--module-cmd (module fmt &optional def)
  (when module
    (let* ((module (geiser-sqw-libctl--get-module module))
           (module (cond ((or (null module) (eq module :f)) def)
                         (t (format "%s" module)))))
      (and module (format fmt module)))))

(defun geiser-sqw-libctl--import-command (module)
  (geiser-sqw-libctl--module-cmd module ",open %s"))

(defun geiser-sqw-libctl--enter-command (module)
  (let ((cmd (if (string-equal module "user")
		 ",user"
	       ",in %s")))
    (geiser-sqw-libctl--module-cmd module cmd module)))

(defun geiser-sqw-libctl--exit-command () ",exit")

(defun geiser-sqw-libctl--symbol-begin (module)
  (if module
      (max (save-excursion (beginning-of-line) (point))
           (save-excursion (skip-syntax-backward "^(>") (1- (point))))
    (save-excursion (skip-syntax-backward "^-()>") (point))))

;;; Error display

(defun geiser-sqw-libctl--enter-debugger ()
  (let ((bt-cmd (format ",condition\n,debug\n")))
    (compilation-forget-errors)
    (goto-char (point-max))
    (geiser-repl--prepare-send)
    (comint-send-string nil bt-cmd)
    (when geiser-sqw-libctl-show-debug-help-p nil)
    (when geiser-sqw-libctl-jump-on-debug-p
      (accept-process-output (get-buffer-process (current-buffer))
                             0.2 nil t)
      (ignore-errors (next-error)))))

(defun geiser-sqw-libctl--display-error (module key msg)
  (newline)
  (when (stringp msg)
    (save-excursion (insert msg))))

(defvar geiser-sqw-libctl--guess-re
  (format "\\(%s\\|#![a-z/]+sqw-libctl\\( *\\\\\\)?\\)"
          geiser-sqw-libctl--module-re))

(defun geiser-sqw-libctl--guess ()
  (save-excursion
    (goto-char (point-min))
    (re-search-forward
     geiser-sqw-libctl--guess-re
     nil t)))

(defun geiser-sqw-libctl--keywords ()
  (when geiser-sqw-libctl-extra-keywords
    `((,(format "[[(]%s\\>" (regexp-opt geiser-sqw-libctl-extra-keywords 1))
       . 1))))



(geiser-syntax--scheme-indent
 (c-declare 0)
 (c-lambda 2)
 (lambda* 1)
 (pmatch defun)
 (sigaction 1)
 (with-fluid* 1)
 (with-fluids 1)
 (with-fluids* 1)
 (with-method 1)
 (dynamic-wind 0)

 ;; Scheme 48
 (destructure 1)
 (enum-case 2)
 (environment-define! 2 no-font-lock)
 (environment-set! 2 no-font-lock)
 (guard 1)
 (iterate 3)
 (make-usual-resumer 2 no-font-lock)
 (mvlet 1)
 (mvlet* 1)
 (search-tree-modify! 2 no-font-lock)
 (usual-resumer 0 no-font-lock)
 (with-exception-handler 1)
 (with-handler 1)
 (with-interaction-environment 1)
 (with-nondeterminism 0)

 ;; I/O-related
 (call-with-current-input-port 1)
 (call-with-current-noise-port 1)
 (call-with-current-output-port 1)
 (call-with-string-output-port 0)
 (limit-output 2 no-font-lock)
 (recurring-write 2 no-font-lock)
 (silently 0)
 (with-current-ports 3)

 ;; Configuration language
 (define-interface 1)
 (define-structure 2)
 (structure 1)
 (structures 1)

 ;; Concurrency-related
 (atomically 0)
 (atomically! 0)
 (call-ensuring-atomicity 0)
 (call-ensuring-atomicity! 0)
 (ensure-atomicity 0)
 (ensure-atomicity! 0)
 (interrupt-thread 1 no-font-lock)
 (let-fluid 2)
 (let-fluids defun)
 (spawn-on-scheduler 1 no-font-lock)
 (with-new-proposal 1)



 ;; sqw-libctl
 (with-current-input-port 2)
 (with-current-output-port 2)
 (awk 3)
 (close-after 2 no-font-lock)
 (if-match 2)
 (with-cwd 1)
 (with-cwd* 1)

 ;; Others
 (let-optionals scheme-let-indent)
 (let-optionals* scheme-let-indent)

 ;; SRFI-2
 (and-let* 1)

 ;; SRFI-8
 (receive 2)

 ;; SRFI-11
 (let-values 1)
 (let*-values 1))

;;; Compilation shell regexps

(defvar geiser-sqw-libctl--path-rx "^In \\([^:\n ]+\\):\n")

(defvar geiser-sqw-libctl--rel-path-rx "^In +\\([^/\n :]+\\):\n")

(defvar geiser-sqw-libctl--file-cache (make-hash-table :test 'equal))

(defun geiser-sqw-libctl--resolve-file (file)
  (when (and (stringp file)
             (not (member file '("socket" "stdin" "unknown file"))))
    (if (file-name-absolute-p file) file
      (or (gethash file geiser-sqw-libctl--file-cache)
          (puthash file
                   (geiser-eval--send/result `(:eval (:ge find-file ,file)))
                   geiser-sqw-libctl--file-cache)))))

(defun geiser-sqw-libctl--resolve-file-x ()
  (let ((f (geiser-sqw-libctl--resolve-file (match-string-no-properties 1))))
    (and (stringp f) (list f))))

;;; REPL startup

(defun geiser-sqw-libctl-update-warning-level ()
  "Update the warning level used by the REPL.
The new level is set using the value of `geiser-sqw-libctl-warning-level'."
  (interactive)
  (let ((code `(:eval (:ge set-warnings ',geiser-sqw-libctl-warning-level)
                      (geiser evaluation))))
    (geiser-eval--send/result code)))

(defun geiser-sqw-libctl--set-load-path ()
  (let* ((code (if geiser-sqw-libctl-load-path
		   `(begin (for-each (lambda (path)
				       (lib-dirs-append! path))
				     (quote ,geiser-sqw-libctl-load-path))
			   'done)
		 `(quote ()))))
    (geiser-eval--send/wait code)))



(defun geiser-sqw-libctl--startup (remote)
  (set (make-local-variable 'compilation-error-regexp-alist)
       `((,geiser-sqw-libctl--path-rx geiser-sqw-libctl--resolve-file-x)
         ("^  +\\([0-9]+\\):\\([0-9]+\\)" nil 1 2)))
  (compilation-setup t)
  (font-lock-add-keywords nil
                          `((,geiser-sqw-libctl--path-rx 1
						   compilation-error-face)))
  (let* ((geiser-log-verbose-p t)
	 (path (expand-file-name "sqw-libctl/geiser/" geiser-scheme-dir))
	 (load-geiser-cmd (format ",translate =geiser-sqw-libctl-dir/ %s" path))
	 (load-init-file-cmd (concat ",user ,load " (expand-file-name geiser-sqw-libctl-init-file)))
	 (load-cmd ",exec ,load =geiser-sqw-libctl-dir/load.scm"))
    (geiser-sqw-libctl--set-load-path)
    (geiser-eval--send/wait load-geiser-cmd)
    (if geiser-sqw-libctl-load-init-file-p (geiser-eval--send/wait load-init-file-cmd))
    (geiser-eval--send/wait load-cmd 5)))

;;; Manual lookup

(defun geiser-sqw-libctl--info-spec (&optional nodes)
  (let* ((nrx "^[ 	]+-+ [^:]+:[ 	]*")
         (drx "\\b")
         (res (when (Info-find-file "r5rs" t)
                `(("(r5rs)Index" nil ,nrx ,drx)))))
    (dolist (node (or nodes geiser-sqw-libctl-manual-lookup-nodes) res)
      (when (Info-find-file node t)
        (mapc (lambda (idx)
                (add-to-list 'res
                             (list (format "(%s)%s" node idx) nil nrx drx)))
              '("Index"))))))

(info-lookup-add-help :topic 'symbol :mode 'geiser-sqw-libctl-mode
                      :ignore-case nil
                      :regexp "[^()`',\" 	\n]+"
                      :doc-spec (geiser-sqw-libctl--info-spec))

(defun sqw-libctl--manual-look-up (id mod)
  (let ((info-lookup-other-window-flag
         geiser-sqw-libctl-manual-lookup-other-window-p))
    (info-lookup-symbol id 'geiser-sqw-libctl-mode))
  (when geiser-sqw-libctl-manual-lookup-other-window-p
    (switch-to-buffer-other-window "*info*"))
  (search-forward (format "%s" id) nil t))

;; ++ We override this internal geiser function so that geiser can
;; connect to sqw-libctl.  The original function inserts newlines into the
;; regular expression used by the `tq' package to determine where
;; sqw-libctl's process output ends.  Unfortunately, the resulting regex
;; doesn't match sqw-libctl's output; thus `tq' never knows that sqw-libctl's
;; output is ready, and the REPL hangs.
(defun geiser-con--connection-eot-re (prompt debug)
  (geiser-con--combined-prompt (format "%s" prompt)
                               (and debug (format "%s" debug))))



;; ++ We override this internal variable because its default value,
;; `nil', was being passed to `funcall', which was making Emacs
;; unhappy.
(setq geiser-eval--get-module-function #'geiser-sqw-libctl--get-module)

;;; Support for the sqw-libctl/s48 disassembler

(defun geiser-sqw-libctl-disassemble-region (start end)
  ;; Int Int -> State!
  "Disassemble the sqw-libctl code in the region between START and END.
Opens a new buffer with the output of the disassembler."
  (interactive "r")
  (let* ((str (buffer-substring-no-properties start end)))
    (geiser-sqw-libctl--really-disassemble str)))

(defun geiser-sqw-libctl-disassemble-thing-at-point ()
  ;; -> State!
  "Disassemble the sqw-libctl symbol at point.
Opens a new buffer with the output of the disassembler."
  (interactive)
  (let* ((it (thing-at-point 'symbol)))
    (geiser-sqw-libctl--really-disassemble it)))

;; ++ The way we construct the sqw-libctl code and fiddle with regexps here
;; is a kludge.
(defun geiser-sqw-libctl--really-disassemble (str)
  ;; String -> State!
  (let* ((code (concat "(ge:disassemble " str ")"))
	 (ret (geiser-eval--send/wait code))
	 (raw (cdr (assoc 'output ret)))
	 (pass1 (replace-regexp-in-string "#f" "" raw))
	 (pass2 (replace-regexp-in-string "^> " "" pass1))
	 (bufname "* Sqw-Libctl Disassembler Output *"))
    (with-output-to-temp-buffer bufname
      (princ pass2))))

;;; Implementation definition:

(define-geiser-implementation sqw-libctl
  (arglist geiser-sqw-libctl--parameters)
  (repl-startup geiser-sqw-libctl--startup)
  (enter-debugger geiser-sqw-libctl--enter-debugger)
  (external-help sqw-libctl--manual-look-up)
  (binary geiser-sqw-libctl--binary)
  (prompt-regexp geiser-sqw-libctl--prompt-regexp)
  (debugger-prompt-regexp geiser-sqw-libctl--debugger-prompt-regexp)
  (find-module geiser-sqw-libctl--get-module)
  (enter-command geiser-sqw-libctl--enter-command)
  (exit-command geiser-sqw-libctl--exit-command)
  (import-command geiser-sqw-libctl--import-command)
  (find-symbol-begin geiser-sqw-libctl--symbol-begin)
  (display-error geiser-sqw-libctl--display-error)
  (check-buffer geiser-sqw-libctl--guess)
  (marshall-procedure geiser-sqw-libctl--geiser-procedure)
  (keywords geiser-sqw-libctl--keywords)
  (case-sensitive geiser-sqw-libctl-case-sensitive-p))

(geiser-impl--add-to-alist 'regexp "\\.scm$" 'sqw-libctl t)

(provide 'geiser-sqw-libctl)

;; geiser-sqw-libctl.el ends here
