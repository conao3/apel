;;; emu-latin1.el --- emu module for Emacs 19 and XEmacs without MULE

;; Copyright (C) 1995,1996,1997,1998 Free Software Foundation, Inc.

;; Author: MORIOKA Tomohiko <morioka@jaist.ac.jp>
;; Keywords: emulation, compatibility, mule, Latin-1

;; This file is part of emu.

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2, or (at
;; your option) any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Code:

;;; @ version and variant specific features
;;;

;; (cond (running-xemacs
;;        (require 'emu-xemacs))
;;       (running-emacs-19
;;        (require 'emu-e19)
;;        ))


;;; @ character set
;;;

(put 'ascii 'charset-description "Character set of ASCII")
(put 'ascii 'charset-registry "ASCII")

(put 'latin-iso8859-1 'charset-description "Character set of ISO-8859-1")
(put 'latin-iso8859-1 'charset-registry "ISO8859-1")

(defun charset-description (charset)
  "Return description of CHARSET."
  (get charset 'charset-description)
  )

(defun charset-registry (charset)
  "Return registry name of CHARSET."
  (get charset 'charset-registry)
  )

(defun charset-width (charset)
  "Return number of columns a CHARSET occupies when displayed."
  1)

(defun charset-direction (charset)
  "Return the direction of a character of CHARSET by
  0 (left-to-right) or 1 (right-to-left)."
  0)

(defun find-charset-string (str)
  "Return a list of charsets in the string."
  (if (string-match "[\200-\377]" str)
      '(latin-iso8859-1)
    ))

(defalias 'find-non-ascii-charset-string 'find-charset-string)

(defun find-charset-region (start end)
  "Return a list of charsets in the region between START and END."
  (if (save-excursion
	(goto-char start)
	(re-search-forward "[\200-\377]" end t)
	)
      '(latin-iso8859-1)
    ))

(defalias 'find-non-ascii-charset-region 'find-charset-region)


;;; @ coding-system
;;;

(defconst *internal* nil)
(defconst *ctext* nil)
(defconst *noconv* nil)

(defun decode-coding-string (string coding-system)
  "Decode the STRING which is encoded in CODING-SYSTEM."
  string)

(defun encode-coding-string (string coding-system)
  "Encode the STRING as CODING-SYSTEM."
  string)

(defun decode-coding-region (start end coding-system)
  "Decode the text between START and END which is encoded in CODING-SYSTEM."
  0)

(defun encode-coding-region (start end coding-system)
  "Encode the text between START and END to CODING-SYSTEM."
  0)

(defun detect-coding-region (start end)
  "Detect coding-system of the text in the region between START and END."
  )

(defun set-buffer-file-coding-system (coding-system &optional force)
  "Set buffer-file-coding-system of the current buffer to CODING-SYSTEM."
  )

(defmacro as-binary-process (&rest body)
  (` (let (selective-display)	; Disable ^M to nl translation.
       (,@ body)
       )))

(defmacro as-binary-input-file (&rest body)
  (` (let ((emx-binary-mode t)) ; Stop CRLF to LF conversion in OS/2
       (,@ body)
       )))

(defmacro as-binary-output-file (&rest body)
  (` (let ((emx-binary-mode t)) ; Stop CRLF to LF conversion in OS/2
       (,@ body)
       )))


;;; @@ for old MULE emulation
;;;

(defun code-convert-string (str ic oc)
  "Convert code in STRING from SOURCE code to TARGET code,
On successful converion, returns the result string,
else returns nil. [emu-latin1.el; old MULE emulating function]"
  str)

(defun code-convert-region (beg end ic oc)
  "Convert code of the text between BEGIN and END from SOURCE
to TARGET. On successful conversion returns t,
else returns nil. [emu-latin1.el; old MULE emulating function]"
  t)


;;; @ binary access
;;;

(defun insert-file-contents-as-binary (filename
				       &optional visit beg end replace)
  "Like `insert-file-contents', q.v., but don't code and format conversion.
Like `insert-file-contents-literary', but it allows find-file-hooks,
automatic uncompression, etc.

Namely this function ensures that only format decoding and character
code conversion will not take place."
  (let ((emx-binary-mode t))
    (insert-file-contents filename visit beg end replace)
    ))

(defalias 'insert-binary-file-contents 'insert-file-contents-as-binary)
(make-obsolete 'insert-binary-file-contents 'insert-file-contents-as-binary)

(defun insert-binary-file-contents-literally (filename
					      &optional visit beg end replace)
  "Like `insert-file-contents-literally', q.v., but don't code conversion.
A buffer may be modified in several ways after reading into the buffer due
to advanced Emacs features, such as file-name-handlers, format decoding,
find-file-hooks, etc.
  This function ensures that none of these modifications will take place."
  (let ((emx-binary-mode t))
    (insert-file-contents-literally filename visit beg end replace)
    ))

(defun write-region-as-binary (start end filename
				     &optional append visit lockname)
  "Like `write-region', q.v., but don't code conversion."
  (let ((emx-binary-mode t))
    (write-region start end filename append visit lockname)
    ))


;;; @ MIME charset
;;;

(defvar charsets-mime-charset-alist
  '(((ascii) . us-ascii)))

(defvar default-mime-charset 'iso-8859-1)

(defun mime-charset-to-coding-system (charset)
  (if (stringp charset)
      (setq charset (intern (downcase charset)))
    )
  (and (memq charset (list 'us-ascii default-mime-charset))
       charset)
  )

(defun detect-mime-charset-region (start end)
  "Return MIME charset for region between START and END."
  (if (save-excursion
	(goto-char start)
	(re-search-forward "[\200-\377]" end t)
	)
      default-mime-charset
    'us-ascii))

(defun encode-mime-charset-region (start end charset)
  "Encode the text between START and END as MIME CHARSET."
  )

(defun decode-mime-charset-region (start end charset)
  "Decode the text between START and END as MIME CHARSET."
  )

(defun encode-mime-charset-string (string charset)
  "Encode the STRING as MIME CHARSET."
  string)

(defun decode-mime-charset-string (string charset)
  "Decode the STRING as MIME CHARSET."
  string)


;;; @ character
;;;

(defun char-charset (char)
  "Return the character set of char CHAR."
  (if (< chr 128)
      'ascii
    'latin-iso8859-1))

(defun char-bytes (char)
  "Return number of bytes a character in CHAR occupies in a buffer."
  1)

(defun char-width (char)
  "Return number of columns a CHAR occupies when displayed."
  1)

(defalias 'char-length 'char-bytes)

(defmacro char-next-index (char index)
  "Return index of character succeeding CHAR whose index is INDEX."
  (` (1+ (, index))))


;;; @ string
;;;

(defalias 'string-width 'length)

(defun string-to-char-list (str)
  (mapcar (function identity) str)
  )

(defalias 'string-to-int-list 'string-to-char-list)

(defalias 'sref 'aref)

(defun truncate-string (str width &optional start-column)
  "Truncate STR to fit in WIDTH columns.
Optional non-nil arg START-COLUMN specifies the starting column.
\[emu-latin1.el; MULE 2.3 emulating function]"
  (or start-column
      (setq start-column 0))
  (substring str start-column width)
  )

;;; @@ obsoleted aliases
;;;
;;; You should not use them.

(defalias 'string-columns 'length)
(make-obsolete 'string-columns 'string-width)


;;; @ end
;;;

(provide 'emu-latin1)

;;; emu-latin1.el ends here