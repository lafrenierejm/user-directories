;;; user-directories-linux.el --- Linux specification for User Emacs directories   -*- lexical-binding: t -*-

;; Copyright (C)2018 Free Software Foundation

;; Author: Francisco Miguel Colaço <francisco.colaco@gmail.com>
;; Maintainer: Francisco Miguel Colaço <francisco.colaco@gmail.com>
;; Version: 1
;; Created: 2018-05-05
;; Keywords: emacs
;; Homepage: https://github.com/francisco.colaco/emacs-directories
;; Package-Requires: (cl)

;; This file is not yet part of GNU Emacs.

;; This program is free software: you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation, either version 3 of the
;; License, or (at your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; The Linux configuration of the user-directories package uses
;; xdg-user-dir, present at all present distributions.
;;
;; There are directories for user :data, :config, :cache and :runtime
;; files.  Aditionally, the following directories are queried from
;; xdg-user-dir:
;;
;;  - :desktop
;;  - :documents
;;  - :download
;;  - :pictures
;;  - :publicshare
;;  - :templates
;;  - :videos
;;

;;; Code:

(eval-when-compile
 (require 'cl))


;;;; Linux specific code.

(defvar linux-xdg-folder-definitions
  '(:desktop "~/Desktop"
    :download "~/Downloads"
    :templates "~/Templates"
    :publicshare "~/Public"
    :documents "~/Documents"
    :pictures "~/Images"
    :videos "~/Videos")
  "A list of Linux directory that will be searched.

Each of the associations has a key and a default value, which the
user directory will take if the command xdg-user-dir does not
exist at the executable path.")


(defconst user-directories-have-xdg-user-dir
  (not (null (locate-file "xdg-user-dir" exec-path)))
  "Tells if the command xdg-user-dir was found in the executable path.

Most Linux distributions have xdg-user-dir.  Older than 2010 may
have not.  This constant determines if the command is safe to
use: exists and is at the executable path.")


(defun xdg-user-dir (type)
  "Find a XDG user directory of TYPE.

Uses the binary 'xdg-user-dir' if available."
  (if user-directories-have-xdg-user-dir
      (let ((key (upcase (replace-regexp-in-string ":" "" (symbol-name type)))))
        (substring (shell-command-to-string (concat "xdg-user-dir " key)) 0 -1))))


(defun setup-user-directories-linux ()
  "Set up the user directories on Linux based systems."

  ;; Set the user folders.
  (cl-loop for (type default) on linux-xdg-folder-definitions by (function cddr) do
    (set-user-directory type (or (xdg-user-dir type) (expand-file-name default))))

  ;; Set the XDG base folders.
  (let ((config-dir (or (getenv "XDG_CONFIG_HOME") (expand-file-name "~/.config/")))
        (data-dir (or (getenv "XDG_DATA_HOME") (expand-file-name "~/.local/share/")))
        (cache-dir (or (getenv "XDG_CACHE_HOME") (expand-file-name "~/.cache/")))
        (runtime-dir (getenv "XDG_RUNTIME_DIR")))
    ;; Add the directories to the user directories file, creating them if absent.
    (set-user-directory :config (expand-file-name "emacs/" config-dir) t)
    (set-user-directory :data (expand-file-name "emacs/" data-dir) t)
    (set-user-directory :cache (expand-file-name "emacs/" cache-dir) t)
    (set-user-directory :runtime (expand-file-name "emacs/" runtime-dir) t)

    ;; Set the user Lisp directories, adding them and their subdirs to `load-path'.
    ;; Create them if needed.
    (let ((dir (expand-file-name "emacs/lisp/" data-dir)))
      (set-user-directory :lisp dir t :recursive)
      (add-to-list 'load-path dir))

    (let ((dir (expand-file-name "emacs/lisp/" config-dir)))
      (set-user-directory :user-lisp dir t :recursive)
      (add-to-list 'load-path dir))))


(provide 'user-directories-linux)
;;; user-directories-linux.el ends here
