;;; load.scm -- run at geiser-sqw-libctl REPL startup

;; Copyright (C) 2013, 2014 Rich Loveland

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the Modified BSD License. You should
;; have received a copy of the license along with this program. If
;; not, see <http://www.xfree86.org/3.3.6/COPYRIGHT2.html#5>.

;;++ See geiser-sqw-libctl.el for the value of =geiser-sqw-libctl-dir.
(config '(load "=geiser-sqw-libctl-dir/interfaces.scm"
               "=geiser-sqw-libctl-dir/packages.scm"
	       "=geiser-sqw-libctl-dir/apropos.scm"))

;;++ Load the geiser packages in the correct (dependency) order.
(load-package 'geiser-utils)
(load-package 'geiser-modules)
(load-package 'geiser-evaluation)
(load-package 'geiser-doc)
(load-package 'geiser-completion)
(load-package 'geiser-xref)
(load-package 'geiser-emacs)
(load-package 'apropos)

(user)

(open 'geiser-utils)
(open 'geiser-modules)
(open 'geiser-evaluation)
(open 'geiser-doc)
(open 'geiser-completion)
(open 'geiser-xref)
(open 'geiser-emacs)
(open 'apropos)

;; load.scm ends here
