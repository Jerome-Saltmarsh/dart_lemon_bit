

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:typedef/json.dart';

final firestoreService = _FirestoreService();

class _FirestoreService {
  final _url = "https://gamestream-firestore-26-osbmaezptq-ts.a.run.app";

  String get _host => _url.replaceAll("https://", "");

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

  Future saveCharacter({required Account account, required double x, required double y}) async {
    print("saveCharacter()");
    final Map<String, String> body = {
      'id': account.userId,
      'x': x.toInt().toString(),
      'y': y.toInt().toString(),
    };
    var url = Uri.https(_host, '/characters');
    await http.post(url, headers: _headersJSON, body: jsonEncode(body));
  }

  Future loadCharacter(Account account) async {
    final response = await httpGet('/characters', {'id': account.userId});
    return jsonDecode(response.body);
  }

  Future createAccount({
    required String userId,
    required String email,
    required String privateName,
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

  Future<Account?> findUserById(String userId) async {
    print("firestoreService.findUserById()");

    if (userId.isEmpty) throw Exception("userId is Empty");

    var response = await get('users', params: {'id': userId});

    if (response.statusCode != 200) {
      throw Exception('Request failed with status: ${response.statusCode}.');
    }
    var body = jsonDecode(response.body) as Json;

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

  Future<Json> loadMap(String mapId) async {
     final response = await get('maps', params: {
       'id': mapId
     });
     final body = utf8.decode(response.bodyBytes);
     return jsonDecode(body);
  }

  Future<Response> createMap({required String mapId, required Json map}){
    print("firestoreService.createMap(id: '$mapId')");
    return post(endpoint: 'maps', params: {
      'id': mapId,
    },
      body: jsonEncode(map),
    );
  }

  Future<List<String>> getMapNames() async {
    final response = await get('maps');
    final body = jsonDecode(response.body) as List<dynamic>;
    final List<String> names = [];
    for(var entry in body){
      if (entry is String){
        names.add(entry);
      }
    }
    return names;
  }

  Future<Response> get(String endpoint, {Json? params, String? method}){

    if (method != null && params != null){
      params['method'] = method;
    }

    final url = Uri.https(_host, '/$endpoint', params);
    return http.get(url, headers: _headers);
  }

  Future<Response> post({
    required String endpoint,
    required Json params,
    required Object body
  }){
    final url = Uri.https(_host, '/$endpoint', params);
    return http.post(url, headers: {
      header.contentType: contentType.applicationJsonUTF8,
      header.accessControlAllowOrigin: "*",
    }, body: body);
  }

  Future<http.Response> httpGet(String url, Map<String, dynamic>? queries){
    return http.get(Uri.https(_host, url, queries), headers: _headers);
  }
}

final _ContentType contentType = _ContentType();
final _Headers header = _Headers();

class _ContentType {
  final applicationJson = "applications/json";
  final applicationJsonUTF8 = "application/json; charset=UTF-8";
}

class _Headers {
   final String contentType = "Content-Type";
   final String accept = "Accept";
   final String accessControlAllowOrigin = "Access-Control-Allow-Origin";
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

final _headersJSON = {
  "Accept": "*/*",
  "Access-Control-Allow-Origin": "*",
  "Content-Type": "application/json"
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

