;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Copyright (c) Richard Gomes <rgomes.info@gmail.com>
;;
;; Blog: http://rgomes.info/
;;
;; Just drop this .emacs file onto your home directory and it automagically
;; creates directory .emacs.d for you, downloads and install all required
;; plugins.
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; see: http://www.emacswiki.org/emacs/UrlPackage#toc6
(setq url-proxy-services `'(
       ("http"      . ,(getenv "http_proxy"))
       ("https"     . ,(getenv "https_proxy"))
       ("ftp"       . ,(getenv "ftp_proxy"))
       ("no_proxy"  . ,(getenv "no_proxy"))
))


 ;;
;; utility functions
;;;

(defun ensure-directories (dirs)
  (dolist (d dirs)
    (if (not (file-directory-p d))
      (mkdir d))))

;;--  loads a script from a given URL
(defun eval-url (url)
  (let ((buffer (url-retrieve-synchronously url)))
    (save-excursion
      (set-buffer buffer)
      (goto-char (point-min))
      (re-search-forward "^$" nil 'move)
      (eval-region (point) (point-max))
      (kill-buffer (current-buffer)))))

;;-- installs a list of packages
(defun install-packages (packages)
  (setq packages-refreshed nil)
  (dolist (p packages)
    (when (not (package-installed-p p))
      (if (not packages-refreshed)
        (package-refresh-contents)
        (setq packages-refreshed t))
      (package-install p))
      (require p)))


 ;;
;; .emacs.d initialization
;;;

(ensure-directories '("~/.emacs.d" "~/.emacs.d/plugins"))

;;-- package.el is embedded in Emacs-24
(unless (require 'package nil t)
  (eval-url "http://repo.or.cz/w/emacs.git/blob_plain/1a0a666f941c99882093d7bd08ced15033bc3f0c:/lisp/emacs-lisp/package.el"))
(package-initialize)



 ;;
;; plugin configuration via eval-after-load
;; note: eval-after-load must be defined before loading packages
;;;

;;-- yasnippet
(eval-after-load "yasnippet"
  '(progn
    (yas-global-mode 1)
    (message "[yasnippet configured]")))

;;-- google-this
(eval-after-load "google-this"
  '(progn
    (global-set-key (kbd "C-x g") 'google-this-mode-submap)
    (google-this-mode 1)
    (message "[google-this configured]")))

;;-- auto-complete
(eval-after-load "auto-complete"
  '(progn
    (require 'auto-complete-config)
    (ac-config-default)
    (setq ac-delay 0.5)
    (define-key ac-completing-map (kbd "M-/") 'ac-stop)
    (global-auto-complete-mode t)
    (message "[auto-complete configured]")))

;;-- jedi
(defun jedi-start-kbd-macro ()
    "Disables jedi-mode before kmacro-start-macro"
    (interactive)
    (jedi-mode 0)
    (kmacro-start-macro))
(defun jedi-end-kbd-macro ()
    "Enables jedi-mode after kmacro-end-macro"
    (interactive)
    (kmacro-end-macro)
    (jedi-mode 1))
(eval-after-load "jedi"
  '(progn
	(setq jedi:setup-keys t)
	(setq jedi:complete-on-dot t)
	(setq jedi:tooltip-method '(popup))
	;(setq jedi:tooltip-method '(pos-tip))
	(setq jedi:server-command '("python" "~/.emacs.d/elpa/jedi-20130714.1415/jediepcserver.py"))
	(autoload 'jedi:setup "jedi" nil t)
        ;(global-set-key (kbd "C-x (") 'jedi-start-kbd-macro)
        ;(global-set-key (kbd "C-x )") 'jedi-end-kbd-macro)
	;(add-hook 'python-mode-hook 'jedi:ac-setup)
	(add-hook 'python-mode-hook 'jedi:setup)
        (message "[jedi configured]")))

;;-- ipython
(eval-after-load "ipython"
  '(progn
	(setq ansi-term-color-vector [unspecified "#3f3f3f" "#cc9393" "#7f9f7f" "#f0dfaf" "#DD6600" "#dc8cc3" "#93e0e3" "#dcdccc"])
	(setq python-shell-interpreter      "ipython")
	(setq python-shell-interpreter-args "")
	(setq python-shell-prompt-regexp         "In \\[[0-9]+\\]: ")
	(setq python-shell-prompt-output-regexp  "Out\\[[0-9]+\\]: ")
	(setq python-shell-completion-setup-code         "from IPython.core.completerlib import module_completion")
	(setq python-shell-completion-module-string-code "';'.join(module_completion('''%s'''))\n")
	(setq python-shell-completion-string-code        "';'.join(get_ipython().Completer.all_completions('''%s'''))\n")
        (message "[ipython configured]")))

;;-- flymake
;;-- see: http://www.plope.com/Members/chrism/flymake-mode
(add-hook 'find-file-hook 'flymake-find-file-hook)
(when (load "flymake" t)
    (defun flymake-pyflakes-init ()
        (let* ((temp-file (flymake-init-create-temp-buffer-copy 'flymake-create-temp-inplace))
               (local-file (file-relative-name temp-file (file-name-directory buffer-file-name))))
        (list "pyflakes" (list local-file))))

    (add-to-list 'flymake-allowed-file-name-masks '("\\.py\\'" flymake-pyflakes-init)))

;; nXML
(eval-after-load "auto-complete-nxml"
  '(progn
        (add-to-list 'auto-mode-alist '("\\.pt\\'" . nxml-mode))))

;;-- elpy
(eval-after-load "elpy"
  '(progn
	;(define-key ac-completing-map (kbd "<up>") nil)
	;(define-key ac-completing-map (kbd "<down>") nil)
	;(define-key ac-completing-map (kbd "RET") nil)
	;(define-key ac-completing-map (kbd "<return>") nil)
	(elpy-use-ipython)
	(elpy-enable)
        (message "[elpy configured]")))


 ;;
;; install packages using embedded package manager
;;;

;;-- install a list of packages from ELPA
;(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")))
;(install-packages '(yasnippet))

;;-- install a list of packages from other sources
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("marmalade" . "http://marmalade-repo.org/packages/")
                         ("melpa" . "http://melpa.milkbox.net/packages/")))
(install-packages '(google-this autopair auto-complete auto-complete-nxml python virtualenv flymake jedi scala-mode2))

(package-initialize)


 ;;
;; install cython-mode
;;;

(add-to-list 'load-path "~/.emacs.d/plugins")
(unless (require 'cython-mode nil t)
  (url-copy-file "https://raw.github.com/cython/cython/master/Tools/cython-mode.el" "~/.emacs.d/plugins/cython-mode.el")
  (byte-compile-file "~/.emacs.d/plugins/cython-mode.el" t))

(package-initialize)



;;--ido
(require 'ido)
(ido-mode t)

;;-- cedet
(require 'semantic/sb)
(global-ede-mode 1)
(semantic-mode 1)



;;-- desktop mode (save buffers on exit)
(require 'desktop)
(desktop-save-mode 0)
(defun my-desktop-save ()
  (interactive)
  ;; Don't call desktop-save-in-desktop-dir, as it prints a message.
  (if (eq (desktop-owner) (emacs-pid))
    (desktop-save desktop-dirname)))
(add-hook 'auto-save-hook 'my-desktop-save)


(menu-bar-mode)
(global-linum-mode t)
(line-number-mode t)
(column-number-mode t)
(setq-default indent-tabs-mode nil)


;; pretty theme
;(load-theme 'zenburn t)



 ;;
;; custom variables and faces
;;;

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
  '(safe-local-variable-values (quote ((eval ignore-errors "Write-contents-functions is a buffer-local alternative to before-save-hook" (add-hook (quote write-contents-functions) (lambda nil (delete-trailing-whitespace) nil)) (require (quote whitespace)) "Sometimes the mode needs to be toggled off and on." (whitespace-mode 0) (whitespace-mode 1)) (whitespace-line-column . 80) (whitespace-style face trailing lines-tail) (require-final-newline . t))))
  '(current-language-environment "UTF-8")
  '(scroll-bar-mode nil)
  '(show-paren-mode t)
  '(size-indication-mode t)
  '(tool-bar-mode nil)
  '(flycheck-flake8-maximum-line-length 132)
  '(flycheck-highlighting-mode (quote lines))
  '(flymake-errline ((((class color)) (:background "LightPink" :foreground "black"))))
  '(flymake-warnline ((((class color)) (:background "LightBlue2" :foreground "black")))) 
  '(custom-enabled-themes (quote (tango-dark)))
)

(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
  '(flycheck-error-face ((t (:inherit error :background "gray27" :foreground "IndianRed1" :underline (:color "red" :style wave)))))
  '(flycheck-flake8-maximum-line-length 132)
  '(flycheck-warning-face ((t (:inherit warning :foreground "yellow1"))))
)
