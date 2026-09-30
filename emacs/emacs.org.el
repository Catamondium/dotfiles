
(require 'olivetti)
(setq-default olivetti-body-width 85)
(setq-default olivetti-style 'fancy)

(add-hook 'org-mode-hook (lambda () ; minor modes
                           (wc-mode)
                           (olivetti-mode)
                           (flyspell-mode)
                           (text-scale-set 1)

                           (keymap-local-unset "C-c C-x C-a") ;; Disable archive binding
                           ))

(with-eval-after-load 'org
  (keymap-unset org-mode-map "C-c C-x C-a") ;; Disable archive binding
  )

(setq-default ispell-dictionary "british")

(setq-default org-startup-folded 'show2levels) ; default folding

                                        ; split over domains? reading/read study/studied ??
(setq org-todo-keywords
      '(
        (sequence "TODO(t)" "REVISE(r)" "REVIEW(v)" "|" "DONE(d)")
        (sequence "|" "CANCELLED(c)")
        ))

(setq org-todo-keyword-faces
      '(
	("TODO" . (:inherit org-todo))
	("REVISE" . (:inherit (:foreground "orange" org-todo)))
	("REVIEW" . (:inherit (:foreground "yellow" org-todo)))
        ("CANCELLED" . (:inherit (:foreground "red" org-done)))
	("DONE" . (:inherit org-done))
        ))

(add-to-list 'auto-mode-alist '("\\.org\\'" . org-mode))
(help-set-key "CUSTOM" "\C-cl" #'org-store-link #'org-store-link)
(help-set-key "CUSTOM" "\C-ca" #'org-agenda #'org-agenda)
(help-set-key "CUSTOM" "\C-cc" #'org-capture #'org-capture)

(setq org-agenda-start-on-weekday 1)

(setq --myvar/replace-table
      '(
        ;;("- " . "  ")
        ("!?" . "‽")
        ("?!" . "‽")
        ;;("..." . "…")
        ))

(defun my/add-replace-special (from to)
  "Add or replace a mapping FROM -> TO in `--myvar/replace-table'."
  (setf (alist-get from --myvar/replace-table nil nil #'string=) to))

(defun my/replace-special (beg end)
  "Semi-safely find-replace by `--myvar/replace-table'"
  (interactive (if (use-region-p)
                   (list (region-beginning) (copy-marker (region-end)))
                 (list (point-min) (copy-marker (point-max)))))

  (let ((count 0))
    (save-excursion
      (dolist (pair --myvar/replace-table)
        (goto-char beg)
        (while (search-forward (car pair) end t)
          (setq count (+ count 1))
          (let ((el (org-element-context)))
            (unless (memq (org-element-type el)
                          '(src-block example-block
                                      code verbatim
                                      link property-drawer))
              (replace-match (cdr pair) t t))))))
    (when (called-interactively-p 'interactive)
      (message "Replaced %d Occurences" count))
    ))

(defun my/count-leaves ()
  "Count leaf headings in the current Org buffer."
  (interactive)
  (let ((count 0))
    (org-map-entries
     (lambda ()
       (unless (save-excursion
                 (let ((level (org-outline-level))
                       (end (save-excursion (org-end-of-subtree t t))))
                   (forward-line 1)
                   (and (re-search-forward org-heading-regexp end t)
                        (> (org-outline-level) level))))
         (cl-incf count))))
    (when (called-interactively-p 'interactive)
      (message "Leaf headings: %d" count))
    count))

(setq org-log-done 'time)
(defun my/new-group (name)
  "untested"
  (let* (
         (char (substring name 0 1))
         (pat (concat "{" char "@.+}"))
         )
    (list
     '(:startgrouptag)
     (list name)
     '(:grouptags)
     (list pat)
     '(:endgrouptag))
    ))

;;(apply 'append (mapcar 'my/new-group '("phil" "writing" "life" "meta")))

(setq org-tag-alist '(

                      (:startgrouptag)
                      ("writing")
                      (:grouptags)
                      ("{w@.+}")
                      (:endgrouptag)

                      (:startgrouptag)
                      ("life")
                      (:grouptags)
                      ("{l@.+}")
                      (:endgrouptag)

                      (:startgrouptag)
                      ("meta")
                      (:grouptags)
                      ("{m@.+}")
                      (:endgrouptag)          

                      ))

(defun my/clean-done ()
  (interactive)
  (org-map-entries
   (lambda ()
     (condition-case nil
         (org-priority ? )
       (user-error nil))
     (org-toggle-tag "FLAGGED" 'off))
   "/DONE"
   'file))

(defun my/org-current-headline-bounds ()
  "Return (START . END) for the current Org headline subtree."
  (save-excursion
    (org-back-to-heading t)
    (let ((start (point)))
      (org-end-of-subtree t t)
      (cons start (point)))))

(defun my/org-set-subtree-min (level)
  (let ((delta (- level (org-current-level))))
    (cond
     ((> delta 0)
      (dotimes (_ delta) (org-demote-subtree)))
     ((< delta 0)
      (dotimes (_ (- delta)) (org-promote-subtree))))))

(defun my/org-set-level (level)
  (let ((delta (- level (org-current-level))))
    (cond
     ((> delta 0)
      (dotimes (_ delta) (org-do-demote)))
     ((< delta 0)
      (dotimes (_ (- delta)) (org-do-promote))))))

(defun my/walk-dirs-filtered (dirs &optional pat)
  "Collect file paths out of list-of-dirs, filtered by pattern (default .*)"
  (flatten-list (mapcar (lambda (item)
                          (directory-files-recursively item (or pat ".*")))
                        dirs)))

(setq org-agenda-files (my/walk-dirs-filtered '("~/org/" "~/git/" "~/Documents/01-interests/") "\\.org$"))

                                        ; org-simple-export: simplepdf-org callout
                                        ; drawers?
                                        ; Reset xah-reformat-sentences to accomodate styling

(defun my/narrow-buffer (buf)
  "function takes current region, if not in a region then current org-subtree"
  (let ((bounds (if (buffer-narrowed-p)
                    (cons (point-min) (point-max))
                  (my/org-current-headline-bounds)
                  )))
    (append-to-buffer buf (car bounds) (cdr bounds))
    ))

(defun my/get-buffer-clean (bufname)
  "Create and return a clean buffer by name, recycling"
  (let ((buf (get-buffer-create bufname)))
    (save-excursion
      (switch-to-buffer buf)
      (erase-buffer)
      buf)))

(defun my/clear-heading ()
  (interactive)
  (save-excursion
    (org-back-to-heading t)
    (org-set-tags nil)
    (condition-case nil
        (org-priority ? )
      (user-error nil))
    (org-todo "")
    ))

(defun my/interactive-barrier (f interactive-p prompt)
  "If called interactively, yes-or-no-p, else call"
  (if interactive-p
      (when (yes-or-no-p prompt)
        (funcall f))
    (funcall f)))

(defun my/cull-property-drawers (beg end)
  "Remove all Org property drawers from the current buffer after confirmation."
  (interactive (if (use-region-p)
                   (list (region-beginning) (copy-marker (region-end)))
                 (list (point-min) (copy-marker (point-max)))))

  (my/interactive-barrier 
   (lambda ()
     (save-excursion
       (goto-char beg)
       (while (re-search-forward
               "^[ \t]*:PROPERTIES:[ \t]*\n\\(?:.*\n\\)*?[ \t]*:END:[ \t]*$"
               end t)
         (replace-match "")))
     (message "All property drawers removed."))
   (called-interactively-p 'any)
   "Remove property drawers from this buffer? "
   )
  )

(load "~/.emacs.export.el")
(defun my/simple-export (file)

  (interactive
   (list
    (read-file-name "Enter File Name: ")
    ))

  (save-excursion
    (org-fold-core-ignore-modifications
      (let* (
             (xbuf (my/get-buffer-clean " *org-simple-export*"))
             (case-fold-search t)
             (html-instead-p (string-match ".html$" file))
             )
	;; TODO rework target-region selection
	;; tag | narrow | cursor-parent (?) | entire-document ?
        (my/narrow-buffer xbuf) ; incapable of whole docs
        (switch-to-buffer xbuf)
        (org-mode)

        ;; Not-yet-needed: schedule & :properties: & :logbook: removal & handling
        ;; MAY occur with trackbear integration == ids

        (message "Export: Handling :noexport:")

        (my/cull-property-drawers (point-min) (point-max))
        
        (my/export/safe-map-mutate #'ignore (lambda (_)  (org-cut-subtree)) "+noexport")
        (my/export/lift-kill-ignore) ;; BROKEN by new environment
        (my/export/cut-comments)

        (message "Export: Cleaning headings")
        
        (goto-char (point-min))
        (org-map-entries #'my/clear-heading)

        (my/export/set-title html-instead-p)
        (my/export/remap-levels)
        (my/export/cull-high-heads html-instead-p)
        
        (let* ((outfile (expand-file-name file))
               (emit-format (if html-instead-p "html" "pdf"))
               (infile (concat (file-name-sans-extension outfile) ".org")))

          (message "Export: Exporting to pandoc(%s): %s -> %s" emit-format infile outfile)
          
          (write-file infile t)
          (call-process "pandoc" nil nil nil
                        "-f" "org" "-t" emit-format
                        infile
                        "-o" outfile
                        "--pdf-engine" "weasyprint"
                        )


          (message "Export: Taking statistics")
          
          (when (called-interactively-p 'any)
            (goto-char (point-min))
            (let* ((bleaves (my/count-leaves))
                   (leaves (if (= 0 bleaves) 1 bleaves)) ;; count TITLE
                   (headings (+ 
                              (length (org-map-entries (lambda () t)))
                              (if html-instead-p 0 1) ;; count TITLE
                              ))
                   (words (count-words (point-min) (point-max)))
                   (avg-words (ceiling (/ words leaves))))
              (message "Exported H: %d/%d W: %d/%d" leaves headings avg-words words)
              ))
          
          (unless --myvar/DEBUG
            (delete-file infile))

          (unless --myvar/DEBUG
            (kill-buffer xbuf)))
        ))
    ))

                                        ; Sinolit?
(setq org-agenda-custom-commands
      '(
        ("o" . "other major tags")
        ("ol" tags-todo "life")
        ("om" tags-todo "meta")
        
        ("w" tags-todo "w@works")
        ("c" tags-todo "w@courses")

        ("f" . "flagged items")
        ("ft" tags-todo "FLAGGED")
        ("ff" tags "FLAGGED")

        ("F" "flag blocks"
         ((agenda "")
          (tags-todo "+life+FLAGGED")
          (tags-todo "+writing+FLAGGED")
          ))

        ("r" . "readings blocks")
        ("rt" "todo readings"
         ((agenda "")
          (tags-todo "+w@reading+FLAGGED")
          (tags-todo "+w@reading-FLAGGED")
          ))
        ("rr" "all readings"
         ((agenda "")
          (tags "+w@reading+FLAGGED")
          (tags "+w@reading-FLAGGED")
          ))
        
        ))
