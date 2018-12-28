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

(defun helm-org-rifle-pinboard-show-entry-in-real-buffer (candidate)
  "Show CANDIDATE in its real buffer."
  (-let (((buffer . pos) candidate))
    (switch-to-buffer buffer)
    (goto-char pos)
    (message (org-entry-get (point) "URL")))
  (org-show-entry))

(defcustom org-pinboard-file "~/Dropbox/org/Bookmarks/bookmarks.org"
  "The bookmarks file"
  :type 'string)

(defun org-pinboard-rifle-get-source (buffer)
  "Return Helm source for BUFFER."
  (let ((source (helm-build-sync-source (buffer-name buffer)
                  :candidates (lambda ()
                                (when (s-present? helm-pattern)
                                  (helm-org-rifle--get-candidates-in-buffer (helm-attr 'buffer) helm-pattern)))
                  :match 'identity
                  :multiline t
                  :volatile t
                  :action (helm-make-actions
                           "Open Link" 'helm-org-rifle-pinboard-show-entry-in-real-buffer
                           "Show entry" 'helm-org-rifle--show-candidates))))
    (helm-attrset 'buffer buffer source)
    source))

(defun helm-pinboard-rifle-file ()
  "Override the default source file getter for 'helm-org-rifle-get-source-for-buffer"
  (cl-letf (((symbol-function 'helm-org-rifle-get-source-for-buffer) #'org-pinboard-rifle-get-source))
    (helm-org-rifle-files org-pinboard-file)))

;;;###autoload
(defun helm-org-pinboard ()
  "Create helm for pinboard rifle."
  (interactive)
  (helm
    :sources (list (helm-pinboard-rifle-file))))

(provide 'org-pinboard)
;;; org-pinboard.el ends here
