;;; org-pinboard.el --- Bookmark Management in Org Mode -*- lexical-binding: t; -*-

;; Author: Florian Schroedl <flo.schroedl@gmail.com>
;; Url: http://github.com/floscr/org-pinboard
;; Version: 1.0.0
;; Package-Requires: ((emacs "24.4") (dash "2.12") (f "0.18.1") (helm "1.9.4") (org "9.1.9") (helm-org-rifle "1.7.0-pre"))
;; Keywords: bookmaking

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:

;;; Manage my bookmarks in org mode with rifle like helm menu

;;; Code:

;;;; Require

(require 'cl-lib)
(require 'dash)
(require 'f)
(require 'helm)
(require 'org)
(require 's)
(require 'helm-org-rifle)

;;;###autoload
(defun helm-org-rifle-pinboard-open-link (candidate)
  "Open URL from Candidate"
  ;; This needs to be an interactive command because it's bound in `helm-org-rifle-map'.
  (interactive)
  (-let (((buffer . pos) candidate))
    (with-current-buffer buffer
      (goto-char pos)
      (message (org-entry-get (point) "URL")))))

(defcustom org-pinboard-file "~/Dropbox/org/Bookmarks/bookmarks.org"
  "The bookmarks file"
  :type 'string)

;;;###autoload
(defun org-pinboard-rifle-get-source (buffer)
  "Return Helm source for BUFFER."
  (let ((source (helm-build-sync-source (buffer-name buffer)
                  :after-init-hook helm-org-rifle-after-init-hook
                  :candidates (lambda ()
                                (when (s-present? helm-pattern)
                                  (helm-org-rifle--get-candidates-in-buffer (helm-attr 'buffer) helm-pattern)))
                  :candidate-transformer helm-org-rifle-transformer
                  :match 'identity
                  :multiline t
                  :volatile t
                  :action (helm-make-actions
                            "Open Link" 'helm-org-rifle-pinboard-open-link
                            "Show entry" 'helm-org-rifle--show-candidates
                            "Show entry in indirect buffer" 'helm-org-rifle-show-entry-in-indirect-buffer
                            "Show entry in real buffer" 'helm-org-rifle-show-entry-in-real-buffer
                            "Refile" 'helm-org-rifle--refile)
                  :keymap helm-org-rifle-map)))
    (helm-attrset 'buffer buffer source)
    source))

;;;###autoload
(defun helm-pinboard-rifle-file ()
  "Override the default source file getter for 'helm-org-rifle-get-source-for-buffer"
  (cl-letf (((symbol-function 'helm-org-rifle-get-source-for-buffer) #'org-pinboard-rifle-get-source))
    (helm-org-rifle-files org-pinboard-file)))

;;;###autoload
(helm-org-rifle-define-command
  "pinboard" ()
  "Rifle through the current buffer, sorted by latest timestamp."
  :transformer 'helm-org-rifle-transformer-sort-by-latest-timestamp
  :sources (helm-pinboard-rifle-file))

;;;###autoload
(defun lol ()
  (interactive)
  (message "lol"))

(provide 'org-pinboard)
;;; org-pinboard.el ends here
