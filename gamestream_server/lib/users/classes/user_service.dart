import 'package:gamestream_server/isometric.dart';
import 'package:typedef/json.dart';

abstract class UserService {
  Future saveIsometricPlayer(IsometricPlayer player);
  Future<Json> findCharacterById(String id);
  Future<Json> findUserById(String id);
}