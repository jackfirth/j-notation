#lang j-notation

sealed class Foo
    : extends(SuperFoo)
    // Possible alternate syntax: `: implements Printable, Evalable, Parseable`
    : implements(Printable, Evalable, Parseable)
    : permits(GreenFoo, BlueFoo, RedFoo) {

  val bar: Int = 42;
  val bar2: Int =
      someLongExpression();

  field blah: Int;
  mutable field blah2: Int = 0;

  constructor Foo() {
    blah2 = 42;
  };

  getter baz: Int {
  };

  setter baz(input: Int) {
  };

  method doThing() {
  };

  method Bar.doThing() {
  };
}

#[version("1.4.2")]
#[deprecated]
record Point(x: Double, y: Double) {
  method add(Point(x2, y2)) {
    Point(x + x2, y + y2);
  };
};

record Pair[A, B](left: A, right: B) {
};

// GADT (Genearlized Algebraic Data Type) example. Usage:
//
// ```
// Expression[Bool] expr =
//     Expression(5).add(Expression(10)).equals(Expression(15));
// ```
sealed interface Expression[T] {

  constructor Expression(value: Int) = IntLiteral(value);
  constructor Expression(value: Bool) = BoolLiteral(value);

  method evaluate(): T;

  // Only callable on `Expression[Int]`, not just any `Expression`
  method Expression[Int].add(other: Expression[Int])
      : Expression[Int] {
    AddExpression(this, other);
  };

  method equals(other: Expression[T]): Expression[Bool] {
    EqualsExpression(this, other);
  };

  permitted record IntLiteral(value: Int): implements(Expression[Int]) {
    method evaluate(): Int = value;
  };

  permitted record BoolLiteral(value: Bool): implements(Expression[Bool]) {
    method evaluate(): Bool = value;
  };

  permitted record AddExpression(left: Expression[Int], right: Expression[Int])
      : implements(Expression[Int]) {
    method evalute(): Int = left.evaluate() + right.evaluate();
  };

  permitted record EqualsExpression[T](
          left: Expression[T], right: Expression[T])
      : implements(Expression[Bool]) {
    method evaluate(): Bool = left.evaluate() == right.evaluate();
  };
};

// Kind polymorphism in the style of haskell GHC -XPolyKinds.
// Intended to be equivalent to this haskell code:
//
// ```haskell
// data T (m :: k -> *) a = MkT (m a)
// ```
record T[K][M: K -> Type, A](val: M[A]);

// Dots and brackets should be usable to qualify and index names
SomeClass.SomeObjectList[42].SomeMatrixField[5][6] = 100;
f(SomeClass.SomeObjectList[42].SomeMatrixField[5][6]);
