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
  
      ;; turn mesa-minor-mode on
      (progn

        ;; this buffer will just use the MESA TAGS
        (set (make-local-variable 'tags-file-name) mesa-tags-file-name)
        (set (make-local-variable 'tags-table-list) (list mesa-tags-file-name)))

  ;; turn mesa-minor-mode off
    (progn

      ;; restore the old global tags settings
      (kill-local-variable 'tags-file-name)
      (kill-local-variable 'tags-table-list)))

  ;; the group
  :group 'mesa
)

(provide 'mesa-minor-mode)
