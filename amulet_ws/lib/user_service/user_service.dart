
import 'package:gamestream_ws/packages/amulet_engine/packages/isometric_engine/packages/type_def/json.dart';

abstract class UserService {
  Future<Json> getUser(String userId);

  Future saveUserCharacter({
    required String userId,
    required Json character,
  });
}