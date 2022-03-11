#lang racket/base


(module reader racket/base
  

  (provide read-syntax)


  (require j-notation/grammar
           j-notation/lexer)
  

  (define (read-syntax path port)
    (define parse-tree (parse path (make-tokenizer port)))
    (define module-datum
      `(module bf-mod racket/base
         ',parse-tree))
    (datum->syntax #f module-datum)))
