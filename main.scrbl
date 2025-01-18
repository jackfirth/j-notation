#lang scribble/manual


@(require scribble/bnf)


@title{J-Notation}
@defmodule[j-notation]

@(define group @nonterm{group})
@(define expression @nonterm{expression})
@(define identifier @nonterm{identifier})
@(define value @nonterm{value})
@(define parenthesized-groups @nonterm{parenthesized-groups})
@(define bracketed-groups @nonterm{bracketed-groups})
@(define block @nonterm{block})
@(define group-list @nonterm{group-list})
@(define body @nonterm{body})


@BNF[
 (list group @kleeneplus[expression])

 (list expression
       identifier
       value
       parenthesized-groups
       bracketed-groups
       block)

 (list parenthesized-groups @BNF-seq[@litchar{(} group-list @litchar{)}])
 (list bracketed-groups @BNF-seq[@litchar{[} group-list @litchar{]}])

 (list block @BNF-seq[@litchar["{"] body @litchar["}"]])

 (list group-list
       @BNF-seq[group @optional[@litchar{,}]]
       @BNF-seq[group @litchar{,} group-list])

 (list body
       @BNF-seq[group @optional[@litchar{;}]]
       @BNF-seq[group @litchar{;} body])]
