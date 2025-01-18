#lang j-notation


// Expressions can have attributes.
#[unsafe] doCrimes();


// Expressions can have multiple attributes.
#[foo] #[bar] doCrimes();


// Attribute contents can be expressions.
#[foo(1)]
#[bar + baz]
doCrimes();


// Attributes apply to the whole invocation chain.
#[foo] a.b().c();


// Attributes do not apply to whole operations.
#[foo] a + b;


// Expression grouping can force attributes to apply to certain expressions.
(#[foo] a).b();
#[foo] (a + b);

// Block expressions can have attributes
#[foo] a {
  b;
  c;
  d;
};

// Attributes apply to the whole block chain when multiple blocks exist
#[foo] a { b } { c };

// Expression grouping can force attributes to apply to certain block expressions
(#[foo] a { b }) { c };
