#lang scribble/manual


@(require scribble/bnf)


@title{J-Notation}
@defmodule[j-notation]

@(define body @nonterm{body})
@(define group @nonterm{group})
@(define expression @nonterm{expression})
@(define name @nonterm{name})
@(define operator @nonterm{operator})
@(define literal-value @nonterm{literal-value})
@(define parens @nonterm{parens})
@(define brackets @nonterm{brackets})
@(define block @nonterm{block})
@(define group-list @nonterm{group-list})


@BNF[
 (list body
       @BNF-seq[]
       @BNF-seq[group]
       @BNF-seq[group @litchar{;} body])

 (list group-list
       @BNF-seq[]
       @BNF-seq[group]
       @BNF-seq[group @litchar{,} group-list])

 (list group @kleeneplus[expression])

 (list expression
       name
       operator
       literal-value
       parens
       brackets
       block)

 (list parens @BNF-seq[@litchar{(} group-list @litchar{)}])
 (list brackets @BNF-seq[@litchar{[} group-list @litchar{]}])
 (list block @BNF-seq[@litchar["{"] body @litchar["}"]])]
