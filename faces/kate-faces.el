;;; kate-faces.el --- Extra faces and highlighting -*- lexical-binding: t -*-

(defface kate-import-face '((t :foreground "#27ae60")) "Import keywords.")

(defun kate-faces--python-ts-imports ()
  (setq-local treesit-font-lock-settings
	      (append treesit-font-lock-settings
		      (treesit-font-lock-rules
		       :language 'python :feature 'import :override t
		       '((import_statement "import" @kate-import-face)
			 (import_from_statement ["from" "import"] @kate-import-face)
			 (future_import_statement ["from" "import"] @kate-import-face)))))
  (treesit-font-lock-recompute-features '(import))
  (font-lock-flush))

(add-hook 'python-ts-mode-hook #'kate-faces--python-ts-imports)

(font-lock-add-keywords 'python-mode
			'(("^\\s-*\\_<\\(from\\|import\\)\\_>" 1 'kate-import-face t)
			  ("\\_<from\\_>.*\\_<\\(import\\)\\_>" 1 'kate-import-face t)))

(provide 'kate-faces)
;;; kate-faces.el ends here
