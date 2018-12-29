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

(defcustom org-pinboard-file (concat org-directory "/Bookmarks/bookmarks.org")
  "The bookmarks file."
  :type 'string)

(defun helm-org-pinboard-open-url (candidate)
  "Open CANDIDATE in the browser."
  (-let (((buffer . pos) candidate))
    (switch-to-buffer buffer)
    (goto-char pos)
    (browse-url (org-entry-get (point) "URL"))))

(defun org-pinboard-rifle-get-source ()
  "Return Helm source for BUFFER."
  (let* ((buffer (find-file-noselect org-pinboard-file))
         (source (helm-build-sync-source (buffer-name buffer)
                  :candidates (lambda ()
                                (when (s-present? helm-pattern)
                                  (helm-org-rifle--get-candidates-in-buffer (helm-attr 'buffer) helm-pattern)))
                  :match 'identity
                  :multiline t
                  :volatile t
                  :action (helm-make-actions
                           "Open Link" 'helm-org-pinboard-open-url
                           "Show entry" 'helm-org-rifle--show-candidates))))
    (helm-attrset 'buffer buffer source)
    source))

;;;###autoload
(defun helm-org-pinboard ()
  "Create helm for pinboard rifle."
  (interactive)
  (helm :sources (org-pinboard-rifle-get-source)))

(provide 'org-pinboard)
;;; org-pinboard.el ends here
