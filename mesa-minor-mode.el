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

        ;; set the buffer-local tags file to the MESA file
        (visit-tags-table mesa-tags-file-name t))

  ;; turn mesa-minor-mode off
    (progn

      ;; take MESA out of the global tags table list
      (delete mesa-tags-file-name tags-table-list)))
  ;; the group
  :group 'mesa
)

(provide 'mesa-minor-mode)
