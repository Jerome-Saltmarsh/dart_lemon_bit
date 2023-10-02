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
          Uri.parse('$url/character'),
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
    required String username,
    required String password,
  }) async {
    final response = await http.post(
        Uri.parse('$url/register'),
        headers: headersJson,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
    );
    return response.body;
  }

  static Future<String> login({
    required String url,
    required String username,
    required String password,
  }) async {
    final response = await http.post(
        Uri.parse('$url/login'),
        headers: headersJson,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
    );
    final body = response.body;
    final body2 = body.replaceAll('\"', "");
    return body2;
  }

  static Future<List<Json>> getUserCharacters({
    required String url,
    required String userId,
  }) async {

    final requestUrl = '$url/users/$userId';
    final response = await http.get(Uri.parse(requestUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }

    final jsonResponse = response.body;
    print('Response: $jsonResponse');
    final responseJson =  jsonDecode(jsonResponse) as Json;

    final characterStrings =  responseJson.getList<String>('characters');
    final values = characterStrings.map(jsonDecode).toList(growable: false).cast<Json>();
    return values;
  }

  static Future patchCharacter({
    required String url,
    required String userId,
    required Json character,
  }) => http.patch(Uri.parse('$url/users/$userId'), body: jsonEncode(character));
}
