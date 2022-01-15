@JS()
library stripe;

import 'package:js/js.dart';

@JS()
class Stripe {
  external Stripe(String key);

  external redirectToCheckout(CheckoutOptions checkoutOptions);
}

@JS()
@anonymous
class CheckoutOptions {
  external List<LineItem> get lineItems;

  external String get mode;

  external String get successUrl;

  external String get cancelUrl;

  external String get sessionId;

  external String get customerEmail;

  external String get clientReferenceId;

  external factory CheckoutOptions({
    List<LineItem> lineItems,
    String mode,
    String successUrl,
    String cancelUrl,
    String sessionId,
    String clientReferenceId,
    String customerEmail,
  });
}

@JS()
@anonymous
class LineItem {
  external String get price;

  external int get quantity;

  external factory LineItem({String price, int quantity});
}

// config
const _apiKey = "pk_test_51KDkJgBamGAHT4Os9qGLDnx3rJc9awLjMXAO60ohrn7FRlhb2lB6Vr2wQOQmXPSt5LBYntGp3JRRvnRFYNQcY4Cz00GyeislDS";
const _price = 'price_1KI47PBamGAHT4OsTxM3xTgA';

// https://stripe.com/docs/api/checkout/sessions/object
void stripeCheckout({required String userId, String? email}) {
  print("stripeCheckout(userId: '$userId', email: '$email')");

  if (userId.isEmpty) {
    throw Exception("userId is empty");
  }

  Stripe(_apiKey).redirectToCheckout(CheckoutOptions(
    lineItems: [
      LineItem(
        price: _price,
        quantity: 1,
      )
    ],
    mode: 'subscription',
    successUrl: 'https://gamestream.online',
    cancelUrl: 'https://gamestream.online',
    clientReferenceId: userId,
    customerEmail: email ?? '',
  ));
}