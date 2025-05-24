#lang racket/base


(provide make-tokenizer)


(require brag/support)


;@----------------------------------------------------------------------------------------------------


(define-lex-abbrev whitespace-excluding-newline (:& whitespace (:~ "\n")))


(define-lex-abbrev line-comment (from/to "//" "\n"))


(define-lex-abbrev literal-string (:- (from/to "\"" "\"") (:seq any-string "\n" any-string)))
(define-lex-abbrev literal-integer (:+ (char-set "0123456789")))
(define-lex-abbrev literal-decimal
  (:or (:seq (:? literal-integer) "." literal-integer) (:seq literal-integer ".")))


(define-lex-abbrev name (:seq alphabetic (:* (:or alphabetic numeric "_"))))
(define-lex-abbrev operator (:+ (char-set "#.!=<>+-/*^%:")))


(define j-notation-lexer
  (lexer-srcloc
   [line-comment (token 'LINE-COMMENT #:skip? #true)]
   [(:seq (:* whitespace-excluding-newline) "\n") (token 'WHITESPACE #:skip? #true)]
   [(:+ whitespace-excluding-newline) (token 'WHITESPACE #:skip? #true)]
   [";" (token 'SEMICOLON)]
   ["," (token 'COMMA)]
   ["[" (token 'LEFT-SQUARE-BRACKET)]
   ["]" (token 'RIGHT-SQUARE-BRACKET)]
   ["(" (token 'LEFT-PARENTHESIS)]
   [")" (token 'RIGHT-PARENTHESIS)]
   ["{" (token 'LEFT-CURLY-BRACKET)]
   ["}" (token 'RIGHT-CURLY-BRACKET)]
   [(:seq "}" (:* whitespace-excluding-newline) "\n") (token 'RIGHT-CURLY-BRACKET-AND-NEWLINE)]
   [name (token 'NAME (string->symbol lexeme))]
   [operator (token 'OPERATOR (string->symbol lexeme))]
   [literal-integer (token 'LITERAL-INTEGER (string->number lexeme))]
   [literal-decimal (token 'LITERAL-DECIMAL (string->number lexeme))]
   [literal-string (token 'LITERAL-STRING (substring lexeme 1 (sub1 (string-length lexeme))))]))


(define ((make-tokenizer port))
  (j-notation-lexer port))
