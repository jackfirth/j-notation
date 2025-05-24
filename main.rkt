#lang racket/base


(module reader racket/base
  

  (provide read-syntax)


  (require j-notation/grammar
           j-notation/lexer
           resyntax/private/syntax-traversal
           syntax/parse)
  

  (define (read-syntax path port)
    (define raw-parsed-syntax (parse path (make-tokenizer port)))
    (define normalized-parsed-syntax
      (syntax-traverse raw-parsed-syntax
        #:datum-literals (inline-group end-group inline-block end-block)
        [(~or inline-group end-group) (datum->syntax this-syntax 'group this-syntax this-syntax)]
        [(~or inline-block end-block) (datum->syntax this-syntax 'block this-syntax this-syntax)]))
    (syntax-parse normalized-parsed-syntax
      #:datum-literals (program)
      [(body statement ...) #'(module j-notation racket/base 'statement ...)])))
