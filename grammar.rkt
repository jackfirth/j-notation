#lang brag


# no left recursion


@body: () | /SEMICOLON | inline-group | end-group | inline-group /SEMICOLON body | end-group body
  # never includes: inline-group inline-group
  # can include: inline-group SEMICOLON group
  # can include: end-group group
  # never ends with: inline-group
  # can start with: group
  # can end with: end-group


# for all following rules:
#   never includes: group group
#   never includes: body body


@group-list: () | /COMMA | group | group /COMMA group-list


# for all following rules:
#   never matches: ()
#   no undelimited recursion
#   always starts with: atom | left-delimiter
#   always ends with: atom | right-delimiter


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


left-delimiter: LEFT-PARENTHESIS
              | LEFT-SQUARE-BRACKET
              | LEFT-CURLY-BRACKET
              | LEFT-STRING-TEMPLATE

right-delimiter: RIGHT-PARENTHESIS
               | RIGHT-SQUARE-BRACKET
               | RIGHT-CURLY-BRACKET
               | RIGHT-STRING-TEMPLATE