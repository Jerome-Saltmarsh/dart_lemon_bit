import 'package:gamestream_server/isometric/isometric_player.dart';
import 'package:typedef/json.dart';

abstract class Database {

  Future connect();
  Future<int> getHighScore();
  Future writeHighScore(int value);
  Future<List<Json>> getUserCharacters(String userId);
  Future<Json> getCharacter(String characterId);

  void persist(IsometricPlayer player);

  Future createCharacter({
    required String userId,
    required String name,
    required int complexion,
    required int hairType,
    required int hairColor,
    required int gender,
    required int headType,
  });
}