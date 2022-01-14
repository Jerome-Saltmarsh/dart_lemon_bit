

import 'dart:convert';
import 'package:http/http.dart' as http;

final userService = UserServiceHttpClient("rest-server-osbmaezptq-ey.a.run.app");

class UserServiceHttpClient {
  final String _host;

  UserServiceHttpClient(this._host);

  Future<Map<String, dynamic>> patchDisplayName({required String userId, required String displayName}) async {
    print("patchDisplayName()");
    var url = Uri.https(_host, '/users', {'id': userId, 'display_name': displayName, 'method': 'patch'});
    // final json = '{"title": "Hello"}';
    final response = await http.patch(url, body: '', headers: _headers);
    return jsonDecode(response.body);
  }

  Future createAccount({
    required String userId,
    required String email,
    String? privateName
  }) async {
    print("createAccount(email: '$email', privateName: '$privateName')");
    var url = Uri.https(_host, '/users', {
      'id': userId,
      'email': email,
      'method': "post",
      'private_name': privateName
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
    DateTime? subscriptionCreationDate;
    final subscriptionExpirationDateString = body[fieldNames.subscriptionExpirationDate];
    if (subscriptionExpirationDateString != null) {
      final subscriptionCreatedDateString = body[fieldNames.subscriptionCreatedDate];
      if (subscriptionCreatedDateString == null) {
        throw Exception("subscriptionCreatedDateString is null");
      }
      subscriptionExpirationDate = parseDateTime(subscriptionExpirationDateString);
      subscriptionCreationDate = parseDateTime(subscriptionCreatedDateString);
    }

    final accountCreationDateString = body[fieldNames.accountCreationDate];
    if (accountCreationDateString == null){
      throw Exception("account_creation_date field missing from response");
    }

    final accountCreationDate = parseDateTime(accountCreationDateString);

    final email = body[fieldNames.email];

    if (email == null){
      throw Exception("email is null");
    }

    final privateName = body[fieldNames.private_name];

    if (privateName == null){
      throw Exception("private name is null");
    }

    final publicName = body[fieldNames.public_name];

    if (publicName == null){
      throw Exception("public name is null");
    }

    return Account(
      userId: userId,
      subscriptionCreationDate: subscriptionCreationDate,
      subscriptionExpirationDate: subscriptionExpirationDate,
      accountCreationDate: accountCreationDate,
      publicName: publicName,
      privateName: privateName,
      email: email,
    );
  }
}

class Account {
  final String userId;
  final DateTime accountCreationDate;
  final String publicName;
  final String privateName;
  final String email;
  final DateTime? subscriptionExpirationDate;
  final DateTime? subscriptionCreationDate;

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
    required this.accountCreationDate,
    required this.publicName,
    required this.privateName,
    required this.email,
    this.subscriptionExpirationDate,
    this.subscriptionCreationDate,
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
  final String accountCreationDate = "account_creation_date";
  final String subscriptionExpirationDate = "subscription_expiration_date";
  final String subscriptionStatus = "subscription_status";
  final String error = "error";
  final String stripeCustomerId = 'stripe_customer_id';
  final String email = 'email';
  final String public_name = 'public_name';
  final String private_name = 'private_name';
  final String subscriptionCreatedDate = "subscription_created_date";
}


// Future get(Uri url, ) async {
//   final client = Client();
//   final method = 'GET';
//   final request = Request(method, url);
//   final streamedResponse = await client.send(request);
//   return await Response.fromStream(streamedResponse);
// }

DateTime parseDateTime(String value){
  return DateTime.parse(value);
}