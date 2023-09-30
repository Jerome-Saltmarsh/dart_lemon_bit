import 'package:typedef/json.dart';

abstract class Database {

  Future connect();
  // Future<int> getHighScore();
  // Future writeHighScore(int value);
  Future<List<Json>> getUser(String userId);
  Future<Json> getCharacter(String characterId);
  Future saveCharacter(Json json);

  Future<String> createCharacter({
    required String userId,
    required String name,
    required int complexion,
    required int hairType,
    required int hairColor,
    required int gender,
    required int headType,
  });
}