;; .emacs

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.

(require 'package)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

(add-to-list 'auto-mode-alist '("\\.py\\'" . python-mode))

(add-to-list 'auto-mode-alist '("\\.smk\\'" . python-mode))
(add-to-list 'auto-mode-alist '("\\.yaml\\'" . python-mode))
(add-to-list 'auto-mode-alist '("\\.yml\\'" . python-mode))

(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

(add-to-list 'auto-mode-alist '("\\.C\\'" . cc-mode))
(add-to-list 'auto-mode-alist '("\\.c\\'" . cc-mode))
(add-to-list 'auto-mode-alist '("\\.pl\\'" . cperl-mode))

(add-to-list 'auto-mode-alist '("\\.html\\'" . html-helper-mode))

(add-to-list 'auto-mode-alist '("\\.tex\\'" . tex-mode))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(diff-switches "-u")
 '(package-selected-packages (quote (markdown-mode ##))))

;;; uncomment for CJK utf-8 support for non-Asian users
;; (require 'un-define)

(put 'upcase-region 'disabled nil)
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
