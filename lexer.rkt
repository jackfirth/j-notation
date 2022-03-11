#lang racket/base


(provide make-tokenizer)


(require brag/support)


(define-lex-abbrev digits (:+ (char-set "0123456789")))


(define (make-tokenizer port)
  (define (next-token)
    (define bf-lexer
      (lexer-srcloc
       [(from/to "//" "\n") (next-token)]
       [whitespace (token lexeme #:skip? #true)]
       [(:+ alphabetic) (token 'SIMPLE-NAME lexeme)]
       [digits (token 'LITERAL-INTEGER (string->number lexeme))]
       [(:or (:seq (:? digits) "." digits) (:seq digits "."))
        (token 'LITERAL-DECIMAL (string->number lexeme))]
       [(from/to "\"" "\"")
        (token 'LITERAL-STRING
               (substring lexeme 1 (sub1 (string-length lexeme))))]
       [any-char lexeme]))
    (bf-lexer port))
  next-token)
