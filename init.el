;; put all customize-related code into separate file instead of init.el
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror)

(setq package-archives '(
			 ("GNU ELPA"     . "https://elpa.gnu.org/packages/")
			 ("MELPA"        . "https://melpa.org/packages/")
			 ("ORG"          . "https://orgmode.org/elpa/")
			 ("MELPA Stable" . "https://stable.melpa.org/packages/")
			 ("nongnu"       . "https://elpa.nongnu.org/nongnu/")
			 )
      package-archive-priorities '(
				   ("GNU ELPA"     . 20)
				   ("MELPA"        . 15)
				   ("ORG"          . 10)
				   ("MELPA Stable" . 5)
				   ("nongnu"       . 0)
				   )
      )
(package-initialize)

;; refresh package contents before any installation
(defun my/package-refresh-before-install (orig-fun &rest args)
  (package-refresh-contents)
  (apply orig-fun args))
(advice-add 'package-install :around #'my/package-refresh-before-install)

(use-package gnu-elpa-keyring-update :ensure t :defer t)

(use-package no-littering :ensure t :defer nil)

;; (load "~/.emacs.d/leaf-dark-theme.el")
;; (load-theme 'leaf-dark t)


(use-package ef-themes
  :ensure t

  :init
  ;; This makes the Modus commands listed below consider only the Ef
  ;; themes.  For an alternative that includes Modus and all
  ;; derivative themes (like Ef), enable the
  ;; `modus-themes-include-derivatives-mode' instead.  The manual of
  ;; the Ef themes has a section that explains all the possibilities:
  ;;
  ;; - Evaluate `(info "(ef-themes) Working with other Modus themes or taking over Modus")'
  ;; - Visit <https://protesilaos.com/emacs/ef-themes#h:6585235a-5219-4f78-9dd5-6a64d87d1b6e>
  (ef-themes-take-over-modus-themes-mode t)

  :bind
  (
   ;; ("<f5>" . modus-themes-rotate)
   ("C-<f5>" . modus-themes-select)
   ("M-<f5>" . modus-themes-load-random)
   )

  :config
  ;; All customisations here.
  (setq modus-themes-mixed-fonts t)
  (setq modus-themes-italic-constructs t)

  ;; Finally, load your theme of choice (or a random one with
  ;; `modus-themes-load-random', `modus-themes-load-random-dark',
  ;; `modus-themes-load-random-light').
  (modus-themes-load-theme 'ef-elea-dark)
  )

;; when opening files with emacsclient, use existing emacs window
(use-package server
  :ensure nil
  :config
  (unless (server-running-p) (server-start)))

(setq blink-cursor-mode nil)
(setq inhibit-startup-screen t)
(setq column-number-mode t)
(setq display-line-numbers t)
(setq initial-buffer-choice t)
(global-display-line-numbers-mode)
(cua-mode)
(global-auto-revert-mode t)
(global-set-key (kbd "<f5>") #'revert-buffer)
(setq use-short-answers t)  ;; use y/n instead of yes/no when prompted
(tool-bar-mode -1)
(frame-parameter nil 'client) ;; fix KDE window grouping when using emacsclient and pinning

(setq scroll-conservatively 10
      scroll-margin 15)

;; advanced autocompletion
(use-package corfu
  :ensure t)

(use-package emacs
  :custom

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)

  ;; Emacs 30 and newer: Disable Ispell completion function.
  ;; Try `cape-dict' as an alternative.
  (text-mode-ispell-word-completion nil)

  ;; Hide commands in M-x which do not apply to the current mode.  Corfu
  ;; commands are hidden, since they are not used via M-x. This setting is
  ;; useful beyond Corfu.
  (read-extended-command-predicate #'command-completion-default-include-p))

(use-package ibuffer
  :ensure nil

  :custom
  (ibuffer-never-show-predicates '("^\\*"))

  :hook
  (ibuffer-mode . ibuffer-auto-mode)

  :config
  (setq ibuffer-saved-filter-groups
        '(("default"
           ("Org" (mode . org-mode))
           ("Programming" (derived-mode . prog-mode))
           ("Dired" (mode . dired-mode)))))
  (add-hook 'ibuffer-mode-hook
            (lambda ()
              (ibuffer-switch-to-saved-filter-groups "default")))
  )

(use-package ibuffer-sidebar
  :ensure t
  :demand t

  :bind
  (("C-c b" . ibuffer-sidebar-toggle-sidebar))

  :config
  (setq ibuffer-sidebar-width 28)
  (ibuffer-sidebar-show-sidebar)
  (add-hook 'server-after-make-frame-hook #'ibuffer-sidebar-show-sidebar)

  )

(use-package blamer
  :ensure t
  :defer t

  :bind
  (("C-c g" . blamer-mode))

  )

(use-package breadcrumb
  :ensure t
  :config
  (breadcrumb-mode t)
  )


(with-eval-after-load 'dired
  (define-key dired-mode-map [mouse-2] #'dired-find-file))


;; (setq auto-save-list-file-prefix "~/.emacs.d/autosave/")
;; (setq auto-save-file-name-transforms  '((".*" "~/.emacs.d/autosave/" t)))

;;configure LSP-related things

(use-package markdown-mode :ensure t :defer t)
(use-package dotenv-mode :ensure t :defer t)

(use-package color :defer t)

(defun my/csv-highlight (&optional separator)
  (interactive (list (when current-prefix-arg (read-char "Separator: "))))
  (font-lock-mode 1)
  (let* ((separator (or separator ?\,))
         (n (count-matches (string separator) (pos-bol) (pos-eol)))
         (colors (cl-loop for i from 0 to 1.0 by (/ 2.0 n)
                          collect (apply #'color-rgb-to-hex
                                         (color-hsl-to-rgb i 0.3 0.5)))))
    (cl-loop for i from 2 to n by 2
             for c in colors
             for r = (format "^\\([^%c\n]+%c\\)\\{%d\\}" separator separator i)
             do (font-lock-add-keywords nil `((,r (1 '(face (:foreground ,c)))))))))

(use-package csv-mode
  :ensure t
  :defer t

  :hook
  (csv-mode . my/csv-highlight)
  )

(use-package treesit-auto
  :ensure t

  :config
  (global-treesit-auto-mode)

  :custom
  (treesit-auto-install 'prompt)
  )

(use-package eglot
  :ensure t
  :defer t

  :hook (prog-mode . eglot-ensure)

  :config
  ;; (add-to-list 'eglot-server-programs
  ;; 	       `(python-ts-mode . ,(eglot-alternatives '(("pylsp" "--check-parent-process")))))

  (add-to-list 'eglot-server-programs
               '(python-ts-mode . ("basedpyright-langserver" "--stdio")))

  (add-to-list 'eglot-server-programs
               '(json-ts-mode . ("vscode-json-languageserver" "--stdio"
				 :initializationOptions (:provideFormatter t))))

  (setq-default eglot-workspace-configuration
		'(
		  ;; basedpyright-langserver
		  ;; official config from docs does not work, solution from here
		  ;; https://github.com/mwolson/eglot-python-preset/tree/main/#workspace-configuration-basedpyright
		  :basedpyright.analysis
		  (:diagnosticSeverityOverrides
		   (
		    :reportAny "none"
		    :reportImplicitStringConcatenation "none"
		    :reportImplicitAbstractClass "hint"
		    )
		   )

		  ;; vscode-json-language-server
		  :json.format
		  (:enable t
			   :tabSize 2
			   :insertSpaces t
			   :indentSize 2
			   :insertFinalNewline t
			   :keepLines :json-false)

		  :json.validate
		  (:enable t)))
  )

(add-hook 'write-file-hooks 'delete-trailing-whitespace)


(use-package apheleia
  :ensure t
  :defer nil

  :config

  (setf (alist-get 'isort apheleia-formatters)
        '("isort"
          "--line-length" "120"
          "--no-sections"
          "--order-by-type"
          "--lines-between-types" "1"
          "--lines-after-imports" "2"
          "-"))

  (setf (alist-get 'autopep8 apheleia-formatters)
        '("autopep8"
          "--max-line-length" "160"
          "-"))

  (setf (alist-get 'python-ts-mode apheleia-mode-alist) '(autopep8 isort))

  (setf (alist-get 'prettier apheleia-formatters)
        '("prettier" "--stdin-filepath" filepath))
  (setf (alist-get 'json-ts-mode apheleia-mode-alist) '(prettier))

  (apheleia-global-mode t)

  )

(global-set-key (kbd "C-/") #'comment-line)
