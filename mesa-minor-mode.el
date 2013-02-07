(defgroup mesa nil
  "mesa customizations."
  :prefix "mesa-"
  :group 'mesa)

(defcustom mesa-tags-file-name
  "TAGS"
  "Name of the TAGS file inside of your MESA project"
  :group 'mesa)

(defcustom mesa-tags-file-path
  (concat (getenv "MESA_DIR") "/star/defaults/")
  "Path to your TAGS file inside of your MESA project"
  :group 'mesa)

(defcustom mesa-tags-regexp
  "'/[ \\t]+\\([^ \\t]+\\)[ \\t]*=/\\1/'"
  "Regexp to recognize tags in defaults files"
  :group 'mesa
)

(defun mesa-regen-tags ()
  "Regenerate the tags file for the current working directory"
  (interactive)
  (shell-command (format "etags --language=none --regex=%s -o %s/%s %s*.defaults"
                           mesa-tags-regexp
                           mesa-tags-file-path
                           mesa-tags-file-name
                           mesa-tags-file-path)))

(defun mesa-toggle-boolean ()
  "Toggle an inlist flag between .true. <--> .false."
  (interactive)
  (save-excursion
    (beginning-of-line)
    (if (re-search-forward ".true.\\|.false." (line-end-position) t)
        (replace-match (if (string-equal (match-string 0) ".true.")
                           ".false." ".true.") nil nil))))

;; borrowed from http://www.emacswiki.org/emacs/CommentingCode
(defun mesa-comment-dwim (&optional arg)
  "Replaces default behavior of comment-dwim, when it inserts
comment at the end of the line."
  (interactive "*P")
  (comment-normalize-vars)
  (if (and (not (region-active-p)) (not (looking-at "[ \t]*$")))
      (comment-or-uncomment-region
       (line-beginning-position) (line-end-position))
    (comment-dwim arg)))

(define-minor-mode mesa-minor-mode
  "Toggle MESA minor mode in the usual way."
  :init-value nil
  ;; The indicator for the mode line.
  :lighter " MESA"
  ;; The minor mode bindings.
  :keymap
  '(
    ("\C-c\C-t" . mesa-toggle-boolean)
    ("\C-c\C-c" . mesa-comment-dwim)
    )
  ;; the body
  (if mesa-minor-mode

      ;; turn mesa-minor-mode on
      (progn

        (let ((mesa-tags-file (concat mesa-tags-file-path
                                      mesa-tags-file-name)))

          ;; if TAGS file doesn't exist, generate it
          (if (not (file-exists-p mesa-tags-file))
              (mesa-regen-tags))

          ;; set the buffer-local tags file to the MESA file
          (visit-tags-table mesa-tags-file)))

  ;; turn mesa-minor-mode off
    (progn

      ;; take MESA out of the global tags table list
      (delete mesa-tags-file-name tags-table-list)))
  ;; the group
  :group 'mesa
)

(provide 'mesa-minor-mode)
