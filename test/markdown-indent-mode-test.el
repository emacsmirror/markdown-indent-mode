;;; markdown-indent-mode-test.el --- Tests for markdown-indent-mode  -*- lexical-binding: t; -*-

;; Copyright (C) 2026 Wai Hon Law
;;
;; Author: Wai Hon Law <whhone@gmail.com>
;; Version: 0.1.0
;; Package-Requires: ((emacs "28.1"))
;; URL: https://github.com/whhone/markdown-indent-mode
;;
;; This file is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <https://www.gnu.org/licenses/>.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;;; Commentary:

;; Tests for markdown-indent-mode.
;;
;;; Code:


(require 'ert)
(add-to-list 'load-path (expand-file-name ".." (file-name-directory (or load-file-name buffer-file-name))))
(require 'markdown-indent-mode)

(defmacro markdown-indent-mode-test-with-buffer (content &rest body)
  "Execute BODY in a temp buffer containing CONTENT.
`markdown-indent-mode' is enabled before BODY runs."
  (declare (indent 1))
  `(with-temp-buffer
     (insert ,content)
     (markdown-indent-mode 1)
     ,@body))

(defun markdown-indent-mode-test-line-prefix (line-number)
  "Return the plain string of the `line-prefix' property.

LINE-NUMBER is 1-based."
  (save-excursion
    (goto-char (point-min))
    (forward-line (1- line-number))
    (let ((prop (get-text-property (point) 'line-prefix)))
      (if prop (substring-no-properties prop) ""))))

(defun markdown-indent-mode-test-wrap-prefix (line-number)
  "Return the plain string of the `wrap-prefix' property.

LINE-NUMBER is 1-based."
  (save-excursion
    (goto-char (point-min))
    (forward-line (1- line-number))
    (let ((prop (get-text-property (point) 'wrap-prefix)))
      (if prop (substring-no-properties prop) ""))))

;;; Initial indentation

(ert-deftest markdown-indent-mode-test-no-heading ()
  "Content with no heading should have no indentation."
  (markdown-indent-mode-test-with-buffer "no heading\nmore content\n"
    (should (string= "" (markdown-indent-mode-test-line-prefix 1)))
    (should (string= "" (markdown-indent-mode-test-line-prefix 2)))))

(ert-deftest markdown-indent-mode-test-level-1 ()
  "Heading line has no prefix; content under level-1 heading is indented by 2."
  (markdown-indent-mode-test-with-buffer "# Heading\ncontent\n"
    (should (string= "" (markdown-indent-mode-test-line-prefix 1)))
    (should (string= "  " (markdown-indent-mode-test-line-prefix 2)))))

(ert-deftest markdown-indent-mode-test-level-2 ()
  "Level-2 heading is indented by 1; content under it is indented by 4."
  (markdown-indent-mode-test-with-buffer "## Heading\ncontent\n"
    (should (string= " " (markdown-indent-mode-test-line-prefix 1)))
    (should (string= "    " (markdown-indent-mode-test-line-prefix 2)))))

(ert-deftest markdown-indent-mode-test-level-3 ()
  "Level-3 heading is indented by 2; content under it is indented by 6."
  (markdown-indent-mode-test-with-buffer "### Heading\ncontent\n"
    (should (string= "  " (markdown-indent-mode-test-line-prefix 1)))
    (should (string= "      " (markdown-indent-mode-test-line-prefix 2)))))

(ert-deftest markdown-indent-mode-test-nested-headings ()
  "Heading lines are indented by level-1; content is indented by 2*level."
  (markdown-indent-mode-test-with-buffer "# H1\ncontent1\n## H2\ncontent2\n### H3\ncontent3\n"
    (should (string= "" (markdown-indent-mode-test-line-prefix 1)))      ; # H1: 0 spaces
    (should (string= "  " (markdown-indent-mode-test-line-prefix 2)))    ; content1: 2 spaces
    (should (string= " " (markdown-indent-mode-test-line-prefix 3)))     ; ## H2: 1 space
    (should (string= "    " (markdown-indent-mode-test-line-prefix 4)))  ; content2: 4 spaces
    (should (string= "  " (markdown-indent-mode-test-line-prefix 5)))    ; ### H3: 2 spaces
    (should (string= "      " (markdown-indent-mode-test-line-prefix 6))))) ; content3: 6 spaces

(ert-deftest markdown-indent-mode-test-content-before-heading ()
  "Content before the first heading should not be indented."
  (markdown-indent-mode-test-with-buffer "preamble\n# Heading\ncontent\n"
    (should (string= "" (markdown-indent-mode-test-line-prefix 1)))    ; preamble
    (should (string= "" (markdown-indent-mode-test-line-prefix 2)))    ; # Heading
    (should (string= "  " (markdown-indent-mode-test-line-prefix 3))))) ; content

(ert-deftest markdown-indent-mode-test-invalid-heading-no-space ()
  "'###text' without a space is not a heading; content should not be indented."
  (markdown-indent-mode-test-with-buffer "###NoSpace\ncontent\n"
    (should (string= "" (markdown-indent-mode-test-line-prefix 1)))
    (should (string= "" (markdown-indent-mode-test-line-prefix 2)))))

;;; Code fences

(ert-deftest markdown-indent-mode-test-fence-indentation ()
  "Fence delimiters and content are indented like regular content.

Fake headings inside don't change level."
  (markdown-indent-mode-test-with-buffer "# Heading\n```\n# not a heading\ncontent\n```\n"
    (should (string= "" (markdown-indent-mode-test-line-prefix 1)))    ; # Heading (heading line)
    (should (string= "  " (markdown-indent-mode-test-line-prefix 2)))  ; ``` (indented like content)
    (should (string= "  " (markdown-indent-mode-test-line-prefix 3)))  ; # not a heading (indented, not a real heading)
    (should (string= "  " (markdown-indent-mode-test-line-prefix 4)))  ; content
    (should (string= "  " (markdown-indent-mode-test-line-prefix 5))))) ; closing ``` (still under # Heading)

(ert-deftest markdown-indent-mode-test-fence-resumes-indentation ()
  "Indentation resumes correctly after a code fence closes."
  (markdown-indent-mode-test-with-buffer "# Heading\n```\ncode\n```\nafter fence\n"
    (should (string= "  " (markdown-indent-mode-test-line-prefix 5))))) ; after fence

(ert-deftest markdown-indent-mode-test-dynamic-heading-update-past-fence ()
  "Modifying a heading level that follows a fence containing fake headings."
  (markdown-indent-mode-test-with-buffer "## Heading\n```\n# fake\n```\nafter\n"
    (should (string= "    " (markdown-indent-mode-test-line-prefix 5))) ; initially under ## (4 spaces)
    (goto-char (point-min))
    (delete-char 1)                                                 ; ## → #
    (should (string= "  " (markdown-indent-mode-test-line-prefix 5))))) ; now under # (2 spaces)

;;; Dynamic updates

(ert-deftest markdown-indent-mode-test-dynamic-delete-hash ()
  "Deleting a # reduces heading level and updates content indentation."
  (markdown-indent-mode-test-with-buffer "## Heading\ncontent\n"
    (should (string= "    " (markdown-indent-mode-test-line-prefix 2))) ; initially 4 spaces (level 2)
    (goto-char (point-min))
    (delete-char 1)                                                 ; ## → #
    (should (string= "  " (markdown-indent-mode-test-line-prefix 2))))) ; now 2 spaces (level 1)

(ert-deftest markdown-indent-mode-test-dynamic-delete-space ()
  "Deleting the space after ### makes it invalid; content loses indentation."
  (markdown-indent-mode-test-with-buffer "### Heading\ncontent\n"
    (should (string= "      " (markdown-indent-mode-test-line-prefix 2))) ; initially 6 spaces (level 3)
    (goto-char (point-min))
    (search-forward "### ")
    (delete-char -1)                                                  ; delete the space
    (should (string= "" (markdown-indent-mode-test-line-prefix 2)))))     ; no longer a heading

;;; List item wrap-prefix

(ert-deftest markdown-indent-mode-test-list-item-wrap-prefix ()
  "List item `wrap-prefix' aligns continuation with body (after marker)."
  (markdown-indent-mode-test-with-buffer "# Heading\n- item\n"
    ;; line-prefix for list item: 2 spaces (level 1)
    (should (string= "  " (markdown-indent-mode-test-line-prefix 2)))
    ;; wrap-prefix: 2 (level) + 2 (for "- ") = 4 spaces
    (should (string= "    " (markdown-indent-mode-test-wrap-prefix 2)))))

(ert-deftest markdown-indent-mode-test-list-item-nested-indent ()
  "Indented list item `wrap-prefix' accounts for leading spaces and marker."
  (markdown-indent-mode-test-with-buffer "# Heading\n  - item\n"
    ;; line-prefix: 2 spaces (level 1)
    (should (string= "  " (markdown-indent-mode-test-line-prefix 2)))
    ;; wrap-prefix: 2 (level) + 4 (for "  - ") = 6 spaces
    (should (string= "      " (markdown-indent-mode-test-wrap-prefix 2)))))

(ert-deftest markdown-indent-mode-test-ordered-list-wrap-prefix ()
  "Ordered list item `wrap-prefix' aligns continuation with body."
  (markdown-indent-mode-test-with-buffer "# Heading\n1. item\n"
    ;; wrap-prefix: 2 (level) + 3 (for "1. ") = 5 spaces
    (should (string= "     " (markdown-indent-mode-test-wrap-prefix 2)))))

(ert-deftest markdown-indent-mode-test-regular-text-wrap-prefix ()
  "Regular text `wrap-prefix' equals `line-prefix' (no extra indentation)."
  (markdown-indent-mode-test-with-buffer "# Heading\ncontent\n"
    ;; wrap-prefix equals line-prefix for non-indented regular text
    (should (string= "  " (markdown-indent-mode-test-wrap-prefix 2)))))

;;; Blockquote wrap-prefix

(ert-deftest markdown-indent-mode-test-blockquote-wrap-prefix ()
  "Blockquote `wrap-prefix' uses `> ' continuation marker."
  (markdown-indent-mode-test-with-buffer "# Heading\n> quote\n"
    (should (string= "  " (markdown-indent-mode-test-line-prefix 2)))
    ;; wrap-prefix: 2 spaces (level 1) + "> "
    (should (string= "  > " (markdown-indent-mode-test-wrap-prefix 2)))))

(ert-deftest markdown-indent-mode-test-blockquote-no-space-wrap-prefix ()
  "Blockquote with no trailing space still uses `> ' continuation marker."
  (markdown-indent-mode-test-with-buffer "# Heading\n>quote\n"
    ;; wrap-prefix: 2 spaces (level 1) + "> "
    (should (string= "  > " (markdown-indent-mode-test-wrap-prefix 2)))))

(ert-deftest markdown-indent-mode-test-blockquote-indented-wrap-prefix ()
  "Indented blockquote includes leading spaces in continuation."
  (markdown-indent-mode-test-with-buffer "# Heading\n  > quote\n"
    ;; wrap-prefix: 2 spaces (level 1) + "  > " (2 leading spaces + "> ")
    (should (string= "    > " (markdown-indent-mode-test-wrap-prefix 2)))))

(ert-deftest markdown-indent-mode-test-list-item-wrap-prefix-no-heading ()
  "List item `wrap-prefix' aligns continuation even with no heading."
  (markdown-indent-mode-test-with-buffer "  - item\n"
    (should (string= "" (markdown-indent-mode-test-line-prefix 1)))
    ;; wrap-prefix: 0 (no heading) + 4 (for "  - ") = 4 spaces
    (should (string= "    " (markdown-indent-mode-test-wrap-prefix 1)))))

(ert-deftest markdown-indent-mode-test-blockquote-wrap-prefix-no-heading ()
  "Blockquote `wrap-prefix' preserves leading spaces even with no heading."
  (markdown-indent-mode-test-with-buffer "  > quote\n"
    (should (string= "" (markdown-indent-mode-test-line-prefix 1)))
    ;; wrap-prefix: 0 (no heading) + "  > " (2 leading spaces + "> ")
    (should (string= "  > " (markdown-indent-mode-test-wrap-prefix 1)))))

;;; Mode disable

(ert-deftest markdown-indent-mode-test-disable-removes-properties ()
  "Disabling `markdown-indent-mode' removes all `line-prefix' properties."
  (markdown-indent-mode-test-with-buffer "# Heading\ncontent\n"
    (should (string= "  " (markdown-indent-mode-test-line-prefix 2)))   ; properties are set
    (markdown-indent-mode -1)
    (should (null (get-text-property                                ; properties removed
                   (save-excursion (goto-char (point-min)) (forward-line 1) (point))
                   'line-prefix)))))

(provide 'markdown-indent-mode-test)

;;; markdown-indent-mode-test.el ends here
