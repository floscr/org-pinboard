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

(defcustom org-pinboard-dir org-directory
  "The pinboard directory."
  :type 'string)

(defcustom org-pinboard-file (concat org-pinboard-dir "/Bookmarks/bookmarks.org")
  "The bookmarks file."
  :type 'string)

(defcustom org-pinboard-archive-file (concat org-pinboard-dir "/Bookmarks/.archive/pinboard.org")
  "The archive file."
  :type 'string)

;;;###autoload
(defun org-pinboard-open-url ()
  "Open URL prop in browser."
  (interactive)
  "Open the URL property of the element under the cursor."
  (browse-url (org-entry-get (point) "URL")))

(defun helm-org-pinboard-open-url (candidate)
  "Open CANDIDATE in the browser."
  (-let (((buffer . pos) candidate))
    (switch-to-buffer buffer)
    (goto-char pos)
    (org-pinboard-open-url)))

(defun org-pinboard-rifle-get-source (file)
  "Return Helm source for FILE."
  (let* ((buffer (find-file-noselect file))
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
  "Helm pinboard rifle."
  (interactive)
  (helm :sources (org-pinboard-rifle-get-source org-pinboard-file)))

;;;###autoload
(defun helm-org-pinboard-archive ()
  "Helm pinboard archive rifle."
  (interactive)
  (helm :sources (org-pinboard-rifle-get-source org-pinboard-archive-file)))

;;;###autoload
(defun helm-org-pinboard-all ()
  "Helm pinboard all rifle."
  (interactive)
  (helm :sources (-map #'org-pinboard-rifle-get-source (list org-pinboard-file org-pinboard-archive-file))))

;;;###autoload
(define-minor-mode pinboard-mode
  "Custom mode for pinboard files to add hooks and bindings.")

;;;###autoload
(defun org-pinboard-convert-link-to-property ()
  "Convert a section header with a link to the url property."
  (interactive)
  (defun map-fn ()
    (let* ((link (org-entry-get (point) "ITEM")))
        (org-entry-put (point) "URL" link)))
  (org-map-entries #'map-fn nil 'tree))

(defun org-capture-template-goto-link ()
  "Set point for capturing at what capture target file+headline with headline     set to %l would do."
  (org-capture-put :target (list 'file+headline (nth 1 (org-capture-get :target))     (org-capture-get :annotation)))
  (org-capture-set-target-location))


;; ("p" "Pin Bookmark" plain
;;  (file+function org-pinboard-file org-pinboard-capture-find-header)
;;  (function org-pinboard-create-template))))
;;;###autoload
(defun org-pinboard-capture-find-header ()
  "Goto matching entry with the current file-header."
  (if (search-forward-regexp (concat ":URL:\s*" (org-capture-bookmark-string-url) "$") nil t)
      (progn (org-capture-put :target (list 'file+headline (nth 1 (org-capture-get :target)) (org-capture-get :annotation)))
             (org-capture-put-target-region-and-position)
             (org-up-element)
             (org-up-element)
             (message "NODE EXISTS"))
    (goto-char (point-max))))

;;;###autoload
(defun +org-pinboard/dwim-at-point ()
  "Open a link when with enter."
  (interactive)
  (if-let ((url (org-entry-get (point) "URL")))
      (browse-url url)
    (+org/dwim-at-point)))

(provide 'org-pinboard)
;;; org-pinboard.el ends here
