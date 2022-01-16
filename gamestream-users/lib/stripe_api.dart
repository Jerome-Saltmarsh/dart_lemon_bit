
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class StripeApi {
  final scheme = 'https';
  final host = 'api.stripe.com';
  final version = '2020-08-27';
  final apiKey = 'sk_test_51KDkJgBamGAHT4OsrcRTh2JwtFlc6XXvOgMwtqZKHrQrr9S5zNKUgy1oUNFH2tD8FmynS9zWQgbVbV3YmnI6nrb10046vhqd5e';

  Future<Response> deleteSubscription({required String subscriptionId}){
    print('stripeApi.deleteSubscription($subscriptionId)');
    final uri = Uri(scheme: scheme, host: host, path: 'v1/subscriptions/$subscriptionId');
    print(uri.toString());

    return http.delete(uri, headers: {
      'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:'))}',
      'Stripe-Version': version,
      'Content-Type': 'application/x-www-form-urlencoded',
    });
    // ..baseUrl = baseUrl
    // ..responseType = ResponseType.json
    // ..contentType = 'application/x-www-form-urlencoded'
    // ..headers = {
    // 'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:'))}',
    // 'Stripe-Version': version,
    // 'Content-Type': 'application/x-www-form-urlencoded',
  }
}
