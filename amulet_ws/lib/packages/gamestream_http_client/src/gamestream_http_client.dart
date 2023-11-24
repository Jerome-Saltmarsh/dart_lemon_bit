import 'dart:convert';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:typedef/json.dart';


abstract class GameStreamHttpClient {

  static const headersJson = {
    'Content-Type': 'application/json',
  };

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

  static Future<Response> createUser({
    required String url,
    required String username,
    required String password,
  }) async {
    return await http.post(
        Uri.parse('$url/register'),
        headers: headersJson,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
    );
    // return response.body;
  }

  static Future<Response> login({
    required String url,
    required String username,
    required String password,
  }) async {
    return http.post(
        Uri.parse('$url/login'),
        headers: headersJson,
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
    );
  }

  static Future<Json> getUser({
    required String url,
    required String userId,
  }) async {

    final requestUrl = '$url/users/$userId';
    final response = await http.get(Uri.parse(requestUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to load data');
    }

    final jsonResponse = response.body;
    return jsonDecode(jsonResponse) as Json;
  }

  static Future patchCharacter({
    required String url,
    required String userId,
    required Json character,
  }) => http.patch(Uri.parse('$url/users/$userId'), body: jsonEncode(character));

  static Future setUserLocked({
    required String url,
    required String userId,
    required bool locked,
  }){
     return http.patch(Uri.parse('$url/lock/$userId'), body: jsonEncode({

     }));
  }

  static Future<Response> deleteCharacter({
    required String url,
    required String userId,
    required String characterId,
  }) =>
    http.delete(Uri.parse('$url/character'),
        headers: headersJson,
        body: jsonEncode({
          'userId': userId,
          'characterId': characterId,
        }),
    );
}
