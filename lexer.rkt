#lang racket/base


(provide make-tokenizer)


(require brag/support
         racket/list
         racket/match
         racket/string)


;@----------------------------------------------------------------------------------------------------


(define-lex-abbrev whitespace-excluding-newline (:& whitespace (:~ "\n")))
(define-lex-abbrev not-containing-newline (complement (:seq any-string "\n" any-string)))


(define-lex-abbrev line-comment (from/to "//" "\n"))


(define-lex-abbrev literal-single-line-string
  (:& (from/to "\"" "\"") not-containing-newline (complement (:seq any-string "$" any-string))))


(define-lex-abbrev literal-multiline-string (from/to "\"\"\"\n" "\"\"\""))


(define-lex-abbrev literal-left-string-line-template-piece
  (:& (from/to "\"" "${")
      not-containing-newline
      (complement (:seq "\"" any-string "\"" any-string))))


(define-lex-abbrev literal-middle-string-line-template-piece
  (:& (from/to "}" "${")
      not-containing-newline
      (complement (:seq any-string "\"" any-string))))


(define-lex-abbrev literal-right-string-line-template-piece
  (:& (from/to "}" "\"")
      not-containing-newline
      (complement (:seq any-string "\"" any-string "\""))
      (complement (:seq any-string "${" any-string "\""))))


(define-lex-abbrev literal-integer (:+ (char-set "0123456789")))


(define-lex-abbrev literal-decimal
  (:or (:seq (:? literal-integer) "." literal-integer) (:seq literal-integer ".")))


(define-lex-abbrev name (:seq alphabetic (:* (:or alphabetic numeric "_"))))
(define-lex-abbrev operator (:+ (char-set "#.!=<>+-/*^%:")))


(struct lexer-result (token mode-action) #:transparent)

(struct push-mode (lexer) #:transparent)
(struct pop-mode () #:transparent)


(define j-notation-lexer
  (lexer
   [line-comment
    (lexer-result (make-srcloc-token (token 'LINE-COMMENT #:skip? #true) lexeme-srcloc) #false)]
   [(:seq (:* whitespace-excluding-newline) "\n")
    (lexer-result (make-srcloc-token (token 'WHITESPACE #:skip? #true) lexeme-srcloc) #false)]
   [(:+ whitespace-excluding-newline)
    (lexer-result (make-srcloc-token (token 'WHITESPACE #:skip? #true) lexeme-srcloc) #false)]
   [";" (lexer-result (make-srcloc-token (token 'SEMICOLON) lexeme-srcloc) #false)]
   ["," (lexer-result (make-srcloc-token (token 'COMMA) lexeme-srcloc) #false)]
   ["[" (lexer-result (make-srcloc-token (token 'LEFT-SQUARE-BRACKET) lexeme-srcloc) #false)]
   ["]" (lexer-result (make-srcloc-token (token 'RIGHT-SQUARE-BRACKET) lexeme-srcloc) #false)]
   ["(" (lexer-result (make-srcloc-token (token 'LEFT-PARENTHESIS) lexeme-srcloc) #false)]
   [")" (lexer-result (make-srcloc-token (token 'RIGHT-PARENTHESIS) lexeme-srcloc) #false)]
   ["{" (lexer-result (make-srcloc-token (token 'LEFT-CURLY-BRACKET) lexeme-srcloc) #false)]
   ["}" (lexer-result (make-srcloc-token (token 'RIGHT-CURLY-BRACKET) lexeme-srcloc) #false)]
   [(:seq "}" (:* whitespace-excluding-newline) "\n")
    (lexer-result (make-srcloc-token (token 'RIGHT-CURLY-BRACKET-AND-NEWLINE) lexeme-srcloc)
                  #false)]
   [name
    (lexer-result (make-srcloc-token (token 'NAME (string->symbol lexeme)) lexeme-srcloc)
                  #false)]
   [operator
    (lexer-result (make-srcloc-token (token 'OPERATOR (string->symbol lexeme)) lexeme-srcloc)
                  #false)]
   [literal-integer
    (lexer-result (make-srcloc-token (token 'LITERAL-INTEGER (string->number lexeme)) lexeme-srcloc)
                  #false)]
   [literal-decimal
    (lexer-result (make-srcloc-token (token 'LITERAL-DECIMAL (string->number lexeme)) lexeme-srcloc)
                  #false)]
   [literal-single-line-string
    (let ()
      (define raw-token (token 'LITERAL-STRING (substring lexeme 1 (sub1 (string-length lexeme)))))
      (lexer-result (make-srcloc-token raw-token lexeme-srcloc) #false))]
   [literal-multiline-string
    (let ()
      (define indentation (position-col start-pos))
      (define indented-string (substring lexeme 3 (- (string-length lexeme) 3)))
      (define without-indentation
        (string-replace indented-string (string-append "\n" (make-string indentation #\space)) "\n"))
      (define raw-token (token 'LITERAL-STRING without-indentation))
      (lexer-result (make-srcloc-token raw-token lexeme-srcloc) #false))]
   [literal-left-string-line-template-piece
    (let ()
      (define token-value (substring lexeme 1 (- (string-length lexeme) 2)))
      (define raw-token (token 'LEFT-STRING-TEMPLATE token-value))
      (lexer-result (make-srcloc-token raw-token lexeme-srcloc)
                    (push-mode j-notation-template-argument-lexer)))]))


(define j-notation-template-argument-lexer
  (lexer
   [(:+ whitespace-excluding-newline)
    (lexer-result (make-srcloc-token (token 'WHITESPACE #:skip? #true) lexeme-srcloc) #false)]
   [";"
    (lexer-result (make-srcloc-token (token 'SEMICOLON) lexeme-srcloc)
                  #false)]
   [","
    (lexer-result (make-srcloc-token (token 'COMMA) lexeme-srcloc)
                  #false)]
   ["["
    (lexer-result (make-srcloc-token (token 'LEFT-SQUARE-BRACKET) lexeme-srcloc)
                  #false)]
   ["]"
    (lexer-result (make-srcloc-token (token 'RIGHT-SQUARE-BRACKET) lexeme-srcloc)
                  #false)]
   ["("
    (lexer-result (make-srcloc-token (token 'LEFT-PARENTHESIS) lexeme-srcloc)
                  #false)]
   [")"
    (lexer-result (make-srcloc-token (token 'RIGHT-PARENTHESIS) lexeme-srcloc)
                  #false)]
   ["{"
    (lexer-result (make-srcloc-token (token 'LEFT-CURLY-BRACKET) lexeme-srcloc)
                  #false)]
   ["}"
    (lexer-result (make-srcloc-token (token 'RIGHT-CURLY-BRACKET) lexeme-srcloc)
                  #false)]
   [name
    (lexer-result (make-srcloc-token (token 'NAME (string->symbol lexeme)) lexeme-srcloc)
                  #false)]
   [operator
    (lexer-result (make-srcloc-token (token 'OPERATOR (string->symbol lexeme)) lexeme-srcloc)
                  #false)]
   [literal-integer
    (lexer-result (make-srcloc-token (token 'LITERAL-INTEGER (string->number lexeme)) lexeme-srcloc)
                  #false)]
   [literal-decimal
    (lexer-result (make-srcloc-token (token 'LITERAL-DECIMAL (string->number lexeme)) lexeme-srcloc)
                  #false)]
   [literal-middle-string-line-template-piece
    (let ()
      (define token-value (substring lexeme 1 (- (string-length lexeme) 2)))
      (define raw-token (token 'MIDDLE-STRING-TEMPLATE token-value))
      (lexer-result (make-srcloc-token raw-token lexeme-srcloc) #false))]
   [literal-right-string-line-template-piece
    (let ()
      (define token-value (substring lexeme 1 (sub1 (string-length lexeme))))
      (define raw-token (token 'RIGHT-STRING-TEMPLATE token-value))
      (lexer-result (make-srcloc-token raw-token lexeme-srcloc) (pop-mode)))]))


(define (make-tokenizer port)
  (define lexer-stack (list j-notation-lexer))
  (λ ()
    (define result ((first lexer-stack) port))
    (match result
      [(? eof-object?) result]
      [(lexer-result token #false) token]
      [(lexer-result token (push-mode new-lexer))
       (set! lexer-stack (cons new-lexer lexer-stack))
       token]
      [(lexer-result token (pop-mode))
       (set! lexer-stack (rest lexer-stack))
       token])))


(define t (make-tokenizer (open-input-string "print(\"One is ${1}, two is ${2}, three is both.\");\n")))
