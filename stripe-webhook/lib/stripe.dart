// stripe webhook handlers
import 'package:gamestream_stripe_webhook/firestore.dart';

final webhooks = _StripeWebhooks();

typedef Json = Map<String, dynamic>;

class _StripeWebhooks {

  void handleEvent(Json event){
    final type = event['type'];
    if (type == null){
      throw Exception("event.type is null");
    }
    switch(type){
      case 'checkout.session.completed':
        _checkoutSessionCompleted(event);
        break;
      default:
        // print('no handler for stripe event $type');
        break;
    }
  }

  void _checkoutSessionCompleted(Json event){
    print("stripe.checkoutSessionCompleted()");

    if (!event.containsKey('data')){
      throw Exception("event does not contain data");
    }

    final data = event['data'] as Json;

    if (!data.containsKey('object')){
      throw Exception("data does not contain object");
    }

    final obj = data['object'] as Json;

    if (!obj.containsKey('client_reference_id')) {
      throw Exception('Object does not contain client_reference_id');
    }

    final userId = obj['client_reference_id'];
    final stripeCustomerId = obj['customer'];
    final stripePaymentEmail = obj['customer_email'];
    final subscriptionId = obj['subscription'];

    firestore.subscribe(
        userId: userId,
        stripeCustomerId: stripeCustomerId,
        subscriptionId: subscriptionId,
        stripePaymentEmail: stripePaymentEmail
    );
  }
}
