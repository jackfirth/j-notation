#lang brag

program: statement*
@statement:
  declaration /";"
  | inline-definition /";"
  | reassignment /";"
  | inline-expression /";"
  | block-definition
  | block-expression
block: /"{" statement* /"}"

# NAMES

name: @unindexed-name index-selection*
unindexed-name: @qualifier* SIMPLE-NAME
unqualified-name: SIMPLE-NAME index-selection*
qualifier: @unqualified-name /"."
index-selection: /"[" [expression (/"," expression)* [/","]] /"]"
operator-name: @qualifier* SIMPLE-OPERATOR-NAME

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
declaration: attribute* modifier* kind header annotation*
modifier: name
kind: name

contextual-declaration: attribute* modifier* header annotation*
@header: unindexed-name indices-specification* [components-specification]
components-specification:
  /"(" [contextual-specification (/"," contextual-specification)* [/","]] /")"
indices-specification: /"[" [contextual-specification (/"," contextual-specification)* [/","]] /"]"
annotation: /":" expression
attribute: /"#" /"[" expression /"]"

# STATEMENTS

/assignment: /"=" expression
reassignment: name assignment
@specification: declaration | definition
@contextual-specification: contextual-declaration | contextual-definition
@inline-specification: declaration | inline-definition
@definition: inline-definition | block-definition
contextual-definition: contextual-declaration (assignment | block)
inline-definition: @declaration assignment
block-definition: @declaration block

# EXPRESSIONS

@expression: @inline-expression | @block-expression
inline-expression:
  attribute* @attributeless-inline-expression
attributeless-inline-expression:
  reference | literal | inline-invocation | inline-operation | /"(" expression /")"
reference: @name
block-expression: attribute* (block-invocation | block-operation)

inline-invocation:
  [@attributeless-inline-expression /"."]
  unqualified-name
  parameters
block-invocation:
  @inline-invocation block
parameters:   /"(" [(expression | reassignment) (/"," (expression | reassignment))* [/","]] /")"


inline-operation:
  inline-expression operator-name inline-expression
block-operation:
  inline-expression operator-name block-expression

literal: LITERAL-INTEGER | LITERAL-DECIMAL | LITERAL-STRING
