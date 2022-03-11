#lang j-notation

magic record Pair[A, B](left: A, right: B)
    : implements(Serializable, Printable)
    : deriving(Serializable, Printable) {
  method swap(): Pair[B, A] {
    Point(right, left);
  }
}
