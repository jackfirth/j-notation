#lang brag

@body: () | /";" | inline-group | end-group | inline-group /";" body | end-group body
@group-list: () | /"," | group | group /"," group-list

@group: inline-group | end-group
inline-group: inline-expression+
end-group: inline-expression* end-block

@inline-expression: atom | parens | brackets | inline-block

@atom: NAME | OPERATOR | LITERAL-INTEGER | LITERAL-DECIMAL | LITERAL-STRING
parens: /"(" group-list /")"
brackets: /"[" group-list /"]"
inline-block: /"{" body /"}"
end-block: /"{" body /CLOSING-BRACE-AND-NEWLINE
