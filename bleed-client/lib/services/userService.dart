

import 'dart:convert';

import 'package:http/http.dart' as http;

Future<DateTime?> getUserSubscriptionExpiration(String userId) async {
  print("getUserSubscriptionExpiration($userId)");

  if (userId.isEmpty) throw Exception("user is Empty");

  var url = Uri.https('rest-server-6-osbmaezptq-ey.a.run.app', '/users', {'id': userId});

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

    if (!body.containsKey('status')){
      throw Exception("response missing status");
    }

    final status = body['status'];

    if (status == 'user_not_found') {
      print("user not found in subscription service");
      return null;
    }

    if (status != 'success'){
      throw Exception(response.body);
    }

    if (!body.containsKey('sub_exp')){
      throw Exception("response missing sub_exp field");
    }
    final subExpString = body['sub_exp'];
    return DateTime.parse(subExpString);
  }
  print('Request failed with status: ${response.statusCode}.');
  return null;
}

class Account {
  final String userId;
  final DateTime? subscription;
  final String displayName;

  Account(this.userId, this.subscription, this.displayName);
}