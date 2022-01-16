

import 'dart:convert';
import 'package:bleed_client/toString.dart';
import 'package:http/http.dart' as http;

final userService = UserServiceHttpClient("rest-server-1-osbmaezptq-ey.a.run.app");

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
    final currentPeriodStart = body['subscription_current_period_start'];
    if (currentPeriodStart != null) {
      final currentPeriodEnd = body['subscription_current_period_end'];
      subscriptionCreationDate = parseEpoch(currentPeriodStart);
      subscriptionExpirationDate = parseEpoch(currentPeriodEnd);
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

    SubscriptionStatus subscriptionStatus = SubscriptionStatus.Not_Subscribed;
    final subscriptionStatusString = body[fieldNames.subscriptionStatus];
    if (subscriptionStatusString != null){
      subscriptionStatus = parseSubscriptionStatus(subscriptionStatusString);
    }

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
      subscriptionStatus: subscriptionStatus,
    );
  }
}

class Account {
  final SubscriptionStatus subscriptionStatus;
  final String userId;
  final DateTime accountCreationDate;
  final String publicName;
  final String privateName;
  final String email;
  final DateTime? subscriptionExpirationDate;
  final DateTime? subscriptionCreationDate;

  bool get subscriptionActive => subscriptionStatus == SubscriptionStatus.Active;
  bool get subscriptionExpired => subscriptionStatus == SubscriptionStatus.Ended;
  bool get subscriptionNone => subscriptionStatus == SubscriptionStatus.Not_Subscribed;

  // SubscriptionStatus get subscriptionStatus {
  //   if (subscriptionExpirationDate == null) return SubscriptionStatus.None;
  //   final now = DateTime.now().toUtc();
  //   if (subscriptionExpirationDate!.isBefore(now)) return SubscriptionStatus.Ended;
  //   return SubscriptionStatus.Active;
  // }

  Account({
    required this.userId,
    required this.accountCreationDate,
    required this.publicName,
    required this.privateName,
    required this.email,
    required this.subscriptionStatus,
    this.subscriptionExpirationDate,
    this.subscriptionCreationDate,
  });
}

final _headers = {
  "Accept": "*/*",
  "Access-Control-Allow-Origin": "*",
};

enum SubscriptionStatus {
  Not_Subscribed,
  Active,
  Past_Due,
  Unpaid,
  Canceled,
  Incomplete,
  Incomplete_Expired,
  Trialing,
  All,
  Ended
}

final List<SubscriptionStatus> subscriptionStatuses = SubscriptionStatus.values;

SubscriptionStatus parseSubscriptionStatus(String value){
  for(SubscriptionStatus status in subscriptionStatuses){
    if (enumString(status).toLowerCase() == value.toLowerCase()){
      return status;
    }
  }
  throw Exception("could not parse $value to subscription status");
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

DateTime parseDateTime(String value){
  return DateTime.parse(value);
}

DateTime parseEpoch(int epoch){
  return DateTime.fromMillisecondsSinceEpoch(epoch * 1000).toLocal();
}
