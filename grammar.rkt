#lang brag

program: statement*
block: /"{" statement* /"}"
@statement: assignment-statement | expression-statement
@assignment-statement: assignment /";"
@expression-statement: inline-expression /";" | block-expression
assignment: expression /"=" expression

# EXPRESSIONS

@expression: inline-expression | block-expression

inline-expression:
  operator-name* single-inline-expression (operator-name+ single-inline-expression)* operator-name*
single-inline-expression: attribute* [header] chain-expression annotation*

block-expression: attribute* [header] chain-expression annotation* block*

@header: modifier* kind
modifier: name
kind: name
chain-expression: atomic-expression (reference | selection | invocation)*
@atomic-expression: name | literal | /"(" @expression /")"

# BASICS

name: SIMPLE-NAME
operator-name: SIMPLE-OPERATOR-NAME
literal: LITERAL-INTEGER | LITERAL-DECIMAL | LITERAL-STRING
reference: /"." name
attribute: /"#" /"[" expression /"]"
annotation: /":" inline-expression
invocation: /"(" parameter-list /")"
selection: /"[" parameter-list /"]"
@parameter-list: [parameter (/"," parameter)* [/","]]
@parameter: assignment | expression
