

import 'dart:convert';

import 'package:http/http.dart' as http;

final userService = UserServiceHttpClient("rest-server-11-osbmaezptq-ey.a.run.app");

class UserServiceHttpClient {
  final String _host;

  UserServiceHttpClient(this._host);

  Future<Account?> getAccount(String userId) async {
    print("getUserSubscriptionExpiration($userId)");

    if (userId.isEmpty) throw Exception("user is Empty");

    var url = Uri.https(_host, '/users', {'id': userId});

    // Await the http get response, then decode the json-formatted response.
    var response = await http.get(url, headers: {
      "Accept": "application/json",
      "Access-Control-Allow-Origin": "*"
    }).catchError((error){
      print(error);
      throw error;
    });
    if (response.statusCode == 200) {
      var body = jsonDecode(response.body) as Map<String, dynamic>;

      final error = body[fieldNames.error];
      if (error != null) {
        if (error == "not_found"){
          return null;
        }
        throw Exception(body);
      }

      DateTime? subscriptionExpirationDate;
      final subscriptionExpirationDateString = body[fieldNames.subscriptionExpirationDate];
      if (subscriptionExpirationDateString != null){
          subscriptionExpirationDate = DateTime.parse(subscriptionExpirationDateString);
      }

      final displayName = body[fieldNames.displayName];

      return Account(
        userId: userId,
        subscriptionExpirationDate: subscriptionExpirationDate,
        displayName: displayName,
      );
    }
    print('Request failed with status: ${response.statusCode}.');
    return null;
  }
}


class Account {
  final String userId;
  final DateTime? subscriptionExpirationDate;
  final String? displayName;

  bool get subscriptionActive => subscriptionStatus == SubscriptionStatus.Active;
  bool get subscriptionExpired => subscriptionStatus == SubscriptionStatus.Expired;
  bool get subscriptionNone => subscriptionStatus == SubscriptionStatus.None;

  SubscriptionStatus get subscriptionStatus {
    if (subscriptionExpirationDate == null) return SubscriptionStatus.None;
    final now = DateTime.now().toUtc();
    if (subscriptionExpirationDate!.isBefore(now)) return SubscriptionStatus.Expired;
    return SubscriptionStatus.Active;
  }

  Account({required this.userId, this.subscriptionExpirationDate, this.displayName});
}

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