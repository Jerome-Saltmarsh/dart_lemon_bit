import 'package:gamestream_server/isometric/isometric_player.dart';

abstract class Database {
  Future connect();
  Future<int> getHighScore();
  Future writeHighScore(int value);
  void persist(IsometricPlayer player);
}