(defun my/export/safe-map-mutate (analyze mutate &optional match)
  "Safely run mutating org-map-entries does not cover cache-reset. Accessory data from analyze is argument to mutate"
  (goto-char (point-min))
  (let ((points nil))
    (org-map-entries (lambda ()
                       (push (cons (point) (funcall analyze)) points)) ;; analyze can access (point) equally
                     match
                     )
    
    (dolist (pt (sort points (lambda (a b)
                               (> (car a) (car b)))))
      (goto-char (car pt))
      (funcall mutate (cdr pt)) ;; likewise for (point)
      )
    )
  )

(defun my/export/remap-levels ()
  "Normalize headings for 1-rooted 1+ increase"

  (message "Export: Normalizing headings")
  
  (let ((level-map (make-hash-table)))

    (my/export/safe-map-mutate (lambda () ; bake settings
                                 (let* ((hl (car (org-heading-components)))
                                        (hl-parent (save-excursion ; fetch heading above
                                                     (when (org-up-heading-safe)
                                                       (car  (org-heading-components)))
                                                     )
                                                   ))
                                   
                                   (if hl-parent
                                       (puthash hl (+ 1 (gethash hl-parent level-map)) level-map)
                                     (puthash hl 1 level-map)
                                     )
                                   ))

                               (lambda (new-level)
                                 (my/org-set-level new-level)))
    (org-element-cache-reset)
    )
  )

(defun my/export/lift-kill-ignore ()
  ":ignore: promote children & cull lines"

  (message "Export: handling :ignore:")

  (let ((lifters nil)
        )

    (goto-char (point-min))
    (org-map-entries (lambda ()
                       (save-excursion
                         (let ((my-level (car (org-heading-components)))
                               (sublevel nil))
                           (outline-next-heading)
                           (while (and
                                   (not (eobp))
                                   (> (car (org-heading-components)) my-level))
                             
                             (let ((level (car (org-heading-components))))
                               (if sublevel
                                   (when (= sublevel level)
                                     (push (cons  my-level (point)) lifters)) ;; NOTE 1:N queue not compat my/export/safe-map-mutate
                                 (setq sublevel level)
                                 (push (cons my-level (point)) lifters))
                               (outline-next-heading))))))
                     "+ignore")

    ;; level from bottom to top.
    (dolist (lift (sort lifters
                        (lambda (a b)
                          (> (cdr a) (cdr b)))))
      (goto-char (cdr lift))
      (my/org-set-level (car lift)))

    (goto-char (point-min))
    (my/export/safe-map-mutate #'ignore (lambda (_) (org-cut-subtree)) "+ignore")

    (org-element-cache-reset))
  )

(defun my/export/set-title (html-instead-p)
  "Figure out how to render TITLE"

  (message "Export: Setting up title(%s)" (if html-instead-p "html" "pdf"))
  
  (goto-char (point-min))
  (unless (or
           html-instead-p
           (assoc "TITLE" (org-collect-keywords '("TITLE")))
           )
    (message "TITLE line not found, turning heading") ;; Reachable
    (when (re-search-forward org-heading-regexp nil t)
      (let ((title (org-get-heading t t t t)))
        (beginning-of-line)

        (delete-region (line-beginning-position) (line-end-position))
        (insert (format "#+TITLE: %s" title))
	(message "MARK")
	)))

  (org-element-cache-reset)
  )

(defun my/export/cull-high-heads (html-instead-p)
  "Limit heading degrees by removal"

  (message "Export: Culling high headings(%s)" (if html-instead-p "html" "pdf"))
  
  (goto-char (point-min))
  (org-map-entries (lambda ()
                     (when (<=
                            (if html-instead-p 4 3)
                            (car (org-heading-components)))
                       (kill-line))
                     ))

  (org-element-cache-reset)
  )

(defun my/export/cut-comments ()
  "Remove the variety of comment types"

  (message "Export: Cutting comments")
  
  (my/export/safe-map-mutate #'ignore (lambda (_) (org-cut-subtree)) "COMMENT")
  
  ;; Line-level comments
  (goto-char (point-min))
  (flush-lines "^#[^+]")
  (org-element-cache-reset)

  ;; Block comments
  (goto-char (point-min))
  (while (re-search-forward
          "^#\\+begin_comment\\(?:.\\|\n\\)*?^#\\+end_comment\n?"
          nil t)
    (replace-match ""))
  (org-element-cache-reset)
  )
