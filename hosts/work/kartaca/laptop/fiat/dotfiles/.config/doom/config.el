;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(remove-hook '+doom-dashboard-functions #'doom-dashboard-widget-shortmenu)
(add-hook! '+doom-dashboard-functions :append
  (insert "\n" (+doom-dashboard--center +doom-dashboard--width "")))
(defun my-weebery-is-always-greater ()
  (let* ((banner '(
                   "                        ██  ██        "
                   "                        ██  ██        "
                   "  ████████████  ██████████  ██  ██████"
                   "  ██  ██▄▄████  ████  ████  ██  ██▄▄██"
                   "████  ██  ██  ██  ████████████████  ██"
                   ))
         (longest-line (apply #'max (mapcar #'length banner))))
    (put-text-property

     (point)
     (dolist (line banner (point))
       (insert (+doom-dashboard--center
                +doom-dashboard--width
                (concat line (make-string (max 0 (- longest-line (length line))) 32)))
               "\n"))
     'face 'doom-dashboard-banner)))
(setq +doom-dashboard-ascii-banner-fn #'my-weebery-is-always-greater)
(setq confirm-kill-emacs nil) ;; disable emacs confirming before exit
(setq doom-theme 'doom-gruvbox)
(setq display-line-numbers-type t)
(setq org-directory "~/resource/notes/org")
(setq org-attach-id-dir "~/resource/notes/org/roam/assets")
(add-hook 'org-mode-hook (lambda () (display-line-numbers-mode 0))) ;; disable line numbers in org
(setq user-full-name "Kuzey Koç"
      user-mail-address "kuzey.koc@kartaca.com")

(setq doom-font (font-spec :family "IosevkaTerm Nerd Font Mono" :size 18)
      doom-variable-pitch-font (font-spec :family "IosevkaTerm Nerd Font Mono" :size 18))

;; custom functions
(defun my/project-ediff ()
  "Ediff two files picked from the current project."
  (interactive)
  (let* ((project (project-current t))
         (files (project-files project))
         (file-a (completing-read "File A: " files nil t))
         (file-b (completing-read "File B: " files nil t)))
    (ediff file-a file-b)))

(map! :leader
      :desc "Ediff project files" "f E" #'my/project-ediff)

;; transparency
;; for gui
(after! doom-themes
  (custom-set-faces!
    '(default :background "#000000")
    ))

;; for tui
(when (not (display-graphic-p))
  (set-face-background 'default "unspecified-bg" nil)
  )

(add-to-list 'default-frame-alist '(alpha-background . 70))

(setq evil-vsplit-window-right t)
(setq evil-split-window-below t)

(map! :n "C-<up>" #'evil-window-increase-height)
(map! :n "C-<down>" #'evil-window-decrease-height)
(map! :n "C-<right>" #'evil-window-decrease-width)
(map! :n "C-<left>" #'evil-window-increase-width)

(map! :leader :desc "switch to previous workspace" "TAB h"   #'+workspace:switch-previous )
(map! :leader :desc "switch to next workspace"     "TAB l"   #'+workspace:switch-next )
(map! :leader :desc "last workspace"               "TAB TAB" #'+workspace/other )
(map! :leader :desc "display workspaces"           "TAB SPC" #'+workspace/display )

(map! :leader :desc "switch buffer" "b l" #'consult-buffer)
(map! :leader :desc "last buffer" "b b" #'evil-switch-to-windows-last-buffer)

(setq evil-escape-key-sequence "jk")

(define-key evil-normal-state-map (kbd "j") 'evil-next-visual-line)
(define-key evil-normal-state-map (kbd "k") 'evil-previous-visual-line)

;; these are very good QoL settings for evil
(setq evil-move-cursor-back nil)
(setq evil-move-beyond-eol t)

(setq evil-want-fine-undo t)

(setq evil-snipe-mode 1)
(setq evil-snipe-override-mode 1)
(define-key evil-normal-state-map (kbd "f") 'avy-goto-char-timer)
(define-key evil-visual-state-map (kbd "f") 'avy-goto-char-timer)
(setq avy-timeout-seconds 0.01)

;; window separator
(set-face-background 'vertical-border (face-background 'default))
(set-display-table-slot standard-display-table 'vertical-border (make-glyph-code ?│))

(setq projectile-auto-cleanup-known-projects t)
(setq projectile-auto-update-cache t)

(setq projectile-known-projects
      '("~/resource/notes/org/"
        "~/.config/emacs/"

        ;; personal projects
        "~/project/repos/one-ring/"
        "~/project/repos/legolas/"
        "~/project/repos/gimly/"
        "~/project/repos/sauron/"
        "~/project/repos/tolkien/"
        "~/project/repos/soup/"
        "~/project/dev/nazg/"

        "~/project/kartaca/hopi/repos/bekci2"
        "~/project/kartaca/hopi/repos/bird-usy"
        ))

(after! treemacs
  (treemacs-follow-mode 1)
  (setq treemacs-width 45)
  (setq treemacs-position 'right)
  ;; (setq treemacs-text-scale -2) ;; enable if using emacs gui
  (setq treemacs-git-mode 'extended)
  (setq treemacs-width-is-initially-locked nil) ;; enable manual width adjustment using mouse
  )

(after! vterm
  (set-popup-rule! "*doom:vterm-popup"
    :size 0.25
    :select t
    :quit nil))

(with-eval-after-load 'vterm
  (define-key vterm-mode-map (kbd "M-o") #'vterm--self-insert) ;; Allow tmux prefix (M-o) passthrough
  (define-key vterm-mode-map (kbd "C-l") nil) ;; accepting zsh autosuggestions
  (define-key vterm-mode-map (kbd "C-g") nil) ;; zsh fzf cd utility
  )

(defun my/vterm-cd-to-buffer-dir ()
  "CD into the directory of the current buffer when opening vterm."
  (when-let* ((file (buffer-file-name (get-buffer (or (buffer-name) ""))))
              (dir (file-name-directory file)))
    (vterm-send-string (format "cd %s\n" (shell-quote-argument dir)))))

(add-hook! 'vterm-mode-hook #'my/vterm-cd-to-buffer-dir)

;; eat
(after! eat
  (set-popup-rule! "^\\*eat\\*"
    :side 'bottom
    :size 0.25
    :select t
    :quit nil))

(defun my/eat-toggle ()
  (interactive)
  (let* ((default-directory (or (projectile-project-root) default-directory))
         (buffer (get-buffer "*eat*")))
    (if (and buffer (get-buffer-window buffer))
        (delete-window (get-buffer-window buffer))
      (if buffer
          (pop-to-buffer buffer)
        (eat)))))

(map! :leader
      :prefix ("o" . "toggle")
      :desc "Eat terminal" "t" #'my/eat-toggle)

;; org-babel
(setq org-export-babel-evaluate nil) ;; prevent org babel from running code blocks when exporting

;; evil
(define-key evil-normal-state-map (kbd "L") 'evil-end-of-line) ;; shift + l go to end of line
(define-key evil-normal-state-map (kbd "H") 'evil-first-non-blank) ;; shift + h go to start of line

;; which-key
(setq which-key-idle-delay 0.25) ;; reduce delay in which-key
(setq which-key-idle-secondary-delay 0)

;; mu4e
(after! mu4e
  ;; nixos: mu4e elisp lives in the Nix store, not a standard path.
  ;; this dynamically resolves it so it survives package updates.
  (add-to-list 'load-path
               (expand-file-name
                "../../share/emacs/site-lisp/mu4e"
                (file-truename (executable-find "mu"))))

  ;; core paths
  (setq mu4e-maildir "~/area/mail"
        mu4e-get-mail-command "mbsync -a"
        mu4e-update-interval 300) ;; update mails every 5 minutes

  (setq mu4e-drafts-folder "/personal/[Gmail]/Drafts"
        mu4e-sent-folder   "/personal/[Gmail]/Sent Mail"
        mu4e-trash-folder  "/personal/[Gmail]/Trash"
        mu4e-refile-folder "/personal/[Gmail]/Archive")

  ;; sending via msmtp
  (setq sendmail-program (executable-find "msmtp")
        send-mail-function             'sendmail-send-it
        message-send-mail-function     'message-send-mail-with-sendmail
        message-sendmail-f-is-evil     t
        message-sendmail-extra-arguments '("--read-envelope-from"))

  ;; quality of life
  (setq mu4e-view-show-images t
        mu4e-compose-signature-auto-include t
        mu4e-sent-messages-behavior 'delete))  ; remove this line if not Gmail

;; org crypt
(setq org-crypt-disable-auto-save t) ;; disable auto-save for encrypted org mode entries
;; (setq org-crypt-key "F5190B59F4E143E0") ;; encrypt entries with my GPG key
(setq org-crypt-key "CB5A65C413A6AA63") ;; encrypt entries with my GPG key
(setq org-tags-exclude-from-inheritance '("crypt")) ;; prevent tag inheritance for "crypt" tag

;; org mode
(add-hook 'auto-save-hook 'org-save-all-org-buffers)
(after! org
  (setq org-id-update-id-locations-at-save nil) ;; prevent scanning org ids on every save (solve delay when saving)
  ;; (setq org-src--auto-save-timer 10)
  (setq org-ellipsis " ")
  (setq org-lowest-priority ?F) ;; set todo priorities from A to F
  (setq org-startup-with-inline-images nil)
  (setq org-image-actual-width nil)
  (setq org-startup-folded 'overview)
  (setq org-fontify-archived-trees nil)
  ;; (setq org-use-tag-inheritance nil) ;; prevent child headings inherit parent headings' tags

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  ;; (setq org-habit-graph-column 100)
  ;; (setq org-habit-following-days 3)
  (setq org-habit-show-all-today t)
  ;; (setq +org-habit-graph-window-ratio 0.3)
  ;; (setq +org-habit-graph-padding 0)
  ;; (setq org-habit-preceding-days 14)
  (setq org-todo-keywords
        '((sequence
           "TODO(t)" "READ(r)" "DOING(o!)" "NEXT(n)" "LATER(l@/!)" "WAIT(w@/!)" "EVENT(e)" "JOB(j)" "BIRTHDAY(b)" "HABIT(h)" "|"
           "DONE(d@/!)" "CANCEL(c@/!)"
           )))

  (setq org-todo-keyword-faces
        '(("LATER"    . (:foreground "yellow"  :weight bold))
          ("TODO"     . (:foreground "#00FF00" :weight bold))
          ("READ"     . (:foreground "#D6BE87" :weight bold))
          ("NEXT"     . (:foreground "#FF00FF" :weight bold))
          ("DOING"    . (:foreground "#FF0000" :weight bold))
          ("WAIT"     . (:foreground "yellow"  :weight bold))
          ("DONE"     . (:foreground "#666666" :weight bold))
          ("CANCEL"   . (:foreground "#666666" :weight bold))
          ("EVENT"    . (:foreground "#e300d1" :weight bold))
          ("JOB"      . (:foreground "#000000" :background "#ffffff" :weight bold))
          ("HABIT"    . (:foreground "#00ffff" :weight bold))
          ("BIRTHDAY" . (:foreground "#00ff00" :weight bold))
          ))

  (custom-set-faces!
    '(org-level-1 :foreground "#ebdbb2" :weight normal)
    '(org-level-2 :foreground "#e0d1a6" :weight normal)
    '(org-level-3 :foreground "#d5c4a1" :weight normal)
    '(org-level-4 :foreground "#c8b894" :weight normal)
    '(org-level-5 :foreground "#bdae93" :weight normal)
    '(org-level-6 :foreground "#bdae93" :weight normal)
    '(org-level-7 :foreground "#a89984" :weight normal)
    '(org-level-8 :foreground "#a89984" :weight normal)
    )

(setq org-capture-templates
      '(
        ;; ---------------- PERSONAL ----------------
        ("1" "personal todo" entry (file+headline "roam/agenda/personal.org" "tasks")
         "* TODO %?\n:PROPERTIES:\n:ID: %(org-id-new)\n:CREATED: %(format-time-string \"%Y-%m-%d %H:%M\")\n:END:\n")

        ("9" "todo (today)" entry (file+headline "roam/agenda/personal.org" "tasks")
         "* TODO %?\nSCHEDULED: %(format-time-string \"<%Y-%m-%d>\")\n:PROPERTIES:\n:ID: %(org-id-new)\n:CREATED: %(format-time-string \"%Y-%m-%d %H:%M\")\n:END:\n")

        ("t" "todo (scheduled)" entry (file+headline "roam/agenda/personal.org" "tasks")
         "* TODO %?\nSCHEDULED: %^t\n:PROPERTIES:\n:ID: %(org-id-new)\n:CREATED: %(format-time-string \"%Y-%m-%d %H:%M\")\n:END:\n")

        ("w" "todo (weekend)" entry (file+headline "roam/agenda/personal.org" "tasks")
         "* TODO %?\nSCHEDULED: %(let* ((now (current-time))
                                       (dow (string-to-number (format-time-string \"%u\" now)))
                                       (days-to-sat (mod (- 6 dow) 7)))
                                  (format-time-string \"<%Y-%m-%d>\"
                                                      (time-add now (days-to-time days-to-sat))))
:PROPERTIES:\n:ID: %(org-id-new)\n:CREATED: %(format-time-string \"%Y-%m-%d %H:%M\")\n:END:\n")

        ("d" "todo (deadline)" entry (file+headline "roam/agenda/personal.org" "tasks")
         "* TODO %?\nDEADLINE: %^t\n:PROPERTIES:\n:ID: %(org-id-new)\n:CREATED: %(format-time-string \"%Y-%m-%d %H:%M\")\n:END:\n")

        ;; ---------------- META ----------------
        ("4" "birthday" entry (file+headline "roam/agenda/personal.org" "birthdays")
         "* BIRTHDAY %?\n:PROPERTIES:\n:ID: %(org-id-new)\n:CREATED: %(format-time-string \"%Y-%m-%d %H:%M\")\n:END:\n")

        ("5" "habit" entry (file+headline "roam/agenda/personal.org" "habits")
         "* HABIT %?\n:PROPERTIES:\n:REPEAT_TO_STATE: HABIT\n:STYLE: habit\n:CREATED: %(format-time-string \"%Y-%m-%d %H:%M\")\n:END:\n")

        ("6" "person" entry (file+headline "roam/agenda/personal.org" "people")
         "* %?\n:PROPERTIES:\n:ID: %(org-id-new)\n:CREATED: %(format-time-string \"%Y-%m-%d %H:%M\")\n:PHONE:\n:EMAIL:\n:JOB:\n:COMPANY:\n:DEPARTMENT:\n:CITY:\n:ADDRESS:\n:RELATIONSHIP:\n:END:\n")

        ("7" "location" entry (file+headline "roam/agenda/personal.org" "location")
         "* %?\n:PROPERTIES:\n:ID: %(org-id-new)\n:CREATED: %(format-time-string \"%Y-%m-%d %H:%M\")\n:CITY:\n:END:\n")

        ("8" "phone" entry (file+headline "roam/agenda/personal.org" "phones")
         "* %?\n:PROPERTIES:\n:ID: %(org-id-new)\n:CREATED: %(format-time-string \"%Y-%m-%d %H:%M\")\n:END:\n")

        ;; ---------------- WORK ----------------
        ("2" "job" entry (file+headline "roam/agenda/kartaca.org" "jobs")
         "* JOB %?\n:PROPERTIES:\n:REPEAT_TO_STATE: JOB\n:ID: %(org-id-new)\n:CREATED: %(format-time-string \"%Y-%m-%d %H:%M\")\n:JIRA_URL:\n:END:\n")

        ("3" "work todo" entry (file+headline "roam/agenda/kartaca.org" "tasks")
         "* TODO %?\n:PROPERTIES:\n:ID: %(org-id-new)\n:CREATED: %(format-time-string \"%Y-%m-%d %H:%M\")\n:END:\n")

        ("T" "work todo (today)" entry (file+headline "roam/agenda/kartaca.org" "tasks")
         "* TODO %?\nSCHEDULED: %(format-time-string \"<%Y-%m-%d>\")\n:PROPERTIES:\n:ID: %(org-id-new)\n:CREATED: %(format-time-string \"%Y-%m-%d %H:%M\")\n:END:\n")

        ("s" "work todo (scheduled)" entry (file+headline "roam/agenda/kartaca.org" "tasks")
         "* TODO %?\nSCHEDULED: %^t\n:PROPERTIES:\n:ID: %(org-id-new)\n:CREATED: %(format-time-string \"%Y-%m-%d %H:%M\")\n:END:\n")

        ("D" "work todo (deadline)" entry (file+headline "roam/agenda/kartaca.org" "tasks")
         "* TODO %?\nDEADLINE: %^t\n:PROPERTIES:\n:ID: %(org-id-new)\n:CREATED: %(format-time-string \"%Y-%m-%d %H:%M\")\n:END:\n")
        ))

  (defun savolla/org-insert-agenda-personal-birthday              () (interactive) (org-capture nil "4"))
  (defun savolla/org-insert-agenda-personal-habit                 () (interactive) (org-capture nil "5"))
  (defun savolla/org-insert-agenda-personal-person                () (interactive) (org-capture nil "6"))
  (defun savolla/org-insert-agenda-personal-location              () (interactive) (org-capture nil "7"))
  (defun savolla/org-insert-agenda-personal-phone                 () (interactive) (org-capture nil "8"))
  (defun savolla/org-insert-agenda-personal-todo                  () (interactive) (org-capture nil "1"))
  (defun savolla/org-insert-agenda-personal-todo-today            () (interactive) (org-capture nil "9"))
  (defun savolla/org-insert-agenda-personal-todo-weekend          () (interactive) (org-capture nil "10"))
  (defun savolla/org-insert-agenda-personal-todo-scheduled        () (interactive) (org-capture nil "t"))
  (defun savolla/org-insert-agenda-personal-todo-deadline         () (interactive) (org-capture nil "d"))

  (defun savolla/org-insert-agenda-work-job                       () (interactive) (org-capture nil "2"))
  (defun savolla/org-insert-agenda-work-todo                      () (interactive) (org-capture nil "3"))
  (defun savolla/org-insert-agenda-work-today                     () (interactive) (org-capture nil "T"))
  (defun savolla/org-insert-agenda-work-scheduled                 () (interactive) (org-capture nil "s"))
  (defun savolla/org-insert-agenda-work-deadline                  () (interactive) (org-capture nil "D"))
  )

;; org link references
(map! :leader :desc "copy id" "j C" #'org-store-link)
(map! :leader :desc "paste id" "j P" #'org-insert-link)

;;; prevent org tag inheritance for files that has @biblio tag
(add-hook 'org-mode-hook
  (lambda ()
    (when (and (buffer-file-name)
               (save-excursion
                 (goto-char (point-min))
                 (re-search-forward "^#\\+filetags:.*@biblio" nil t)))
      (setq-local org-use-tag-inheritance nil))))

;; latex
(setq org-latex-src-block-backend 'engraved) ;; syntax highlighting for code blocks in pdfs

;; org-agenda

;; remove scheduled timestampt from task item when tagging them as LATER
(defun my/org-remove-scheduled-when-later ()
  "Remove SCHEDULED timestamp when task is marked LATER."
  (when (and (string= org-state "LATER")
             (org-get-scheduled-time (point)))
    (org-schedule '(4))))
(add-hook 'org-after-todo-state-change-hook #'my/org-remove-scheduled-when-later)

(setq org-agenda-sticky t)

(setq org-clock-in-switch-to-state "DOING") ;; mark tasks as DOING when clocked-in

(custom-set-faces!
  '(org-agenda-clocking :background "gold" :foreground "black" :weight bold)
  '(org-agenda-scheduled-today  :foreground "orange")
  )

;; (setq org-agenda-start-with-log-mode t) ;; creates too much noice in agenda. (maybe enable later)
;; (setq org-agenda-start-with-clockreport-mode t)
(setq org-agenda-files '("~/resource/notes/org/roam/agenda/"))
(setq org-log-into-drawer t)
(setq system-time-locale "C")
(setq org-agenda-current-time-string " 🔴 NOW ")
(setq org-agenda-prefix-format
      '((agenda . "%?-12t %s")
        (todo   . " ")
        (tags   . " ")
        (search . " ")))

(setq org-agenda-hide-tags-regexp ".*")

;; org agenda view

(setq org-agenda-block-separator nil)  ;; remove the default = separator

(defun savolla/org-agenda-centered-header (title)
  (let* ((width (window-width))
         (title (concat " " title " "))
         (line-width (/ (- width (length title)) 2))
         (left-line (make-string (max 0 line-width) ?─))
         ;; subtract 1 for the right side to avoid overflow
         (right-line (make-string (max 0 (1- line-width)) ?─)))
    (concat "\n" left-line title right-line)))

(setq org-agenda-custom-commands
      '(

("b" "agenda"
 (
  (todo "DOING|NEXT|WAIT" ((org-agenda-overriding-header " 󱌣  Currently Working (ALL)")))
  (agenda ""
          ((org-agenda-overriding-header (savolla/org-agenda-centered-header "󰃶  Today"))
           (org-agenda-start-day "0d") ; start from today
           (org-agenda-span 1) ; display 2 weeks
           (org-deadline-warning-days 14) ; remind upcoming deadlines before 2 weeks
           (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo '("DOING"))) ;; skip if it's a DOING task
           ))
  (todo "TODO" ((org-agenda-overriding-header (savolla/org-agenda-centered-header "  Todo"))))
  (todo "DONE" ((org-agenda-overriding-header (savolla/org-agenda-centered-header "  Done"))))
  (todo "CANCEL" ((org-agenda-overriding-header (savolla/org-agenda-centered-header "󰜺  Canceled"))))
  )
 )

("p" "personal agenda"
 (
  (todo "DOING|NEXT|WAIT" ((org-agenda-overriding-header " 󱌣  Currently Working (personal)")))
  (agenda ""
          ((org-agenda-overriding-header (savolla/org-agenda-centered-header "󰃶  Today"))
           (org-agenda-start-day "0d") ; start from today
           (org-agenda-span 1) ; display current day only
           (org-deadline-warning-days 14) ; remind upcoming deadlines before 2 weeks
           (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo '("DOING" "DONE" "CANCEL" "NEXT")))
           ))

  (todo "READ" ((org-agenda-overriding-header (savolla/org-agenda-centered-header "  Reading"))))
  (todo "TODO" ((org-agenda-overriding-header (savolla/org-agenda-centered-header "  Todo"))))
  (todo "DONE" ((org-agenda-overriding-header (savolla/org-agenda-centered-header "  Done"))))
  (todo "CANCEL" ((org-agenda-overriding-header (savolla/org-agenda-centered-header "󰜺  Canceled"))))
  )
 ((org-agenda-tag-filter-preset '("+_personal")))
 )

("k" "kartaca work agenda"
 (
  (tags "+_job/DOING" ((org-agenda-overriding-header "󰌃  Active Jobs")))
  (tags "+_job/NEXT" ((org-agenda-overriding-header "")))
  (tags "+_job/WAIT" ((org-agenda-overriding-header "")))

  (tags "-_job/DOING" ((org-agenda-overriding-header "\n 󱌣  Active Tasks ")))
  (tags "-_job/NEXT" ((org-agenda-overriding-header "")))
  (tags "-_job/WAIT" ((org-agenda-overriding-header "")))

  (agenda ""
          (
           (org-agenda-overriding-header (savolla/org-agenda-centered-header "󰃶  Today"))
           (org-agenda-start-day "0d")
           (org-agenda-span 1)
           (org-deadline-warning-days 14)
           (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo '("DOING" "DONE" "CANCEL" "NEXT")))
           ))

  ;; open jobs
  (tags "+_job/JOB" ((org-agenda-overriding-header (savolla/org-agenda-centered-header "󰌃  Open Jobs"))))

  ;; open tasks
  (tags "-_job/TODO" ((org-agenda-overriding-header (savolla/org-agenda-centered-header "  Open Tasks"))))

  ;; closed jobs
  (tags "+_job/DONE" ((org-agenda-overriding-header (savolla/org-agenda-centered-header "󰌃  Closed Jobs"))))
  (tags "+_job/CANCEL" ((org-agenda-overriding-header "")))

  ;; closed tasks
  (tags "-_job/DONE" ((org-agenda-overriding-header (savolla/org-agenda-centered-header "  Closed Tasks"))))
  (tags "-_job/CANCEL" ((org-agenda-overriding-header "")))
  )
 ((org-agenda-tag-filter-preset '("+_work" "+kartaca")))
 )
))

(custom-set-faces!
  '(org-block :background unspecified)
  '(org-block-background :background unspecified)
  '(org-src :background unspecified))

;; optimize node search buffer by only giving it title and tags
(after! org-roam
  (setq org-roam-node-display-template
        (concat
         (propertize "${doom-hierarchy}" 'face 'font-lock-keyword-face)
         " "
         (propertize "${doom-tags}" 'face '(:inherit org-tag :box nil))))

  (setq org-roam-capture-templates
        '(("d" "default" plain "%?"
           :target (file+head "zettels/%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n")
           :unnarrowed t)))
  )
(setq org-roam-dailies-directory "journal/")


(setq global-hl-line-modes nil) ;; disable highlighted line in emacs.

;; make emacs open url in $BROWSER
(setq browse-url-browser-function 'browse-url-generic
      browse-url-generic-program (getenv "BROWSER"))

;; if directory contains direnv files then allow automatically
(defun my/direnv-auto-allow ()
  "Auto-run `direnv allow` if .envrc exists and is blocked."
  (let ((envrc (locate-dominating-file default-directory ".envrc")))
    (when envrc
      (let ((default-directory envrc))
        (start-process "direnv-allow" nil "direnv" "allow")))))

(add-hook 'find-file-hook #'my/direnv-auto-allow)

;; pdf viewer configuration
(add-hook 'pdf-view-mode-hook (lambda () (pdf-view-midnight-minor-mode)))
(setq pdf-view-midnight-colors '("#d0d0d0" . "#222222"))

(after! pdf-tools
  (setq pdf-view-display-size 'fit-width)
  (setq pdf-view-resize-factor 1.1)
  ;; Set the colors for dark mode (light text on dark background)
  (setq pdf-view-midnight-colors '("#f0f0f0" . "#2e2e2e"))
  )

(after! pdf-view
  (defun savolla/pdf-highlight (color tag)
    "Highlight region in PDF with COLOR and create org-noter note tagged TAG."
    (interactive)
    (pdf-annot-add-highlight-markup-annotation (pdf-view-active-region) color)
    (org-noter-insert-precise-note)
    (org-id-get-create)
    (save-buffer)
    (org-roam-tag-add (list tag)))

  (defun savolla/pdf-highlight-term         () (interactive) (savolla/pdf-highlight "#FFD700" "_term"))
  (defun savolla/pdf-highlight-abbr         () (interactive) (savolla/pdf-highlight "#FFF176" "_abbr"))
  (defun savolla/pdf-highlight-analogy      () (interactive) (savolla/pdf-highlight "#CE93D8" "_analogy"))
  (defun savolla/pdf-highlight-history      () (interactive) (savolla/pdf-highlight "#D7B483" "_history"))
  (defun savolla/pdf-highlight-fact         () (interactive) (savolla/pdf-highlight "#80DEEA" "_fact"))
  (defun savolla/pdf-highlight-property     () (interactive) (savolla/pdf-highlight "#90CAF9" "_property"))
  (defun savolla/pdf-highlight-mechanism    () (interactive) (savolla/pdf-highlight "#42A5F5" "_mechanism"))
  (defun savolla/pdf-highlight-method       () (interactive) (savolla/pdf-highlight "#4DB6AC" "_method"))
  (defun savolla/pdf-highlight-comparison   () (interactive) (savolla/pdf-highlight "#FFB74D" "_comparison"))
  (defun savolla/pdf-highlight-usecase      () (interactive) (savolla/pdf-highlight "#A5D6A7" "_usecase"))
  (defun savolla/pdf-highlight-tradeoff     () (interactive) (savolla/pdf-highlight "#FFCA28" "_tradeoff"))
  (defun savolla/pdf-highlight-bestpractice () (interactive) (savolla/pdf-highlight "#D4E157" "_bestpractice"))
  (defun savolla/pdf-highlight-warning      () (interactive) (savolla/pdf-highlight "#EF9A9A" "_warning"))
  (defun savolla/pdf-highlight-fix          () (interactive) (savolla/pdf-highlight "#F48FB1" "_fix"))
  (defun savolla/pdf-highlight-reference    () (interactive) (savolla/pdf-highlight "#B0BEC5" "_reference"))

  ;; quickly skip through the book by only looking at your highlihgts
  (map! :map pdf-view-mode-map
        :n "C-j" #'org-noter-sync-next-note
        :n "C-k" #'org-noter-sync-prev-note)
  )

;; corfu
(after! corfu
  (setq +corfu-want-tab-prefer-expand-snippets t)
  (setq corfu-auto t)
  (setq corfu-auto-delay 1)
  (setq corfu-auto-prefix 2)
  (setq corfu-count 8)
  (setq corfu-preselect t)

  ;; instant completion in programming modes
  (add-hook 'prog-mode-hook
            (lambda ()
              (setq-local corfu-auto-delay 0)))

  (map! :map corfu-map
        :i "TAB" #'corfu-complete
        :i "C-j" #'corfu-next
        :i "C-k" #'corfu-previous
        :i "SPC" #'corfu-insert-separator))

(setq-hook! 'prog-mode-hook corfu-auto-delay 0)

;; Directly remove the auto-completion timer hook in org buffers
(add-hook 'org-mode-hook
          (lambda ()
            (remove-hook 'post-command-hook #'corfu-auto--post-command t)))

;; flycheck
(after! flycheck
  (setq-default flycheck-disabled-checkers '(org-lint)))

;; undo-tree
;; (after! undo-tree
;;   (setq undo-tree-auto-save-history nil))

;; gc
(setq gc-cons-threshold (* 100 1024 1024))
(run-with-idle-timer 5 t #'garbage-collect)

;; org roam ql

;; org-fc
(use-package! org-fc
  :custom
  (org-fc-directories '("/home/kkoc/resource/notes/org/roam/zettels"
                        "/home/kkoc/resource/notes/org/roam/biblio/notes"
                        "/home/kkoc/resource/notes/org/roam/journal"))
  :config
  (require 'org-fc-hydra))

;;; pre-made decks
(defun my/fc-terraform () (interactive)
  (org-fc-review '(:paths all :filter (tag "terraform"))))

(defun my/fc-terraform-facts () (interactive)
  (org-fc-review '(:paths all :filter (and (tag "terraform") (tag "_fact")))))

;;; define keybindings for review session (evil-mode)
(evil-define-minor-mode-key '(normal insert emacs) 'org-fc-review-flip-mode
  (kbd "RET") 'org-fc-review-flip
  (kbd "n") 'org-fc-review-flip
  (kbd "s") 'org-fc-review-suspend-card
  (kbd "q") 'org-fc-review-quit)

(evil-define-minor-mode-key '(normal insert emacs) 'org-fc-review-rate-mode
  (kbd "a") 'org-fc-review-rate-again
  (kbd "h") 'org-fc-review-rate-hard
  (kbd "g") 'org-fc-review-rate-good
  (kbd "e") 'org-fc-review-rate-easy
  (kbd "s") 'org-fc-review-suspend-card
  (kbd "q") 'org-fc-review-quit)


;; org-noter
(setq
 org-noter-separate-notes-from-heading t ;; aesthetics. leave space between notes
 org-noter-always-create-frame nil ;; prevent new frames
 org-noter-auto-save-last-location t ;; resume where you left off
 org-noter-notes-search-path '("~/resource/notes/org/roam/biblio/notes")
 org-noter-default-heading-title (format-time-string "%Y%m%d%H%M%S") ;; zettelkasten style headings by default
 org-noter-insert-note-no-questions t ;; skip promting for note insertion
 org-noter-max-short-selected-text-length 0 ;; prevent short highlighted text to be a heading
 )

;; ace window
(setq aw-keys '(?j ?k ?l ?d ?f ?a ?i)) ;; select windows with chars instead of numbers

;; flacscard entry
(defun savolla/org-capture-flashcard (fc-type)
  "Insert an org-fc flashcard heading of FC-TYPE.
FC-TYPE can be: normal, double, cloze, input.
Inherits the heading level from the previous heading."
  (interactive "sFlashcard type (normal/double/cloze/input): ")
  (goto-char (point-max))
  (let* ((level (save-excursion
                  (if (re-search-backward org-heading-regexp nil t)
                      (org-current-level)
                    1)))
         (stars (make-string level ?*))
         (timestamp (format-time-string "%Y%m%d%H%M%S")))
    (insert (format "\n%s %s\n" stars timestamp)))
  (forward-line -1)
  (org-back-to-heading t)
  (org-id-get-create)
  (org-set-property "CREATED" (format-time-string "%Y-%m-%d %H:%M"))
  (re-search-forward ":END:" nil t)
  (forward-line 1)
  ;; Initialize the org-fc card type AFTER the drawer is set up
  (pcase fc-type
    ("normal" (org-fc-type-normal-init))
    ("double" (org-fc-type-double-init))
    ("cloze"  (org-fc-type-cloze-init 'deletion))
    ("input"  (org-fc-type-text-input-init))
    (_        (message "Unknown fc-type: %s. Use normal/double/cloze/input." fc-type)))
  (evil-insert-state))

;; flashcard types
(defun savolla/org-capture-fc-normal () (interactive) (savolla/org-capture-flashcard "normal"))
(defun savolla/org-capture-fc-double () (interactive) (savolla/org-capture-flashcard "double"))
(defun savolla/org-capture-fc-cloze  () (interactive) (savolla/org-capture-flashcard "cloze"))
(defun savolla/org-capture-fc-input  () (interactive) (savolla/org-capture-flashcard "input"))


;; insert journal entry
(defun savolla/org-insert-journal-entry ()
  "insert a journal entry"
  (interactive)
  (goto-char (point-max))
  (let* ((ts (format-time-string "%H:%M:%S"))
         (level (save-excursion
                  (if (re-search-backward org-heading-regexp nil t)
                      (org-current-level)
                    1)))
         (stars (make-string level ?*)))
    (insert (format "\n%s %s\n" stars ts)))
  (forward-line -1)
  (org-back-to-heading t)
  (forward-line 1)
  (evil-insert-state))


;; (defun savolla/org-capture-node (kind type)
;;   "Insert a heading of TYPE with tag KIND (zettel or biblio)
;;    inheriting previous level."
;;   (interactive "sKind (zettel/biblio): \nsZettel type: ")
;;   (goto-char (point-max))
;;   (let* ((level (save-excursion
;;                   (if (re-search-backward org-heading-regexp nil t)
;;                       (org-current-level)
;;                     1)))
;;          (stars (make-string level ?*))
;;          (timestamp (format-time-string "%Y%m%d%H%M%S")))
;;     (insert (format "\n%s %s :@%s:%s:\n" stars timestamp kind type)))
;;   (forward-line -1)
;;   (org-back-to-heading t)
;;   (org-id-get-create)
;;   (org-set-property "CREATED" (format-time-string "%Y-%m-%d %H:%M"))
;;   (re-search-forward ":END:" nil t)
;;   (forward-line 1)
;;   (evil-insert-state))


(defun savolla/org-capture-node (kind type)
  "Insert a heading of TYPE with tag KIND (zettel or biblio)
   inheriting previous level. Also initializes an org-fc flashcard
   based on TYPE."
  (interactive "sKind (zettel/biblio): \nsZettel type: ")
  (goto-char (point-max))
  (let* ((level (save-excursion
                  (if (re-search-backward org-heading-regexp nil t)
                      (org-current-level)
                    1)))
         (stars (make-string level ?*))
         (timestamp (format-time-string "%Y%m%d%H%M%S")))
    (insert (format "\n%s %s :@%s:%s:\n" stars timestamp kind type)))
  (forward-line -1)
  (org-back-to-heading t)
  (org-id-get-create)
  (org-set-property "CREATED" (format-time-string "%Y-%m-%d %H:%M"))
  (re-search-forward ":END:" nil t)
  (forward-line 1)
  ;; Initialize org-fc card based on note type.
  ;; Add/remove entries here to control which types get flashcards.
  (pcase type
    ("_term"         (org-fc-type-normal-init))
    ("_abbr"         (org-fc-type-text-input-init))
    ("_fact"         (org-fc-type-cloze-init 'deletion))
    ("_usecase"      (org-fc-type-cloze-init 'deletion))
    ("_mechanism"    (org-fc-type-cloze-init 'deletion))
    ("_history"      (org-fc-type-cloze-init 'deletion))
    ("_analogy"      (org-fc-type-cloze-init 'deletion))
    ("_warning"      (org-fc-type-cloze-init 'deletion))
    ("_bestpractice" (org-fc-type-cloze-init 'deletion))
    ("_fact"         (org-fc-type-cloze-init 'deletion))
    ("_tradeoff"     (org-fc-type-cloze-init 'deletion))
    ("_comparison"   (org-fc-type-cloze-init 'deletion))
    ("_comparison"   (org-fc-type-cloze-init 'deletion))
    ("_usecase"      (org-fc-type-cloze-init 'deletion))
    ("_mechanism"    (org-fc-type-cloze-init 'deletion))
    ("_property"     (org-fc-type-cloze-init 'deletion))
    (_            nil)) ; no flashcard for unrecognized types
  (evil-insert-state))


;; zettel variants
(defun savolla/org-capture-zettel-term         () (interactive) (savolla/org-capture-node "zettel" "_term"))
(defun savolla/org-capture-zettel-abbr         () (interactive) (savolla/org-capture-node "zettel" "_abbr"))
(defun savolla/org-capture-zettel-method       () (interactive) (savolla/org-capture-node "zettel" "_method"))
(defun savolla/org-capture-zettel-history      () (interactive) (savolla/org-capture-node "zettel" "_history"))
(defun savolla/org-capture-zettel-analogy      () (interactive) (savolla/org-capture-node "zettel" "_analogy"))
(defun savolla/org-capture-zettel-reference    () (interactive) (savolla/org-capture-node "zettel" "_reference"))
(defun savolla/org-capture-zettel-bookmark     () (interactive) (savolla/org-capture-node "zettel" "_bookmark"))
(defun savolla/org-capture-zettel-warning      () (interactive) (savolla/org-capture-node "zettel" "_warning"))
(defun savolla/org-capture-zettel-bestpractice () (interactive) (savolla/org-capture-node "zettel" "_bestpractice"))
(defun savolla/org-capture-zettel-fact         () (interactive) (savolla/org-capture-node "zettel" "_fact"))
(defun savolla/org-capture-zettel-tradeoff     () (interactive) (savolla/org-capture-node "zettel" "_tradeoff"))
(defun savolla/org-capture-zettel-comparison   () (interactive) (savolla/org-capture-node "zettel" "_comparison"))
(defun savolla/org-capture-zettel-fix          () (interactive) (savolla/org-capture-node "zettel" "_fix"))
(defun savolla/org-capture-zettel-usecase      () (interactive) (savolla/org-capture-node "zettel" "_usecase"))
(defun savolla/org-capture-zettel-mechanism    () (interactive) (savolla/org-capture-node "zettel" "_mechanism"))
(defun savolla/org-capture-zettel-property     () (interactive) (savolla/org-capture-node "zettel" "_property"))

;; biblio variants
(defun savolla/org-capture-biblio-term         () (interactive) (savolla/org-capture-node "biblio" "_term"))
(defun savolla/org-capture-biblio-abbr         () (interactive) (savolla/org-capture-node "biblio" "_abbr"))
(defun savolla/org-capture-biblio-method       () (interactive) (savolla/org-capture-node "biblio" "_method"))
(defun savolla/org-capture-biblio-history      () (interactive) (savolla/org-capture-node "biblio" "_history"))
(defun savolla/org-capture-biblio-analogy      () (interactive) (savolla/org-capture-node "biblio" "_analogy"))
(defun savolla/org-capture-biblio-reference    () (interactive) (savolla/org-capture-node "biblio" "_reference"))
(defun savolla/org-capture-biblio-warning      () (interactive) (savolla/org-capture-node "biblio" "_warning"))
(defun savolla/org-capture-biblio-bestpractice () (interactive) (savolla/org-capture-node "biblio" "_bestpractice"))
(defun savolla/org-capture-biblio-fact         () (interactive) (savolla/org-capture-node "biblio" "_fact"))
(defun savolla/org-capture-biblio-tradeoff     () (interactive) (savolla/org-capture-node "biblio" "_tradeoff"))
(defun savolla/org-capture-biblio-comparison   () (interactive) (savolla/org-capture-node "biblio" "_comparison"))
(defun savolla/org-capture-biblio-fix          () (interactive) (savolla/org-capture-node "biblio" "_fix"))
(defun savolla/org-capture-biblio-usecase      () (interactive) (savolla/org-capture-node "biblio" "_usecase"))
(defun savolla/org-capture-biblio-mechanism    () (interactive) (savolla/org-capture-node "biblio" "_mechanism"))
(defun savolla/org-capture-biblio-property     () (interactive) (savolla/org-capture-node "biblio" "_property"))


;; key mappings/bindings
(map! :leader :desc "go"           "j g")
(map! :leader :desc "current day"  "j g c" #'org-roam-dailies-goto-today)
(map! :leader :desc "yesterday"    "j g y" #'org-roam-dailies-goto-yesterday)
(map! :leader :desc "tomorrow"     "j g t" #'org-roam-dailies-goto-tomorrow)
(map! :leader :desc "pick date"    "j g g" #'org-roam-dailies-goto-date)
(map! :leader :desc "next day"     "j g n" #'org-roam-dailies-goto-next-note)
(map! :leader :desc "previous day" "j g p" #'org-roam-dailies-goto-previous-note)
(map! :leader :desc "index"        "j g i" (lambda () (interactive) (find-file "~/resource/notes/org/roam/index.org")))
(map! :leader :desc "agenda"       "j g a")
(map! :leader :desc "personal"     "j g a p" (lambda () (interactive) (find-file "~/resource/notes/org/roam/agenda/personal.org")))
(map! :leader :desc "kartaca"      "j g a k" (lambda () (interactive) (find-file "~/resource/notes/org/roam/agenda/kartaca.org")))

(map! :leader :desc "insert"       "j i")
(map! :leader :desc "flashcard"    "j i f")
(map! :leader :desc "normal"       "j i f n"   #'savolla/org-capture-fc-normal)
(map! :leader :desc "double"       "j i f d"   #'savolla/org-capture-fc-double)
(map! :leader :desc "cloze"        "j i f c"   #'savolla/org-capture-fc-cloze)
(map! :leader :desc "input"        "j i f i"   #'savolla/org-capture-fc-input)

(map! :leader :desc "zettel"       "j i z")
(map! :leader :desc "term"         "j i z t"   #'savolla/org-capture-zettel-term)
(map! :leader :desc "abbr"         "j i z a"   #'savolla/org-capture-zettel-abbr)
(map! :leader :desc "analogy"      "j i z A"   #'savolla/org-capture-zettel-analogy)
(map! :leader :desc "history"      "j i z h"   #'savolla/org-capture-zettel-history)
(map! :leader :desc "fact"         "j i z f"   #'savolla/org-capture-zettel-fact)
(map! :leader :desc "property"     "j i z p"   #'savolla/org-capture-zettel-property)
(map! :leader :desc "mechanism"    "j i z M"   #'savolla/org-capture-zettel-mechanism)
(map! :leader :desc "method"       "j i z m"   #'savolla/org-capture-zettel-method)
(map! :leader :desc "comparison"   "j i z c"   #'savolla/org-capture-zettel-comparison)
(map! :leader :desc "usecase"      "j i z u"   #'savolla/org-capture-zettel-usecase)
(map! :leader :desc "tradeoff"     "j i z T"   #'savolla/org-capture-zettel-tradeoff)
(map! :leader :desc "bestpractice" "j i z b"   #'savolla/org-capture-zettel-bestpractice)
(map! :leader :desc "warning"      "j i z w"   #'savolla/org-capture-zettel-warning)
(map! :leader :desc "fix"          "j i z F"   #'savolla/org-capture-zettel-fix)
(map! :leader :desc "reference"    "j i z r"   #'savolla/org-capture-zettel-reference)
(map! :leader :desc "bookmark"     "j i z B"   #'savolla/org-capture-zettel-bookmark)

(map! :leader :desc "biblio"       "j i b")
(map! :leader :desc "term"         "j i b t"   #'savolla/org-capture-biblio-term)
(map! :leader :desc "abbr"         "j i b a"   #'savolla/org-capture-biblio-abbr)
(map! :leader :desc "analogy"      "j i b A"   #'savolla/org-capture-biblio-analogy)
(map! :leader :desc "history"      "j i b h"   #'savolla/org-capture-biblio-history)
(map! :leader :desc "fact"         "j i b f"   #'savolla/org-capture-biblio-fact)
(map! :leader :desc "property"     "j i b p"   #'savolla/org-capture-biblio-property)
(map! :leader :desc "mechanism"    "j i b M"   #'savolla/org-capture-biblio-mechanism)
(map! :leader :desc "method"       "j i b m"   #'savolla/org-capture-biblio-method)
(map! :leader :desc "comparison"   "j i b c"   #'savolla/org-capture-biblio-comparison)
(map! :leader :desc "usecase"      "j i b u"   #'savolla/org-capture-biblio-usecase)
(map! :leader :desc "tradeoff"     "j i b T"   #'savolla/org-capture-biblio-tradeoff)
(map! :leader :desc "bestpractice" "j i b b"   #'savolla/org-capture-biblio-bestpractice)
(map! :leader :desc "warning"      "j i b w"   #'savolla/org-capture-biblio-warning)
(map! :leader :desc "fix"          "j i b F"   #'savolla/org-capture-biblio-fix)
(map! :leader :desc "reference"    "j i b r"   #'savolla/org-capture-biblio-reference)

(map! :leader :desc "highlight"    "j i h")
(map! :leader :desc "term"         "j i h t"   #'savolla/pdf-highlight-term)
(map! :leader :desc "abbr"         "j i h a"   #'savolla/pdf-highlight-abbr)
(map! :leader :desc "analogy"      "j i h A"   #'savolla/pdf-highlight-analogy)
(map! :leader :desc "history"      "j i h h"   #'savolla/pdf-highlight-history)
(map! :leader :desc "fact"         "j i h f"   #'savolla/pdf-highlight-fact)
(map! :leader :desc "property"     "j i h p"   #'savolla/pdf-highlight-property)
(map! :leader :desc "mechanism"    "j i h M"   #'savolla/pdf-highlight-mechanism)
(map! :leader :desc "method"       "j i h m"   #'savolla/pdf-highlight-method)
(map! :leader :desc "comparison"   "j i h c"   #'savolla/pdf-highlight-comparison)
(map! :leader :desc "usecase"      "j i h u"   #'savolla/pdf-highlight-usecase)
(map! :leader :desc "tradeoff"     "j i h T"   #'savolla/pdf-highlight-tradeoff)
(map! :leader :desc "bestpractice" "j i h b"   #'savolla/pdf-highlight-bestpractice)
(map! :leader :desc "warning"      "j i h w"   #'savolla/pdf-highlight-warning)
(map! :leader :desc "fix"          "j i h F"   #'savolla/pdf-highlight-fix)
(map! :leader :desc "reference"    "j i h r"   #'savolla/pdf-highlight-reference)

(map! :leader :desc "agenda"       "j i a")
(map! :leader :desc "personal"     "j i a p")
(map! :leader :desc "birthday"     "j i a p b" #'savolla/org-insert-agenda-personal-birthday)
(map! :leader :desc "habit"        "j i a p h" #'savolla/org-insert-agenda-personal-habit)
(map! :leader :desc "person"       "j i a p p" #'savolla/org-insert-agenda-personal-person)
(map! :leader :desc "location"     "j i a p l" #'savolla/org-insert-agenda-personal-location)
(map! :leader :desc "phone"        "j i a p n" #'savolla/org-insert-agenda-personal-phone)
(map! :leader :desc "task"         "j i a p t" #'savolla/org-insert-agenda-personal-todo)
(map! :leader :desc "today"        "j i a p y" #'savolla/org-insert-agenda-personal-todo-today)
(map! :leader :desc "weekend"      "j i a p w" #'savolla/org-insert-agenda-personal-todo-weekend)
(map! :leader :desc "scheduled"    "j i a p s" #'savolla/org-insert-agenda-personal-todo-scheduled)
(map! :leader :desc "deadline"     "j i a p d" #'savolla/org-insert-agenda-personal-todo-deadline)

(map! :leader :desc "work"         "j i a w")
(map! :leader :desc "task"         "j i a w t")
(map! :leader :desc "todo"         "j i a w t t"  #'savolla/org-insert-agenda-work-todo)
(map! :leader :desc "today"        "j i a w t y"  #'savolla/org-insert-agenda-work-today)
(map! :leader :desc "job"          "j i a w t j"  #'savolla/org-insert-agenda-work-job)
(map! :leader :desc "scheduled"    "j i a w t s"  #'savolla/org-insert-agenda-work-scheduled)
(map! :leader :desc "deadline"     "j i a w t d"  #'savolla/org-insert-agenda-work-deadline)

(map! :leader :desc "sync position"  "j n" #'org-noter-sync-current-note)
(map! :leader :desc "journal entry" "j j" #'savolla/org-insert-journal-entry)
(map! :leader :desc "select window" "f w" #'ace-window)
(map! :leader :desc "select window" "w w" #'evil-window-mru)

;; add new line on save (for sonarqube)
(setq-default require-final-newline t)

(defun my-startup-setup ()
  (run-at-time
   "1 sec" nil
   (lambda ()
     (+workspace-rename "main" "journal")
     (delete-other-windows)

     ;; Left: journal
     (org-roam-dailies-goto-today)
     (let ((journal-window (selected-window))
           agenda-window)

       ;; Right: agenda
       (setq agenda-window (split-window-right))
       (select-window agenda-window)
       (org-agenda nil "p")
       (text-scale-set -1)

       ;; Back to journal
       (select-window journal-window)
       (cd "~/")
       (goto-char (point-max))))))

(add-hook 'emacs-startup-hook #'my-startup-setup)
