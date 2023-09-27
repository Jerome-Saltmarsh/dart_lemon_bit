import 'dart:convert';

import 'package:http/http.dart' as http;

Future<List<String>> getUserCharacterNames() async {

  final url = Uri.parse('http://localhost:8082'); // Replace with your desired URL

  // Send an HTTP GET request
  final response = await http.get(url).catchError((error){
    print(error);
  });

  if (response.statusCode == 200) {
    // If the server returns a 200 OK response, parse the JSON
    final jsonResponse = response.body;
    print('Response: $jsonResponse');
  } else {
    // If the server did not return a 200 OK response, throw an exception
    throw Exception('Failed to load data');
  }

  final characters = jsonDecode(response.body) as List;
  return characters.map((e) => e['name'] as String).toList(growable: false);
}