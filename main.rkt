#lang racket/base


(module reader racket/base
  

  (provide read-syntax)


  (require j-notation/grammar
           j-notation/lexer
           syntax/parse)
  

  (define (read-syntax path port)
    (syntax-parse (parse path (make-tokenizer port))
      #:datum-literals (program)
      [(program statement ...) #'(module j-notation racket/base 'statement ...)])))
