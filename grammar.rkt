#lang brag

program: statement*
statement:
  declaration ";"
  | inline-definition ";"
  | reassignment ";"
  | inline-expression ";"
  | block-definition
  | block-expression
block: "{" statement* "}"

# NAMES

name: unindexed-name index-selection*
unindexed-name: qualifier* SIMPLE-NAME
unqualified-name: SIMPLE-NAME index-selection*
qualifier: unqualified-name "."
index-selection: "[" [expression ("," expression)* [","]] "]"
operator-name: qualifier* SIMPLE-OPERATOR-NAME

# DECLARATIONS


# Examples:
#
#   class Foo
#       : extends(Bar)
#       : implements(Baz)
#
#   method bar(x: Int, y: Int)
#
#   #[deprecated] mutable val x
#
declaration: attribute* name+ header annotation*


contextual-declaration: attribute* name* header annotation*
header: unindexed-name indices-specification* [components-specification]
components-specification: "(" [contextual-specification ("," contextual-specification)* [","]] ")"
indices-specification: "[" [contextual-specification ("," contextual-specification)* [","]] "]"
annotation: ":" expression
attribute: "#[" expression "]"

# STATEMENTS

assignment: EQUALS-SIGN expression
reassignment: name assignment
specification: declaration | definition
contextual-specification: contextual-declaration | contextual-definition
inline-specification: declaration | inline-definition
definition: inline-definition | block-definition
contextual-definition: contextual-declaration (assignment | block)
inline-definition: declaration assignment
block-definition: declaration block

# EXPRESSIONS

expression: inline-expression | block-expression
inline-expression:
  name | literal | inline-invocation | inline-operation | "(" expression ")"

block-expression:
  block-invocation
  | block-operation

inline-invocation:
  [inline-expression "."] unqualified-name "(" (expression | reassignment) ("," (expression | reassignment))* [","] ")"
block-invocation:
  inline-invocation block

inline-operation:
  inline-expression operator-name inline-expression
block-operation:
  inline-expression operator-name block-expression

literal: LITERAL-INTEGER | LITERAL-DECIMAL | LITERAL-STRING
