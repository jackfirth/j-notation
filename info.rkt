#lang info

(define collection "j-notation")

(define scribblings
  (list (list "main.scrbl"
              (list 'multi-page)
              (list 'library)
              "j-notation")))

(define deps
  (list "brag-lib"
        "base"
        "resyntax"))

(define build-deps
  (list "racket-doc"
        "rackunit-lib"
        "scribble-lib"))
