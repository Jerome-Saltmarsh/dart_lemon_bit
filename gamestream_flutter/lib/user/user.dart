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
  final scheme = Watch('https');
  final host = Watch('gamestream-http-osbmaezptq-uc.a.run.app');
  final port = Watch(8080);
  // var scheme = 'http';
  // var host = 'localhost';
  // var port = 8082;
  final connected = Watch(false);
  final error = Watch('');

  final characters = Watch<List<Json>>([]);

  String get endpoint => '${scheme.value}://${host.value}:${port.value}';

  User(){
    testConnection().then((value) {
      if (value){
        refreshCharacterNames();
      }
    });
  }

  Future<bool> testConnection() {
    return sendPing().then((value) {
      connected.value = value;
      return value;
    });
  }


  void refreshCharacterNames() async =>
      characters.value = await getUserCharacters(
        scheme: scheme.value,
        host: host.value,
        port: port.value,
        userId: id,
      );

  void playCharacter(String characterId) {
    network.connectToGame(GameType.Amulet, '--id $characterId');
  }

  Future<bool> sendPing() async {
    try {
      final response = await http.get(Uri.parse('$endpoint/ping'));
      return response.statusCode == 200;
    } catch (error){
      this.error.value = error.toString();
      return false;
    }
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
       http.post(Uri.parse(endpoint),
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
