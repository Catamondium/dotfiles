(defun xah-reformat-to-sentence-lines ()
  "Reformat current block or selection into multiple lines by ending period.
Move cursor to the beginning of next text block.
After this command is called, press `xah-repeat-key' to repeat it.

URL `http://xahlee.info/emacs/emacs/elisp_reformat_to_sentence_lines.html'
Created: 2020-12-02
Version: 2025-03-25"
  (interactive)
  (let (xbeg xend)
    (seq-setq (xbeg xend) (if (region-active-p) (list (region-beginning) (region-end)) (list (save-excursion (if (re-search-backward "\n[ \t]*\n" nil 1) (match-end 0) (point))) (save-excursion (if (re-search-forward "\n[ \t]*\n" nil 1) (match-beginning 0) (point))))))
    (save-restriction
      (narrow-to-region xbeg xend)
      (goto-char (point-min)) (while (search-forward "。" nil t) (replace-match "。\n"))
      ;; (goto-char (point-min)) (while (search-forward " <a " nil t) (replace-match "\n<a "))
      ;; (goto-char (point-min)) (while (search-forward "</a> " nil t) (replace-match "</a>\n"))
      (goto-char (point-min))
      (while (re-search-forward "\\([A-Za-z0-9]+\\)[ \t]*\n[ \t]*\\([A-Za-z0-9]+\\)" nil t)
        (replace-match "\\1 \\2"))
      (goto-char (point-min))
      (while (re-search-forward "\\([,]\\)[ \t]*\n[ \t]*\\([A-Za-z0-9]+\\)" nil t)
        (replace-match "\\1 \\2"))
      (goto-char (point-min))
      (while (re-search-forward "  +" nil t) (replace-match " "))
      (goto-char (point-min))
      (while (re-search-forward "\\([.?!]\\) +\\([(0-9A-Za-z]+\\)" nil t) (replace-match "\\1\n\\2"))
      (goto-char (point-max))
      (while (eq (char-before) 32) (delete-char -1))))
  (re-search-forward "\n+" nil 1)
  (set-transient-map (let ((xkmap (make-sparse-keymap))) (define-key xkmap (kbd (if (boundp 'xah-repeat-key) xah-repeat-key "m")) this-command) xkmap))
  (set-transient-map (let ((xkmap (make-sparse-keymap))) (define-key xkmap (kbd "DEL") this-command) xkmap)))

(defun xah-add-period-to-line-end ()
  "Add a period to each end of line that does not have one.
Work on current paragraph if there is no selection.

URL `http://xahlee.info/emacs/emacs/emacs_period_to_line_end.html'
Created: 2020-11-25
Version: 2025-03-26"
  (interactive)
  (let (xbeg xend)
    (seq-setq (xbeg xend) (if (region-active-p) (list (region-beginning) (region-end)) (list (save-excursion (if (re-search-backward "\n[ \t]*\n" nil 1) (match-end 0) (point))) (save-excursion (if (re-search-forward "\n[ \t]*\n" nil 1) (match-beginning 0) (point))))))
    (save-restriction
      (narrow-to-region xbeg xend)
      (goto-char (point-max))
      (insert "\n")
      (goto-char (point-min))
      (while (search-forward "\n" nil 1)
        (backward-char)
        (let ((charX (char-before)))
          (if (or (eq charX ?\.) (eq charX ?!) (eq charX ??) (eq charX ?\n) (eq charX ?>))
              nil
            (insert ".")))
        (forward-char))
      (goto-char (point-max))
      (when (eq (char-before) ?\n) (delete-char -1)))))

(defun xah-title-case-region-or-line (&optional Begin End)
  "Title case text between nearest brackets, or current line or selection.
Capitalize first letter of each word, except words like {to, of, the, a, in, or, and}. If a word already contains cap letters such as HTTP, URL, they are left as is.

When called in a elisp program, Begin End are region boundaries.

URL `http://xahlee.info/emacs/emacs/elisp_title_case_text.html'
Version: 2017-01-11 2021-03-30 2021-09-19"
  (interactive)
  (let* ((xskipChars "^\"<>(){}[]“”‘’‹›«»「」『』【】〖〗《》〈〉〔〕")
         (xp0 (point))
         (xp1 (if Begin
                  Begin
                (if (region-active-p)
                    (region-beginning)
                  (progn
                    (skip-chars-backward xskipChars (line-beginning-position)) (point)))))
         (xp2 (if End
                  End
                (if (region-active-p)
                    (region-end)
                  (progn (goto-char xp0)
                         (skip-chars-forward xskipChars (line-end-position)) (point)))))
         (xstrPairs [
                     [" A " " a "]
                     [" An " " an "]
                     [" And " " and "]
                     [" At " " at "]
                     [" As " " as "]
                     [" By " " by "]
                     [" Be " " be "]
                     [" Into " " into "]
                     [" In " " in "]
                     [" Is " " is "]
                     [" It " " it "]
                     [" For " " for "]
                     [" Of " " of "]
                     [" Or " " or "]
                     [" On " " on "]
                     [" Via " " via "]
                     [" The " " the "]
                     [" That " " that "]
                     [" To " " to "]
                     [" Vs " " vs "]
                     [" With " " with "]
                     [" From " " from "]
                     ["'S " "'s "]
                     ["'T " "'t "]
                     ]))
    (save-excursion
      (save-restriction
        (narrow-to-region xp1 xp2)
        (upcase-initials-region (point-min) (point-max))
        (let ((case-fold-search nil))
          (mapc
           (lambda (xx)
             (goto-char (point-min))
             (while
                 (search-forward (aref xx 0) nil t)
               (replace-match (aref xx 1) t t)))
           xstrPairs))))))

(help-set-key "XAH" "\C-ct" #'xah-title-case-region-or-line #'xah-title-case-region-or-line)

(defun xah-twitterfy ()
  "Shorten words for Twitter 280 char limit on current line or selection.

If `universal-argument' is called first, ask for conversion direction (shorten/lenthen).

Note: calling this function twice in opposite direction does not necessarily return the origial, because the map is not one-to-one.

URL `http://xahlee.info/emacs/emacs/elisp_twitterfy.html'
Created: 2019-03-02
Version: 2025-03-25"
  (interactive)
  (let (xbeg xend xdirection
             (xabbrevMap
              [
               ["\\bare\\b" "r"]
               ["\\byou\\b" "u"]
               ["e.g. " "eg "]
               ["\bto\b" "2"]
               [" your" " ur "]
               ["\\band\\b" "＆"]
               ["\\bbecause\\b" "∵"]
               ["\\bcuz\\b" "∵"]
               ["therefore " "∴"]
               [" at " " @ "]
               [" love " " ♥ "]
               [" one " " 1 "]
               [" two " " 2 "]
               [" three " " 3 "]
               [" four " " 4 "]
               [" zero " " 0 "]
               ["hexadecimal " "hex "]
               ["Emacs: " "#emacs "]
               ["JavaScript: " "#JavaScript "]
               ["Python: " "#python "]
               ["Ruby: " "#ruby "]
               ["Perl: " "#perl "]
               ["Emacs Lisp: " "#emacs #lisp "]
               ["Elisp: " "#emacs #lisp "]
               [", " "，"]
               ["\\.\\.\\." "…"]
               ["\\. " "。"]
               ["\\? " "？"]
               [": " "："]
               ["! " "！"]]
              )
             (xreverseMap
              [
               ["\\bu\\b" "you"]
               ["\\br\\b" "are"]
               ["eg " "e.g. "]
               [" 2 " " to "]
               ["\\bur\\b" "your"]
               ["\\b＆\\b" "and"]
               ["\\bcuz\\b" "because"]
               ["\\b∴\\b" "therefore "]
               [" @ " " at "]
               [" ♥ " " love "]
               [" 1 " " one "]
               [" 2 " " two "]
               [" 3 " " three "]
               [" 4 " " four "]
               [" 0 " " zero "]
               ["hex " "hexadecimal "]
               ["，" ", "]
               ["…" "..."]
               ["。" ". "]
               ["？" "? "]
               ["：" ": "]
               ["！" "! "]
               ]
              ))
    (seq-setq (xbeg xend) (if (region-active-p) (list (region-beginning) (region-end)) (list (save-excursion (if (re-search-backward "\n[ \t]*\n" nil 1) (match-end 0) (point))) (save-excursion (if (re-search-forward "\n[ \t]*\n" nil 1) (match-beginning 0) (point))))))
    (setq xdirection
          (if current-prefix-arg
              (completing-read "Direction: " '("shorten" "lengthen") nil t)
            "auto"
            ))
    (save-restriction
      (narrow-to-region xbeg xend)
      (when (string-equal xdirection "auto")
        (goto-char (point-min))
        (setq xdirection
              (if (re-search-forward "。\\|，\\|？\\|！" nil t)
                  "lengthen" "shorten"
                  )))
      (let ((case-fold-search nil))
        (mapc
         (lambda (xx)
           (goto-char (point-min))
           (while (re-search-forward (elt xx 0) nil t)
             (replace-match (elt xx 1) t t)))
         (if (string-equal xdirection "shorten")
             xabbrevMap
           xreverseMap))
        (goto-char (point-min))
        (while (re-search-forward "  +" nil t)
          (replace-match " " t t)))
      (goto-char (+ (point-min) 280)))))
