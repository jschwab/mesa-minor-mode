(defgroup mesa nil
  "mesa customizations."
  :prefix "mesa-"
  :group 'mesa)

(defcustom mesa-tags-file-name
  (concat (getenv "MESA_DIR") "/star/defaults/TAGS")
  "Path to your TAGS file inside of your MESA project.  See `tags-file-name'."
  :group 'mesa)

(define-minor-mode mesa-minor-mode
  "Toggle MESA minor mode in the usual way."
  :init-value nil
  ;; The indicator for the mode line.
  :lighter " MESA"
  ;; The minor mode bindings.
  :keymap nil
  ;; the body
  (if mesa-minor-mode
  
      ;; to start the mode store the old tags file and then set the
      ;; buffer local one to be the mesa tags file

      (progn
        (make-local-variable 'mesa-minor-mode-initial-tags-file-name)
        (setq mesa-minor-mode-initial-tags-file-name tags-file-name)
        (set (make-local-variable 'tags-file-name) mesa-tags-file-name))

    ;; restore our old tags file
    (progn
      (setq tags-file-name mesa-minor-mode-initial-tags-file-name)))

  ;; the group
  :group 'mesa
)

(provide 'mesa-minor-mode)
