;;; org-pinboard.el --- Bookmark Management in Org Mode -*- lexical-binding: t; -*-

;; Author: Florian Schroedl <flo.schroedl@gmail.com>
;; Url: http://github.com/floscr/org-pinboard
;; Version: 1.0.0
;; Package-Requires: ((emacs "24.4") (dash "2.12") (f "0.18.1") (helm "1.9.4") (org "9.1.9"))
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

(provide 'org-pinboard)
;;; org-pinboard.el ends here
