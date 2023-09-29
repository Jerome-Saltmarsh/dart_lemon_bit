import 'dart:convert';

import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/gamestream/isometric/src.dart';
import 'package:gamestream_flutter/packages/common/src/game_type.dart';
import 'package:http/http.dart';
import 'package:lemon_watch/src.dart';
import 'package:typedef/json.dart';
import 'package:http/http.dart' as http;

import 'get_user_characters.dart';

class User with IsometricComponent {
  var id = 'user_01';
  var scheme = 'http';
  var host = 'localhost';
  var port = 8082;

  final characters = Watch<List<Json>>([]);

  User(){
    refreshCharacterNames();
  }

  void refreshCharacterNames() async =>
      characters.value = await getUserCharacters(
        scheme: scheme,
        host: host,
        port: port,
        userId: id,
      );

  void playCharacter(String characterId) {
    network.connectToGame(GameType.Amulet, '--id $characterId');
  }

  Future<Response> createNewCharacter({
    required String userId,
    required String name,
    required int complexion,
    required int hairType,
    required int hairColor,
    required int gender,
    required int headType,
  }) =>
       http.post(Uri.parse('$scheme://$host:$port'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode(<String, dynamic>{
            'userId': userId,
            'name': name,
            'complexion': complexion,
            'hairType': hairType,
            'hairColor': hairColor,
            'gender': gender,
            'headType': headType,
          }));
}
