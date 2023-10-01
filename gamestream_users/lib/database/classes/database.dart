import 'package:typedef/json.dart';

abstract class Database {

  Future<Json> getUser(String userId);

  Future<String> getCharacter(String characterId);

  Future saveCharacter(Json json);

  Future<String> createUser({
    required String username,
    required String password,
  });

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