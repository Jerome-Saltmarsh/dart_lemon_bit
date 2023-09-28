import 'package:gamestream_flutter/gamestream/isometric/components/isometric_component.dart';
import 'package:gamestream_flutter/gamestream/isometric/src.dart';
import 'package:gamestream_flutter/packages/common/src/game_type.dart';
import 'package:lemon_watch/src.dart';
import 'package:typedef/json.dart';

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

  void loadCharacterById(String characterId) {
    network.connectToGame(GameType.Amulet, '--id $characterId');
  }
}
