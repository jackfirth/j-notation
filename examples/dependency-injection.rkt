#lang j-notation

qualifier PayPal;
qualifier Named(name: String);

interface CreditCardProcessor;
interface TransactionLog;
interface BillingService;

injectable class RealBillingService {

  implements BillingService;

  inject formatter: ReceiptFormatter;
  inject processor: #[PayPal] CreditCardProcessor;
  inject transactionLog: #[Named("production")] TransactionLog;

  method chargeOrder(order: PizzaOrder, creditCard: CreditCard): Receipt;
};

record InjectionKey(optional qualifier: Qualifier, type: Type);

repeated annotation injects(key: InjectionKey) {
  constructor injects(optional qualifier: Qualifier, type: Type) =
    construct(InjectionKey(qualifier, type));
};

annotation injected(optional qualifier: Qualifier);

// `injectable` ought to be a macro that generates a constructor accepting the injector.
// Should probably also generate static information that can be used to statically check
// the injection graph.
class RealBillingService {

  implements BillingService;
  injects(ReceiptFormatter);
  injects(PayPal, CreditCardProcessor)
  injects(Named("production"), TransactionLog)

  field formatter: ReceiptFormatter;
  field processor: CreditCardProcessor;
  field transactionLog: TransactionLog;

  // This constructor is macro-generated, so it should only be visible to the DI
  // implementation code. This means constructors need scopes attached to them.
  constructor RealBillingService(injector: Injector) {
    // `inject()` is a generic method whose return type is the type of object to inject.
    formatter = injector.inject(ReceiptFormatter);
    processor = injector.inject(PayPal, CreditCardProcessor); // optional qualifier passed as argument
    transactionLog = injector.inject(Named("production"), TransactionLog);
  };
};

// Interfaces should be able to declare injected dependencies that all implementations
// must provide. This lets interface methods depend on injected dependencies.
injectable interface ImageLoader {

  inject logger: Logger;

  method load(source: Url): Image;

  method tryLoad(source: Url): Option<Image> {
    try {
      present(load(source));
    } catch(e: LoadFailure) {
      logger.atWarning().withCause(e).log("Could not load image " + source);
      absent;
    };
  };
};

// The injectable interface above should expand to an interface with a logger property.
// It should also add static information to the interface that classes use when generating
// their injection code.
interface ImageLoader {

  // When injectable clients implement an interface with injected properties, they
  // automatically get injected fields that back the properties.
  property logger : Logger : injected();

  method load(source: Url): Image;

  method tryLoad(source: Url): Option<Image> {
    try {
      present(load(source));
    } catch(e: LoadFailure) {
      logger.atWarning().withCause(e).log("Could not load image " + source);
      absent;
    };
  };
};
