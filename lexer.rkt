#lang racket/base


(provide make-tokenizer)


(require brag/support
         racket/string)


;@----------------------------------------------------------------------------------------------------


(define-lex-abbrev whitespace-excluding-newline (:& whitespace (:~ "\n")))


(define-lex-abbrev line-comment (from/to "//" "\n"))


(define-lex-abbrev literal-single-line-string
  (:- (from/to "\"" "\"") (:seq any-string "\n" any-string)))

(define-lex-abbrev literal-multiline-string (from/to "\"\"\"\n" "\"\"\""))
(define-lex-abbrev literal-integer (:+ (char-set "0123456789")))

(define-lex-abbrev literal-decimal
  (:or (:seq (:? literal-integer) "." literal-integer) (:seq literal-integer ".")))


(define-lex-abbrev name (:seq alphabetic (:* (:or alphabetic numeric "_"))))
(define-lex-abbrev operator (:+ (char-set "#.!=<>+-/*^%:")))


(struct lexer-result (token next-mode) #:transparent)


(define j-notation-lexer
  (lexer
   [line-comment
    (lexer-result (make-srcloc-token (token 'LINE-COMMENT #:skip? #true) lexeme-srcloc)
                  j-notation-lexer)]
   [(:seq (:* whitespace-excluding-newline) "\n")
    (lexer-result (make-srcloc-token (token 'WHITESPACE #:skip? #true) lexeme-srcloc)
                  j-notation-lexer)]
   [(:+ whitespace-excluding-newline)
    (lexer-result (make-srcloc-token (token 'WHITESPACE #:skip? #true) lexeme-srcloc)
                  j-notation-lexer)]
   [";" (lexer-result (make-srcloc-token (token 'SEMICOLON) lexeme-srcloc) j-notation-lexer)]
   ["," (lexer-result (make-srcloc-token (token 'COMMA) lexeme-srcloc) j-notation-lexer)]
   ["["
    (lexer-result (make-srcloc-token (token 'LEFT-SQUARE-BRACKET) lexeme-srcloc) j-notation-lexer)]
   ["]"
    (lexer-result (make-srcloc-token (token 'RIGHT-SQUARE-BRACKET) lexeme-srcloc) j-notation-lexer)]
   ["(" (lexer-result (make-srcloc-token (token 'LEFT-PARENTHESIS) lexeme-srcloc) j-notation-lexer)]
   [")" (lexer-result (make-srcloc-token (token 'RIGHT-PARENTHESIS) lexeme-srcloc) j-notation-lexer)]
   ["{" (lexer-result (make-srcloc-token (token 'LEFT-CURLY-BRACKET) lexeme-srcloc) j-notation-lexer)]
   ["}"
    (lexer-result (make-srcloc-token (token 'RIGHT-CURLY-BRACKET) lexeme-srcloc) j-notation-lexer)]
   [(:seq "}" (:* whitespace-excluding-newline) "\n")
    (lexer-result (make-srcloc-token (token 'RIGHT-CURLY-BRACKET-AND-NEWLINE) lexeme-srcloc)
                  j-notation-lexer)]
   [name
    (lexer-result (make-srcloc-token (token 'NAME (string->symbol lexeme)) lexeme-srcloc)
                  j-notation-lexer)]
   [operator
    (lexer-result (make-srcloc-token (token 'OPERATOR (string->symbol lexeme)) lexeme-srcloc)
                  j-notation-lexer)]
   [literal-integer
    (lexer-result (make-srcloc-token (token 'LITERAL-INTEGER (string->number lexeme)) lexeme-srcloc)
                  j-notation-lexer)]
   [literal-decimal
    (lexer-result (make-srcloc-token (token 'LITERAL-DECIMAL (string->number lexeme)) lexeme-srcloc)
                  j-notation-lexer)]
   [literal-single-line-string
    (let ()
      (define raw-token (token 'LITERAL-STRING (substring lexeme 1 (sub1 (string-length lexeme)))))
      (lexer-result (make-srcloc-token raw-token lexeme-srcloc) j-notation-lexer))]
   [literal-multiline-string
    (let ()
      (define indentation (position-col start-pos))
      (define indented-string (substring lexeme 3 (- (string-length lexeme) 3)))
      (define without-indentation
        (string-replace indented-string (string-append "\n" (make-string indentation #\space)) "\n"))
      (define raw-token (token 'LITERAL-STRING without-indentation))
      (lexer-result (make-srcloc-token raw-token lexeme-srcloc) j-notation-lexer))]))


(define (make-tokenizer port)
  (define lexer j-notation-lexer)
  (λ ()
    (define result (lexer port))
    (cond
      [(eof-object? result) result]
      [else
       (set! lexer (lexer-result-next-mode result))
       (lexer-result-token result)])))
