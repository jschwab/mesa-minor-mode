;;; mesa-minor-mode.el --- tools for the MESA stellar evolution code

;; Author: Josiah Schwab <jschwab@gmail.com>
;; Keywords: files

;; Copyright (C) 2013-2015 Josiah Schwab

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or (at
;; your option) any later version.
;; 
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;; 
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see http://www.gnu.org/licenses/.

;;; Commentary:

;; See README.org

;;; Code:

;;;; Compatibility
;;;; re-used from https://github.com/flycheck/flycheck

(eval-and-compile
  (unless (fboundp 'defvar-local)
    (defmacro defvar-local (var val &optional docstring)
      "Define VAR as a buffer-local variable with default value VAL.
Like `defvar' but additionally marks the variable as being automatically
buffer-local wherever it is set."
      (declare (debug defvar) (doc-string 3))
      `(progn
         (defvar ,var ,val ,docstring)
         (make-variable-buffer-local ',var))))

  (unless (fboundp 'setq-local)
    (defmacro setq-local (var val)
      "Set variable VAR to value VAL in current buffer."
      `(set (make-local-variable ',var) ,val))))


(defgroup mesa nil
  "mesa customizations."
  :prefix "mesa-"
  :group 'mesa)

(defcustom mesa-tags-file-path
  "TAGS"
  "Name of the TAGS file inside of your MESA project"
  :type 'string
  :group 'mesa)

(defcustom mesa-tags-regexp
  "'/^[ \\t]+\\([^ \\t!]+\\)[ \\t]*=/\\1/'"
  "Regexp to recognize tags in defaults files"
  :type 'regexp
  :group 'mesa
)

(defcustom mesa-default-version
  "git"
  "Default version of MESA"
  :type 'string
  :group 'mesa
  )

(defcustom mesa-init-file
  "~/.mesa_init"
  "Default MESA init file"
  :type 'file
  :group 'mesa
)

(defcustom mesa-use-remote-paths
  nil
  "If t, use remote paths for tramp buffers; if nil, always use local paths."
  :type 'boolean
  :group 'mesa
)

(defconst mesa-rse-include-line
  "      include 'standard_run_star_extras.inc'"
  "Line in run_star_extras.f that pulls in default code."
  )

(defconst mesa-defaults-files
  '("star/defaults/star_job.defaults"
    "star/defaults/controls.defaults"
    "star/defaults/pgstar.defaults"
    "binary/defaults/binary_job.defaults"
    "binary/defaults/binary_controls.defaults")
  "Defaults files contained in MESA")


;; The function mesa-read-init is based on ini.el
;; License: GPL v2+
;; Copyright: Daniel Ness
;; URL: https://github.com/daniel-ness/ini.el

(defun mesa-read-init (filename)
  "Read a MESA config file"
  (let ((lines (with-temp-buffer
                 (insert-file-contents filename)
                 (split-string (buffer-string) "\n")))
        (section)
        (section-list)
        (alist))
    (dolist (l lines)
      (cond ((string-match "^;" l) nil)
            ((string-match "^[ \t]$" l) nil)
            ((string-match "^\\[\\(.*\\)\\]$" l)
             (progn 
               (if section
                   ;; add as sub-list
                   (setq alist (cons `(,section . ,section-list) alist))
                 (setq alist section-list))
               (setq section (match-string 1 l))
               (setq section-list nil)))
            ((string-match "^[ \t]*\\(.+\\) = \\(.+\\)$" l)
             (let ((property (match-string 1 l))
                   (value (match-string 2 l)))
               (progn 
                 (setq section-list (cons `(,property . ,value) section-list)))))))
    (if section
        ;; add as sub-list
        (setq alist (cons `(,section . ,section-list) alist))
      (setq alist section-list))
    alist))

(defun mesa-versions ()
  "List the possible MESA versions"
  (let ((mesa-init-data (mesa-read-init mesa-init-file)))
    (mapcar 'car mesa-init-data)))

(defun mesa-dir-from-version (version)
  "Given a MESA version string, return the corresponding MESA_DIR"
  (let ((mesa-init-data (mesa-read-init mesa-init-file)))
    (cdr (assoc "MESA_DIR"
                (cdr (assoc version mesa-init-data))))))

(defun mesa~prepend-system-name (filename)
  "Given a filename, (possibly) prepend the remote system name"
  (let ((remote (file-remote-p (buffer-file-name))))
    (if (and mesa-use-remote-paths remote)
        (concat remote filename)
      filename)))

(defun mesa~prepend-mesa-dir (filename)
  "Append the MESA_DIR to a filename"
  (let ((mesa-dir (mesa-dir-from-version mesa-version)))
    (mesa~prepend-system-name
     (concat (file-name-as-directory mesa-dir) filename))))

(defun mesa-tags-file ()
  "Create the full path to the TAGS directory"
  (mesa~prepend-mesa-dir mesa-tags-file-path))

(defun mesa-visit-tags-table ()
  "Visit tags table"
  (let ((tags-add-tables nil))
    (visit-tags-table (mesa-tags-file) t)))

(defun mesa-change-tags-table ()
  "Change tags table"
  ;; this works, but I don't understand why it is necesary.  if I just
  ;; used visit-tags-table, it would still always visit the old table,
  ;; even though tags-file-name would have the right value...
  (setq-local tags-table-list nil)
  (add-to-list 'tags-table-list (mesa-tags-file))
  (setq-local tags-file-name (mesa-tags-file))

  ;; make TAGS file if it doesn't exist
  (if (not (file-exists-p (mesa-tags-file)))
      (mesa-regen-tags)))
  
(defun mesa-cleanup-tags-table ()
  "Cleanup tags table"
  (delete mesa-tags-file-name tags-table-list))

(defun mesa-regen-tags ()
  "Regenerate the tags file for the MESA defaults directory"
  (interactive)
  (let ((default-directory (mesa~prepend-mesa-dir nil)))
    (shell-command (format "etags --language=none --regex=%s -o %s %s"
                           mesa-tags-regexp
                           mesa-tags-file-path
                           (mapconcat 'identity mesa-defaults-files " ")))))

(defun mesa-change-version ()
  "Change the MESA version being used in this buffer"
  (interactive)
  (setq-local mesa-version
                (completing-read
                 "Select MESA Version: "
                 (mesa-versions)
                 nil t))
    (mesa-change-tags-table))

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

(defun mesa-enable-rse ()
  "Enable run_star_extras.f by inserting the standard include
file"
  (interactive)
  (save-excursion
    (beginning-of-buffer)
    (if (search-forward mesa-rse-include-line nil nil)
        (progn
          (narrow-to-region (line-beginning-position) (line-end-position))
          (insert-file-contents
           (mesa~prepend-mesa-dir "include/standard_run_star_extras.inc")
           nil nil nil t)
          (widen)))))
      
(defcustom mesa-mode-line
  '(:eval (format " MESA[%s]" mesa-version))
  "Mode line lighter for MESA minor mode"
  :type 'sexp
  :risky t)

(define-minor-mode mesa-minor-mode
  "Toggle MESA minor mode in the usual way."
  :init-value nil
  ;; The indicator for the mode line.
  :lighter mesa-mode-line
  ;; The minor mode bindings.
  :keymap
  '(
    ("\C-c\C-t" . mesa-toggle-boolean)
    ("\C-c\C-c" . mesa-comment-dwim)
    ("\C-c\C-r" . mesa-enable-rse)
    ("\C-c\C-v" . mesa-change-version)
    )
  ;; The body
  (if mesa-minor-mode

      ;; turn mesa-minor-mode on
      (progn

        ;; set the MESA version
        (setq-local mesa-version mesa-default-version)

        ;; make TAGS file if it doesn't exist
        (if (not (file-exists-p (mesa-tags-file)))
            (mesa-regen-tags))

        (mesa-visit-tags-table))

  ;; turn mesa-minor-mode off
    (progn

      ;; take MESA out of the global tags table list
      (mesa-cleanup-tags-table)))
  ;; the group
  :group 'mesa
)

(provide 'mesa-minor-mode)
;;; mesa-minor-mode.el ends here
