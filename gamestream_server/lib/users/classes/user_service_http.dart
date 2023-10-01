

import 'dart:convert';

import 'package:gamestream_server/isometric.dart';
import 'package:gamestream_server/users/functions/map_isometric_player_to_json.dart';

import 'package:http/http.dart' as http;

class UserServiceHttp {

  final String url;

  String get characters => '$url/characters';
  String get users => '$url/users';

  UserServiceHttp({
    required this.url,
  });

  Future saveIsometricPlayer(IsometricPlayer player) async {
    final url = Uri.parse('$characters/${player.uuid}');

    final playerJson = mapIsometricPlayerToJson(player);
    return await http.patch(url, body: jsonEncode(playerJson));
  }
}