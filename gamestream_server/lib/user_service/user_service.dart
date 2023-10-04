
import 'package:typedef/json.dart';

abstract class UserService {
  Future<Json> getUser(String userId);

  Future saveUserCharacter({
    required String userId,
    required Json character,
  });
}