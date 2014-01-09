;;; mesa-minor-mode.el --- tools for the MESA stellar evolution code

;; Copyright (C) 2013-2014  Josiah Schwab

;; Author: Josiah Schwab <jschwab@gmail.com>
;; Keywords: files

;; This software is under the MIT License
;; http://opensource.org/licenses/MIT

;; Permission is hereby granted, free of charge, to any person
;; obtaining a copy of this software and associated documentation
;; files (the "Software"), to deal in the Software without
;; restriction, including without limitation the rights to use, copy,
;; modify, merge, publish, distribute, sublicense, and/or sell copies
;; of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:

;; The above copyright notice and this permission notice shall be
;; included in all copies or substantial portions of the Software.

;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
;; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
;; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
;; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
;; BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
;; ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
;; CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.

;;; Commentary:

;; See README.org

;;; Code:

(provide 'mesa-minor-mode)

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

(defconst mesa-rse-include-line
  "      include 'standard_run_star_extras.inc'"
  "Line in run_star_extras.f that pulls in default code."
)

(defun mesa-regen-tags ()
  "Regenerate the tags file for the MESA defaults directory"
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
           (concat (getenv "MESA_DIR") "/include/standard_run_star_extras.inc")
           nil nil nil t)
          (widen)))))
      

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
    ("\C-c\C-r" . mesa-enable-rse)
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
;;; mesa-minor-mode.el ends here
