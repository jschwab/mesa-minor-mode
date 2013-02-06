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

(define-minor-mode mesa-minor-mode
  "Toggle MESA minor mode in the usual way."
  :init-value nil
  ;; The indicator for the mode line.
  :lighter " MESA"
  ;; The minor mode bindings.
  :keymap
  '(
    ("\C-c\C-t" . mesa-toggle-boolean)
    )
  ;; the body
  (if mesa-minor-mode

      ;; turn mesa-minor-mode on
      (progn

        ;; set the appropriate comment character
        (set (make-local-variable 'comment-start) "! ")
        (set (make-local-variable 'comment-column) 0)

        ;; set the buffer-local tags file to the MESA file
        (visit-tags-table (concat mesa-tags-file-path
                                  mesa-tags-file-name) t))

  ;; turn mesa-minor-mode off
    (progn

      ;; take MESA out of the global tags table list
      (delete mesa-tags-file-name tags-table-list)))
  ;; the group
  :group 'mesa
)

(provide 'mesa-minor-mode)
