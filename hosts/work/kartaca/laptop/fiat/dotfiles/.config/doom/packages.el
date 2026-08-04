;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el
(package! solaire-mode :disable t)
(package! engrave-faces) ;; latex export code blocks with highlight
(package! org-roam-ql)
(package! org-ql)
(package! org-habit-stats) ;; display stats for habits
(package! org-transclusion)
(package! calibredb)

(package! eat
  :recipe (:host codeberg
       :repo "akib/emacs-eat"
       :files ("*.el" ("term" "term/*.el") "*.texi"
               "*.ti" ("terminfo/e" "terminfo/e/*")
               ("terminfo/65" "terminfo/65/*")
               ("integration" "integration/*")
               (:exclude ".dir-locals.el" "*-tests.el"))))

(package! org-fc
  :recipe (:host nil
           :repo "https://git.sr.ht/~l3kn/org-fc"
           :files (:defaults "awk" "demo.org")))

;; d2 diagramming for org mode
(package! d2-mode)
(package! ob-d2 :recipe (:host github :repo "dmacvicar/ob-d2"))

;; (package! jira)
(package! org-jira)
