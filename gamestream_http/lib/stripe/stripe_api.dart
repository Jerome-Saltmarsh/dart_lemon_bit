import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class StripeApi {
  late final scheme;
  late final host;
  late final version;
  late final apiKey;

  late final Map<String, String>? _headers;

  StripeApi({
    required String apiKey,
    this.scheme = "https",
    this.host = 'api.stripe.com',
    this.version = '2020-08-27'
  }){
    _headers = {
      'Authorization': 'Basic ${base64Encode(utf8.encode('$apiKey:'))}',
      'Stripe-Version': version,
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': "application/json",
    };
  }

  Future<String> getSubscription(String subscriptionId) async {
    print("stripeApi.getSubscription('$subscriptionId)'");
    final uri = Uri(scheme: scheme, host: host, path: 'v1/subscriptions/$subscriptionId');
    final response = await  http.get(uri, headers: _headers);
    if (response.statusCode != 200){
        throw Exception('statusCode: ${response.statusCode}, body:${response.body}');
    }
    return response.body;
  }

  Future<Response> deleteSubscription(String subscriptionId){
    print("stripeApi.deleteSubscription('$subscriptionId')");
    final uri = Uri(scheme: scheme, host: host, path: 'v1/subscriptions/$subscriptionId');
    return http.delete(uri, headers: _headers);
  }
}
