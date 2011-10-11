;;; ensime-semantic-highlight.el
;;
;;;; License
;;
;;     Copyright (C) 2010 Aemon Cannon
;;
;;     This program is free software; you can redistribute it and/or
;;     modify it under the terms of the GNU General Public License as
;;     published by the Free Software Foundation; either version 2 of
;;     the License, or (at your option) any later version.
;;
;;     This program is distributed in the hope that it will be useful,
;;     but WITHOUT ANY WARRANTY; without even the implied warranty of
;;     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;;     GNU General Public License for more details.
;;
;;     You should have received a copy of the GNU General Public
;;     License along with this program; if not, write to the Free
;;     Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
;;     MA 02111-1307, USA.



(defvar ensime-sem-high-faces
  (list
   'typeParam	font-lock-type-face
   'constructor	font-lock-type-face
   'class	font-lock-type-face
   'trait	font-lock-type-face
   'object	font-lock-type-face
   'caseApplyOrUnapply	font-lock-type-face
   'package	font-lock-preprocessor-face
   'var		font-lock-function-name-face
   'val		font-lock-variable-name-face
   'varField	font-lock-function-name-face
   'valField    font-lock-variable-name-face
   'method	font-lock-preprocessor-face
   'param	font-lock-variable-name-face
   )
  "Symbol-to-face mapping list to use when applying
  applying semantic highlighting.")

(defun ensime-sem-high-apply-properties (info)
  "Use provided info to modify font-lock properties of identifiers
 in the program text."
  (let ((file (plist-get info :file))
	(syms (plist-get info :syms)))
    (when-let (buf (find-buffer-visiting file))
      (with-current-buffer buf
	(dolist (sym syms)
	  (let* ((type (nth 0 sym))
		 (start (+ ensime-ch-fix (nth 1 sym)))
		 (end (+ ensime-ch-fix (nth 2 sym)))
		 (face (plist-get ensime-sem-high-faces type)))
	    (let ((ov (make-overlay start end buf)))
	      (overlay-put ov 'face face)
	      (overlay-put ov 'ensime-sem-high-overlay t)
	      (overlay-put ov 'ensime-sym-type type))
	    ))
	))))

(defun ensime-sem-high-clear-buffer ()
  (ensime-sem-high-clear-region 0 (point-max)))

(defun ensime-sem-high-clear-region (beg end)
  (let ((ovs (overlays-in beg end)))
    (dolist (ov ovs)
      (when (overlay-get ov 'ensime-sem-high-overlay)
	(delete-overlay ov)))))

(defun ensime-sem-high-refresh-buffer ()
  "Refresh semantic highlighting for the entire buffer."
  (ensime-sem-high-refresh-region 0 (point-max)))

(defun ensime-sem-high-refresh-region (beg end)
  "Refresh semantic highlighting for the given region."
  (ensime-rpc-symbol-designations
   buffer-file-name beg end
   `(lambda (info)
      (ensime-sem-high-clear-region ,beg ,end)
      (ensime-sem-high-apply-properties info))))

(defun ensime-sem-high-inspect-highlight ()
  (interactive)
  (let ((ovs (overlays-at (point))))
    (message "%S" (mapcar 
		   (lambda (ov)
		     (format "%S %S %S" 
			     (overlay-get ov 'face)
			     (overlay-get ov 'ensime-sem-high-overlay)
			     (overlay-get ov 'ensime-sym-type)))
		   ovs))))


(provide 'ensime-semantic-highlight)