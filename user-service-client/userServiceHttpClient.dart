

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';


final userService = UserServiceHttpClient("rest-server-11-osbmaezptq-ey.a.run.app");

class UserServiceHttpClient {
  final String _host;

  UserServiceHttpClient(this._host);

  Future<Map<String, dynamic>> patchDisplayName({required String userId, required String displayName}) async {
    print("patchDisplayName()");
    var url = Uri.https(_host, '/users', {'id': userId, 'display_name': displayName, 'method': 'patch'});
    final json = '{"title": "Hello"}';
    final response = await http.patch(url, body: json, headers: _headers);
    return jsonDecode(response.body);
  }

  Future createAccount({
    required String userId,
    required String email,
    String? displayName
  }) async {
    print("createAccount()");
    var url = Uri.https(_host, '/users', {
      'id': userId,
      'email': email,
      'method': "post",
      'display_name': displayName
    });
    await http.post(url, headers: _headers);
  }

  Future<Account?> findById(String userId) async {
    print("getAccount()");

    if (userId.isEmpty) throw Exception("user is Empty");

    var url = Uri.https(_host, '/users', {'id': userId, 'method': 'get'});

    var response = await http.get(url, headers: _headers);

    if (response.statusCode != 200) {
      throw Exception('Request failed with status: ${response.statusCode}.');
    }
    var body = jsonDecode(response.body) as Map<String, dynamic>;

    final error = body[fieldNames.error];
    if (error != null) {
      if (error == "not_found") {
        return null;
      }
      throw Exception(body);
    }

    DateTime? subscriptionExpirationDate;
    final subscriptionExpirationDateString =
        body[fieldNames.subscriptionExpirationDate];
    if (subscriptionExpirationDateString != null) {
      subscriptionExpirationDate =
          DateTime.parse(subscriptionExpirationDateString);
    }

    final email = body[fieldNames.email];

    final displayName = body[fieldNames.displayName];

    return Account(
      userId: userId,
      subscriptionExpirationDate: subscriptionExpirationDate,
      displayName: displayName,
      email: email,
    );
  }
}

class Account {
  final String userId;
  final DateTime? subscriptionExpirationDate;
  final String? displayName;
  final String? email;

  bool get subscriptionActive => subscriptionStatus == SubscriptionStatus.Active;
  bool get subscriptionExpired => subscriptionStatus == SubscriptionStatus.Expired;
  bool get subscriptionNone => subscriptionStatus == SubscriptionStatus.None;

  SubscriptionStatus get subscriptionStatus {
    if (subscriptionExpirationDate == null) return SubscriptionStatus.None;
    final now = DateTime.now().toUtc();
    if (subscriptionExpirationDate!.isBefore(now)) return SubscriptionStatus.Expired;
    return SubscriptionStatus.Active;
  }

  Account({
    required this.userId,
    this.subscriptionExpirationDate,
    this.displayName,
    this.email
  });
}

final _headers = {
  "Accept": "*/*",
  "Access-Control-Allow-Origin": "*",
};

enum SubscriptionStatus{
  None,
  Active,
  Expired
}

final _FieldNames fieldNames = _FieldNames();

class _FieldNames {
  final String subscriptionExpirationDate = "subscription_expiration_date";
  final String subscriptionStatus = "subscription_status";
  final String error = "error";
  final String stripeCustomerId = 'stripe_customer_id';
  final String email = 'email';
  final String displayName = 'display_name';
}


// Future get(Uri url, ) async {
//   final client = Client();
//   final method = 'GET';
//   final request = Request(method, url);
//   final streamedResponse = await client.send(request);
//   return await Response.fromStream(streamedResponse);
// }