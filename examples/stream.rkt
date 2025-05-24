#lang j-notation


interface Sequence[T: Covariant] {

  method stream(): Stream[T];

}


interface Stream[T: Covariant] {

  method transduce(transducer: Transducer[T, R]): Stream[R];

  method into(reducer: Reducer[T, R]): R;

  method map(mapFunction: T -> R): Stream[R] =
    transduce(Transducer.mapping(mapFunction));

  method anyMatch(predicate: T -> Boolean): Boolean =
    into(Reducer.anyMatch(predicate));

  method allMatch(predicate: T -> Boolean): Boolean =
    into(Reducer.allMatch(predicate));

  method noneMatch(predicate: T -> Boolean): Boolean =
    into(Reducer.noneMatch(predicate));
}


sealed interface ConsumptionResult[S: Covariant, R: Covariant] {

  record Unfinished(state: S);

  record Finished(result: R);
}


interface Reducer[T: Contravariant, R: Covariant, S: Invariant = Any]{

  property starter: Unit -> S;

  property consumer: Arguments[T, S] -> ReductionResult[S, R];

  property finisher: S -> R;
}


interface PerpetualReducer[T: Contravariant, R: Covariant, S: Invariant = Any] {

  extends Reducer[T, R, S];

  override property consumer {
    val perpetual = perpetualConsumer();
    lambda(input, state) { Unfinished(perpetual(input, state)) }
  }

  property perpetualConsumer: Arguments[T, S] -> S;
}


interface Collection[T: Covariant] {

  extends Sequence[T];

  property size: NonnegativeInteger;

  method isEmpty(): Boolean = size() == 0;

  method contains(value: CompatibleWith[T]): Boolean;

  method containsAny(values: Sequence[CompatibleWith[T]]): Boolean =
    values.stream().anyMatch(contains);

  method containsAll(values: Sequence[CompatibleWith[T]]): Boolean =
    values.stream().allMatch(contains);

  method containsNone(values: Sequence[CompatibleWith[T]]): Boolean =
    values.stream().noneMatch(contains);
}
