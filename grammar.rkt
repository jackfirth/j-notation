#lang brag

@body: () | /SEMICOLON | inline-group | end-group | inline-group /SEMICOLON body | end-group body
@group-list: () | /COMMA | group | group /COMMA group-list

@group: inline-group | end-group
inline-group: inline-expression+
end-group: inline-expression* end-block

@inline-expression: atom | parens | brackets | inline-block | string-template

@atom: NAME | OPERATOR | LITERAL-INTEGER | LITERAL-DECIMAL | LITERAL-STRING
parens: /LEFT-PARENTHESIS group-list /RIGHT-PARENTHESIS
brackets: /LEFT-SQUARE-BRACKET group-list /RIGHT-SQUARE-BRACKET
inline-block: /LEFT-CURLY-BRACKET body /RIGHT-CURLY-BRACKET
end-block: /LEFT-CURLY-BRACKET body /RIGHT-CURLY-BRACKET-AND-NEWLINE

string-template:
  LEFT-STRING-TEMPLATE group (MIDDLE-STRING-TEMPLATE group)* RIGHT-STRING-TEMPLATE
