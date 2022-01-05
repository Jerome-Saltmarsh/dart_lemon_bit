@JS()
library stripe;

import 'package:bleed_client/authentication.dart';
import 'package:js/js.dart';

const _apiKey = "pk_test_51KDkJgBamGAHT4Os9qGLDnx3rJc9awLjMXAO60ohrn7FRlhb2lB6Vr2wQOQmXPSt5LBYntGp3JRRvnRFYNQcY4Cz00GyeislDS";

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
  // external String get sessionId;
  external String get customerEmail;

  external factory CheckoutOptions({
    List<LineItem> lineItems,
    String mode,
    String successUrl,
    String cancelUrl,
    String sessionId,
    // String customer,
    String customerEmail
  });
}

@JS()
@anonymous
class LineItem {
  external String get price;

  external int get quantity;

  external factory LineItem({String price, int quantity});
}


void stripeCheckout({required String email}) {
  print("redirectToCheckout()");

  if (email.isEmpty){
    throw Exception('email is empty');
  }

  Stripe(_apiKey).redirectToCheckout(CheckoutOptions(
    lineItems: [
      LineItem(
        price: 'price_1KE2cmBamGAHT4Osredql7tb',
        quantity: 1,
      )
    ],
    mode: 'subscription',
    successUrl: 'https://gamestream.online',
    cancelUrl: 'https://gamestream.online',
    customerEmail: email,
  ));
}