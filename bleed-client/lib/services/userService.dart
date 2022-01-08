

import 'dart:convert';

import 'package:http/http.dart' as http;

void getUser(String userId) async {
  var url = Uri.https('rest-server-5-osbmaezptq-ts.a.run.app', '/users', {'id': userId});

  // Await the http get response, then decode the json-formatted response.
  var response = await http.get(url, headers: {
    "Accept": "application/json",
    "Access-Control-Allow-Origin": "*"
  }).catchError((error){
    print(error);
    if (error is http.ClientException){
    }

    throw error;
  });
  if (response.statusCode == 200) {
    var jsonResponse =
    jsonDecode(response.body) as Map<String, dynamic>;
    var itemCount = jsonResponse['totalItems'];
    print('Number of books about http: $itemCount.');
  } else {
    print('Request failed with status: ${response.statusCode}.');
  }
}