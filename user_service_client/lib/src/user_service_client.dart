import 'dart:convert';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:typedef/json.dart';
import 'headers_json.dart';




abstract class UserServiceClient {

  static Future<bool> ping({
    required String url,
    Function(String message)? onError,
  }) async {
    try {
      final response = await http.get(Uri.parse('$url/ping'));
      if (response.statusCode == 400) {
        onError?.call(response.body);
        return false;
      }
      return response.statusCode == 200;
    } catch (error) {
      onError?.call(error.toString());
      return false;
    }
  }

  static Future<Response> createCharacter({
    required String url,
    required int port,
    required String userId,
    required String password,
    required String name,
    required int complexion,
    required int hairType,
    required int hairColor,
    required int gender,
    required int headType,
  }) =>
      http.post(
          Uri.parse('$url:$port/characters'),
          headers: headersJson,
          body: jsonEncode({
            'userId': userId,
            'password': password,
            'name': name,
            'complexion': complexion,
            'hairType': hairType,
            'hairColor': hairColor,
            'gender': gender,
            'headType': headType,
          }));

  static Future<String> createUser({
    required String url,
    required int port,
    required String username,
    required String password,
  }) async {
    final response = await http.post(
        Uri.parse('$url:$port/users'),
        headers: headersJson,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
    );
    return response.body;
  }

  static Future<List<Json>> getUserCharacters({
    required String url,
    required String userId,
  }) async {

    final response = await http.get(Uri.parse('$url/users/$userId'));

    if (response.statusCode == 200) {
      final jsonResponse = response.body;
      print('Response: $jsonResponse');
    } else {
      // If the server did not return a 200 OK response, throw an exception
      throw Exception('Failed to load data');
    }

    return jsonDecode(response.body).cast<Json>();
  }

  static Future<Json> findCharacterById({
    required String url,
    required String id,
  }) async {
    final response = await http.get(Uri.parse('$url/characters/$id'));
    return jsonDecode(response.body);
  }

}
