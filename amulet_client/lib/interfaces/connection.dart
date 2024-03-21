
import 'package:amulet_common/src.dart';
import 'package:lemon_json/src.dart';

abstract class Connection {

  bool get connected;

  Future<String> createNewCharacter({
    required String name,
    required int complexion,
    required int hairType,
    required int hairColor,
    required int gender,
    required int headType,
    required Difficulty difficulty,
  });

  void playCharacter(String characterUuid);

  Future deleteCharacter(String characterId);

  void disconnect();

  void send(dynamic data);

  Future<List<Json>> getCharacters();
}