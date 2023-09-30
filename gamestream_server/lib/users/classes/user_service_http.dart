

import 'dart:convert';

import 'package:gamestream_server/isometric.dart';
import 'package:gamestream_server/users/functions/map_isometric_player_to_json.dart';
import 'package:typedef/json.dart';

import 'user_service.dart';
import 'package:http/http.dart' as http;

class UserServiceHttp implements UserService {

  final String scheme;
  final String host;
  final int port;

  String get characters => '$scheme://$host:$port/characters';
  String get users => '$scheme://$host:$port/users';

  UserServiceHttp({
    required this.scheme,
    required this.host,
    required this.port,
  });

  @override
  Future saveIsometricPlayer(IsometricPlayer player) async {
    final url = Uri.parse('$characters/${player.uuid}');

    final playerJson = mapIsometricPlayerToJson(player);
    return await http.patch(url, body: jsonEncode(playerJson));
  }

  @override
  Future<Json> findCharacterById(String id) async {
    final url = Uri.parse('$characters/$id');
    final response = await http.get(url);
    return jsonDecode(response.body);
  }

  @override
  Future<Json> findUserById(String id) {
    // TODO: implement findUserById
    throw UnimplementedError();
  }
}