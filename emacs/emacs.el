(setq custom-file "~/.emacs.custom.el")
(load custom-file)
(package-initialize)

(setq --myvar/DEBUG nil)

(add-to-list 'initial-frame-alist '(fullscreen . maximized))

(add-hook 'emacs-lisp-mode-hook (lambda ()
				  (electric-pair-mode)
				  ))

(add-hook 'ink-mode-hook (lambda ()
			   ;; I really dislike ink-mode indentation
			   ;; no editing!
			   (read-only-mode)))

					; (seq-max (mapcar (lambda (x) (length (nth 1 x))) data))
					; bind-key wrapper -> help insertion
					; wrapper groups -> filter
(defun my/emacs-cheats ()
  (interactive)
  (with-output-to-temp-buffer "*emacs-cheats*"
    (mapcar (lambda (tag)
	      (print tag)
	      (print "--------")
	      (mapcar (lambda (element)
			(print (format "%-12s - %s" (nth 1 element) (nth 2 element)))
			)
		      (seq-filter (lambda (x) (string-equal tag (nth 0 x))) --myvar/help)))
	    (seq-uniq (mapcar #'car --myvar/help)))
    )
  
  (display-buffer "*emacs-cheats*")
  )

(setq --myvar/help '(
		     ("BUILTIN" "C-x n s" "Org-narrow to subtree")
		     ("BUILTIN" "C-x n w" "Org-narrow widen to whole tree")
		     ("BUILTIN" "C-x h C-M-\\" "Mark whole buffer & correct indent")
		     ("BUILTIN" "C-c C-x d" "Org Create drawer")
		     ("BUILTIN" "C-x C-f" "find-file aka open")
		     ("BUILTIN" "M-w" "Copy")
		     ("BUILTIN" "C-w" "Cut")
		     ("BUILTIN" "C-y" "Paste")
		     ("BUILTIN" "C-x C-w" "write file")
		     ("BUILTIN" "C-c C-x" "Quit")
		     ("BUILTIN" "C-c C-s"  "Save file")
		     ))

(defun help-set-key (grp keys help fn)
  (push
   (list grp keys help fn)
   --myvar/help
   )
  (global-set-key keys fn))

(help-set-key "CUSTOM" "\C-ch" "emacs-cheats THIS" #'my/emacs-cheats)

					; org-simple-export: (excursion) extract into temporary buffer, replace top-level headline>TITLE, reduce remaining, simplepdf-org callout
					; export :ignore: culling. :noexport: is simplepdf compat
					; cull tags, drawers?
					; Reset xah-reformat-sentences to accomodate styling

(defun my/narrow-out ()
  "function takes current region, if not in a region then current org-subtree, and writes it to specified file"
  (interactive)
					; if-else narrow the buffer save-restriction?
  (let ((bounds (if (buffer-narrowed-p)
		    (cons (point-min) (point-max))
		  (my/org-current-headline-bounds))))
    (write-region (car bounds) (cdr bounds) (read-file-name "Enter File Name: "))
    ))

(defun my/open-folder ()
  "Open current buffer in thunar"
  (interactive)
  (when buffer-file-name
    (message "Opening %s in thunar" buffer-file-name)
    (start-process "thunar" nil "thunar"
                  buffer-file-name)))

(load "~/.emacs.xah.el")
(load "~/.emacs.org.el")
