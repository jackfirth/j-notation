#lang brag

@body: () | /";" | group | group /";" body
@group-list: () | /"," | group | group /"," group-list

group: expression+
@expression: atom | parens | brackets | block

@atom: NAME | OPERATOR | LITERAL-INTEGER | LITERAL-DECIMAL | LITERAL-STRING
parens: /"(" group-list /")"
brackets: /"[" group-list /"]"
block: /"{" body /"}"
