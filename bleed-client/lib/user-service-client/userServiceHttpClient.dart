

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

final userService = UserServiceHttpClient("rest-server-7-osbmaezptq-ey.a.run.app");

class UserServiceHttpClient {
  final String _host;

  UserServiceHttpClient(this._host);

  Future<int> getVersion() async {
    var url = Uri.https(_host, '/version');
    final response = await http.get(url, headers: _headers);
    final responseBody = jsonDecode(response.body);
    final val = responseBody['version'];
    return val;
  }

  Future<ChangeNameStatus> changePublicName({required String userId, required String publicName}) async {
    print("userService.changePublicName()");
    var url = Uri.https(_host, '/users', {'id': userId, 'public_name': publicName, 'method': 'change_public_name'});
    final response = await http.get(url, headers: _headers);
    final responseBody = jsonDecode(response.body);
    final responseError = responseBody['error'];

    if (responseError != null && responseError != 'same_value'){
      print(responseError);
      return _stringEnum(responseError, changeNameStatuses);
    }

    return ChangeNameStatus.Success;
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
      subscriptionStartDate: subscriptionCreationDate,
      subscriptionEndDate: subscriptionExpirationDate,
      accountCreationDate: accountCreationDate,
      publicName: publicName,
      privateName: privateName,
      email: email,
      subscriptionStatus: subscriptionStatus,
    );
  }

  Future<Response> cancelSubscription(String userId) async {
    print("userService.cancelSubscription('$userId')");
    final url = Uri.https(_host, '/users', {'id': userId, 'method': 'cancel_subscription'});
    return http.get(url, headers: _headers);
  }
}

class Account {
  final SubscriptionStatus subscriptionStatus;
  final String userId;
  final DateTime accountCreationDate;
  final String publicName;
  final String privateName;
  final String email;
  final DateTime? subscriptionStartDate;
  final DateTime? subscriptionEndDate;

  bool get subscriptionActive => subscriptionStatus == SubscriptionStatus.Active;
  bool get subscriptionEnded => subscriptionStatus == SubscriptionStatus.Ended;
  bool get subscriptionNone => subscriptionStatus == SubscriptionStatus.Not_Subscribed;

  bool get isPremium => subscriptionEndDate != null && subscriptionEndDate!.isAfter(DateTime.now());

  Account({
    required this.userId,
    required this.accountCreationDate,
    required this.publicName,
    required this.privateName,
    required this.email,
    required this.subscriptionStatus,
    this.subscriptionEndDate,
    this.subscriptionStartDate,
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
  value = value.trim().replaceAll("_", " ").toLowerCase();
  for(SubscriptionStatus status in subscriptionStatuses){
    if (_enumString(status).toLowerCase() == value){
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


enum ChangeNameStatus {
  Success,
  Taken,
  Too_Short,
  Too_Long,
  Other
}

final List<ChangeNameStatus> changeNameStatuses = ChangeNameStatus.values;

T _stringEnum<T>(String text, List<T> values){
  final textFixed = text.trim().toLowerCase().replaceAll(" ", "_");
  for(T status in values){
    if (status.toString().toLowerCase().contains(textFixed)){
      return status;
    }
  }
  throw Exception("Could not parse $text");
}

String _enumString(dynamic value){
  String text = value.toString();
  int index = text.indexOf(".");
  if (index == -1) return text;
  return text.substring(index + 1, text.length).replaceAll("_", " ");
}
