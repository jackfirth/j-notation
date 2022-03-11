#lang info

(define collection "j-notation")

(define scribblings
  (list (list "main.scrbl"
              (list 'multi-page)
              (list 'library)
              "j-notation")))

(define deps
  (list "base"))

(define build-deps
  (list "racket-doc"
        "rackunit-lib"
        "scribble-lib"))
