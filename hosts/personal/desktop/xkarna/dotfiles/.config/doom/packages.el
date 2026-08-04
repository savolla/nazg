;; -*- no-byte-compile: t; -*-
;;; $DOOMDIR/packages.el
(package! solaire-mode :disable t)
(package! engrave-faces) ;; latex export code blocks with highlight
(package! org-roam-ql)
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

;; ;; elfeed packages
;; (package! elfeed)
;; (package! elfeed-org)
;; (package! elfeed-tube)
;; (package! elfeed-tube-mpv)
