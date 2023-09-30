

import 'dart:convert';

import 'package:gamestream_server/isometric.dart';
import 'package:typedef/json.dart';

import 'user_service.dart';
import 'package:http/http.dart' as http;

class UserServiceHttp implements UserService {

  final String scheme;
  final String host;
  final int port;

  UserServiceHttp({
    required this.scheme,
    required this.host,
    required this.port,
  });

  @override
  Future saveIsometricPlayer(IsometricPlayer player) async {
    final url = Uri.parse('$scheme://$host');
    final response = await http.get(url);

  }

  @override
  Future<Json> findCharacterById(String characterId) async {
    final url = Uri.parse('$scheme://$host:$port/characters/$characterId');
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  @override
  Future<Json> findUserById(String id) {
    // TODO: implement findUserById
    throw UnimplementedError();
  }
}