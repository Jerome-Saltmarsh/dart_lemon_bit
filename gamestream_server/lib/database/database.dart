import 'package:gamestream_server/isometric/isometric_player.dart';
import 'package:typedef/json.dart';

abstract class Database {
  Future connect();
  Future<int> getHighScore();
  Future writeHighScore(int value);
  void persist(IsometricPlayer player);

  Future<List<Json>> getUserCharacters(String userId);
}